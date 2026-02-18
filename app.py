import os
import logging
from random import randint
from datetime import datetime, timedelta

from flask import (
    Flask,
    render_template,
    request,
    redirect,
    url_for,
    session,
    flash
)

from flask_sqlalchemy import SQLAlchemy
from werkzeug.security import generate_password_hash, check_password_hash

from sendgrid import SendGridAPIClient
from sendgrid.helpers.mail import Mail


# --------------------------------------------------
# APP INITIALIZATION
# --------------------------------------------------

app = Flask(__name__)

# Secure secret key
app.config['SECRET_KEY'] = os.getenv(
    "SECRET_KEY",
    os.urandom(32).hex()
)

# Secure cookie settings
app.config.update(
    SESSION_COOKIE_HTTPONLY=True,
    SESSION_COOKIE_SECURE=True,
    SESSION_COOKIE_SAMESITE="Lax",
    PERMANENT_SESSION_LIFETIME=timedelta(minutes=30)
)


# --------------------------------------------------
# LOGGING
# --------------------------------------------------

logging.basicConfig(level=logging.INFO)


# --------------------------------------------------
# DATABASE CONFIGURATION (Supabase / Render Safe)
# --------------------------------------------------

db_url = os.getenv("DATABASE_URL", "sqlite:///users.db")

# Fix deprecated postgres prefix
if db_url.startswith("postgres://"):
    db_url = db_url.replace(
        "postgres://",
        "postgresql://",
        1
    )

app.config['SQLALCHEMY_DATABASE_URI'] = db_url

app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# Prevent stale connection crashes
app.config['SQLALCHEMY_ENGINE_OPTIONS'] = {
    "pool_pre_ping": True,
    "pool_recycle": 300
}


# --------------------------------------------------
# SENDGRID CONFIGURATION
# --------------------------------------------------

app.config['MAIL_DEFAULT_SENDER'] = os.getenv(
    "MAIL_DEFAULT_SENDER",
    "verified@email.com"
)

SENDGRID_API_KEY = os.getenv("SENDGRID_API_KEY")

if not SENDGRID_API_KEY:
    logging.warning(
        "SENDGRID_API_KEY not set — email will fail."
    )
else:
    logging.info("SendGrid configured successfully.")


# --------------------------------------------------
# DATABASE INIT
# --------------------------------------------------

db = SQLAlchemy(app)


# --------------------------------------------------
# USER MODEL
# --------------------------------------------------

class User(db.Model):

    id = db.Column(
        db.Integer,
        primary_key=True
    )

    username = db.Column(
        db.String(80),
        unique=True,
        nullable=False
    )

    email = db.Column(
        db.String(120),
        unique=True,
        nullable=False
    )

    password = db.Column(
        db.String(200),
        nullable=False
    )

    created_at = db.Column(
        db.DateTime,
        default=datetime.utcnow
    )


# --------------------------------------------------
# SEND OTP EMAIL FUNCTION
# --------------------------------------------------

def send_otp_email(email, username, otp):

    if not SENDGRID_API_KEY:

        logging.error("SENDGRID_API_KEY missing")

        return False

    try:

        message = Mail(

            from_email=app.config['MAIL_DEFAULT_SENDER'],

            to_emails=email,

            subject="Verify Your Account - AI CyberShield Matrix",

            plain_text_content=f"""
Hello {username},

Your OTP is: {otp}

This OTP expires in 5 minutes.

Regards,
AI CyberShield Team
"""
        )

        sg = SendGridAPIClient(SENDGRID_API_KEY)

        sg.send(message)

        logging.info(f"OTP sent to {email}")

        return True

    except Exception as e:

        logging.error(f"SendGrid error: {e}")

        return False


# --------------------------------------------------
# HOME ROUTE
# --------------------------------------------------

@app.route('/')
def home():

    return render_template("index.html")


# --------------------------------------------------
# REGISTER ROUTE
# --------------------------------------------------

@app.route('/register', methods=['GET', 'POST'])
def register():

    if request.method == 'POST':

        username = request.form.get('username')
        email = request.form.get('email')
        password = request.form.get('password')

        if not username or not email or not password:

            return render_template(
                "register.html",
                error="All fields required"
            )

        if User.query.filter_by(
            username=username
        ).first():

            return render_template(
                "register.html",
                error="Username already exists"
            )

        if User.query.filter_by(
            email=email
        ).first():

            return render_template(
                "register.html",
                error="Email already registered"
            )

        otp = randint(100000, 999999)

        if not send_otp_email(email, username, otp):

            return render_template(
                "register.html",
                error="Failed to send OTP email"
            )

        # Prevent session fixation
        session.clear()

        session['temp_user'] = {

            "username": username,

            "email": email,

            "password": generate_password_hash(password),

            "otp": str(otp),

            "otp_time": datetime.utcnow().isoformat()
        }

        flash("OTP sent to email")

        return redirect(url_for("verify_otp"))

    return render_template("register.html")


# --------------------------------------------------
# VERIFY OTP ROUTE
# --------------------------------------------------

@app.route('/verify-otp', methods=['GET', 'POST'])
def verify_otp():

    temp_user = session.get("temp_user")

    if not temp_user:

        return redirect(url_for("register"))

    if request.method == "POST":

        entered_otp = request.form.get('otp')

        stored_otp = temp_user.get('otp')

        otp_time = datetime.fromisoformat(
            temp_user.get('otp_time')
        )

        # OTP expiry check
        if datetime.utcnow() - otp_time > timedelta(minutes=5):

            session.clear()

            return render_template(
                "verify_otp.html",
                error="OTP expired"
            )

        if entered_otp == stored_otp:

            new_user = User(

                username=temp_user['username'],

                email=temp_user['email'],

                password=temp_user['password']
            )

            db.session.add(new_user)

            db.session.commit()

            session.clear()

            flash("Account created successfully")

            return redirect(url_for("login"))

        else:

            return render_template(
                "verify_otp.html",
                error="Invalid OTP"
            )

    return render_template("verify_otp.html")


# --------------------------------------------------
# LOGIN ROUTE
# --------------------------------------------------

@app.route('/login', methods=['GET', 'POST'])
def login():

    if request.method == "POST":

        username = request.form.get('username')
        password = request.form.get('password')

        user = User.query.filter_by(
            username=username
        ).first()

        if user and check_password_hash(
            user.password,
            password
        ):

            # Prevent session fixation
            session.clear()

            session['user_id'] = user.id

            flash("Login successful")

            return redirect(url_for("dashboard"))

        else:

            return render_template(
                "login.html",
                error="Invalid credentials"
            )

    return render_template("login.html")


# --------------------------------------------------
# DASHBOARD ROUTE
# --------------------------------------------------

@app.route('/dashboard')
def dashboard():

    user_id = session.get("user_id")

    if not user_id:

        return redirect(url_for("login"))

    user = db.session.get(
        User,
        user_id
    )

    if not user:

        session.clear()

        return redirect(url_for("login"))

    return render_template(
        "dashboard.html",
        user=user
    )


# --------------------------------------------------
# LOGOUT ROUTE
# --------------------------------------------------

@app.route('/logout')
def logout():

    session.clear()

    flash("Logged out successfully")

    return redirect(url_for("login"))


# --------------------------------------------------
# CREATE DATABASE TABLES
# --------------------------------------------------

with app.app_context():

    db.create_all()


# --------------------------------------------------
# RUN APP
# --------------------------------------------------

if __name__ == "__main__":

    port = int(
        os.environ.get("PORT", 5000)
    )

    app.run(
        host="0.0.0.0",
        port=port,
        debug=False
    )
