# AI CyberShield Matrix - Supabase Migration

## 🎯 Quick Start Guide

### Prerequisites
- Python 3.10 or 3.11 installed
- Supabase account (free tier works)
- Gmail account with App Password

### Step 1: Set Up Supabase Database

1. **Create Supabase Project** at [supabase.com](https://supabase.com)
2. **Run Database Schema**:
   - Go to SQL Editor in Supabase dashboard
   - Copy content from `supabase_schema.sql`
   - Paste and run it

3. **Get Connection Details**:
   - Settings → API → Copy Project URL and API keys
   - Settings → Database → Copy Connection String

### Step 2: Configure Environment Variables

1. **Create `.env` file** (copy from `.env.example`):
   ```bash
   copy .env.example .env
   ```

2. **Fill in your credentials**:
   ```env
   SECRET_KEY=<generate with: python -c "import secrets; print(secrets.token_hex(32))">
   DATABASE_URL=<your Supabase connection string from Step 1>
   
   # Email Settings (using Gmail)
   USE_SUPABASE_AUTH=False
   MAIL_USERNAME=your-email@gmail.com
   MAIL_PASSWORD=<your Gmail App Password>
   MAIL_DEFAULT_SENDER=your-email@gmail.com
   ```

### Step 3: Install Dependencies

```bash
# Create virtual environment
python -m venv venv

# Activate it
venv\Scripts\activate  # Windows
# source venv/bin/activate  # Linux/Mac

# Install requirements
pip install -r requirements.txt
```

### Step 4: Run the Application

```bash
python app.py
```

Visit: `http://localhost:5000`

### Step 5: Test Registration

1. Go to `/register`
2. Create a test account
3. Check email for OTP
4. Enter OTP to complete registration

✅ **Success!** You're now using Supabase PostgreSQL instead of SQLite.

---

## 📁 What Changed?

### New Files
- `.env.example` - Environment variables template
- `.env` - Your actual configuration (not in git)
- `.gitignore` - Protects sensitive files
- `supabase_schema.sql` - Database schema for Supabase
- `wsgi.py` - Production deployment entry point
- `Procfile` - Gunicorn configuration
- `runtime.txt` - Python version specification
- `DEPLOYMENT_GUIDE.md` - Full deployment instructions

### Modified Files
- `app.py` - Now uses environment variables and supports Supabase
- `requirements.txt` - Added `psycopg2-binary` and `python-dotenv`

---

## 🔧 Configuration Options

### Email: Supabase Auth vs Gmail SMTP

**Option 1: Gmail SMTP** (Recommended for now)
```env
USE_SUPABASE_AUTH=False
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=<App Password>
```

**How to get Gmail App Password**:
1. Go to [myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords)
2. Select "Mail" and "Other device"
3. Copy the 16-character password

**Option 2: Supabase Auth** (Future enhancement)
```env
USE_SUPABASE_AUTH=True
```
*Note: Not yet implemented. Will use Supabase's built-in email service.*

---

## 🚀 Next Steps

### For Local Development
You're all set! Just use:
```bash
python app.py
```

### For Production Deployment
See `DEPLOYMENT_GUIDE.md` for detailed instructions on deploying to:
- MilesWeb shared hosting (cPanel)
- VPS with Nginx
- Cloud platforms (Render, Railway, etc.)

---

## 🐛 Troubleshooting

### "Database connection failed"
- ✅ Check `DATABASE_URL` in `.env`
- ✅ Verify Supabase project is active (not paused)
- ✅ Ensure password in connection string is correct

### "Email sending failed"
- ✅ Verify Gmail App Password is correct
- ✅ Check `MAIL_USERNAME` and `MAIL_PASSWORD` in `.env`
- ✅ Ensure 2FA is enabled on Gmail account
- ✅ Check spam folder if OTP doesn't arrive

### "No module named 'dotenv'"
```bash
pip install python-dotenv
```

### "ModuleNotFoundError: No module named 'psycopg2'"
```bash
pip install psycopg2-binary
```

---

## 📊 Default Admin Account

**Email**: `admin@aicybershield.com`  
**Password**: `Admin@123`

**⚠️ IMPORTANT**: Change this password immediately after first login!

---

## 🔐 Security Checklist

- ✅ Never commit `.env` file to git
- ✅ Use strong `SECRET_KEY` in production
- ✅ Change default admin password
- ✅ Keep `SUPABASE_SERVICE_KEY` secret
- ✅ Use HTTPS in production
- ✅ Set `FLASK_DEBUG=False` in production

---

## 📞 Support

For deployment assistance, see `DEPLOYMENT_GUIDE.md` or check application logs:

```bash
# Check if database connection works
python -c "from app import db; print('✅ Database OK')"

# Check if email works (replace with your email)
python -c "from app import mail, Message; msg = Message('Test', recipients=['you@example.com']); mail.send(msg); print('✅ Email OK')"
```

---

**🎉 You're ready to deploy!** Follow `DEPLOYMENT_GUIDE.md` for MilesWeb deployment steps.
