# 🚀 Deployment Guide for MilesWeb (herosite.pro)

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Supabase Setup](#supabase-setup)
3. [Local Configuration](#local-configuration)
4. [MilesWeb Deployment](#milesweb-deployment)
5. [Post-Deployment Testing](#post-deployment-testing)
6. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before deploying, ensure you have:

- ✅ MilesWeb hosting account credentials
- ✅ FTP/SSH access to your MilesWeb server
- ✅ Supabase account (free tier works fine)
- ✅ Gmail account with App Password (if using Gmail for emails)
- ✅ Basic knowledge of terminal/command line

---

## Supabase Setup

### Step 1: Create Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign up/login
2. Click **"New Project"**
3. Fill in the following:
   - **Name**: `ai-cybershield-matrix`
   - **Database Password**: Create a strong password and **SAVE IT**
   - **Region**: Choose closest to your users
4. Click **"Create new project"** (takes ~2 minutes)

### Step 2: Get Supabase Credentials

Once the project is ready:

1. Go to **Settings** → **API** in the left sidebar
2. Note down these values (you'll need them):
   - **Project URL**: `https://xxxxxxxxxxxxx.supabase.co`
   - **anon public key**: Starts with `eyJhbGci...`
   - **service_role key**: Starts with `eyJhbGci...` (keep this secret!)

3. Go to **Settings** → **Database** in the left sidebar
4. Scroll to **Connection string** → **URI**
5. Copy the connection string: `postgresql://postgres.xxxxx:password@aws...`
6. **IMPORTANT**: Replace `[YOUR-PASSWORD]` in the string with your database password from Step 1

### Step 3: Set Up Database Schema

1. Go to **SQL Editor** in the left sidebar
2. Click **"New query"**
3. Open the `supabase_schema.sql` file from your project folder
4. Copy ALL the SQL content and paste it into the Supabase SQL Editor
5. Click **"Run"** or press `Ctrl+Enter`
6. Wait for "Success. No rows returned" message

**Verify Schema**:
1. Go to **Table Editor** in the left sidebar
2. You should see `users` and `scan_reports` tables
3. Check the `users` table - there should be 1 row (admin user)

---

## Local Configuration

### Step 1: Create Environment File

1. Navigate to your project folder:
   ```bash
   cd "c:\Users\ASUS\Downloads\Document from Shubham Kungar\AI-CyberShield-Matrix"
   ```

2. Copy the example environment file:
   ```bash
   copy .env.example .env
   ```

3. Open `.env` file in a text editor (Notepad, VS Code, etc.)

### Step 2: Configure Environment Variables

Fill in the `.env` file with your actual values:

```env
# ====================================
# FLASK CONFIGURATION
# ====================================
SECRET_KEY=<generate a random 64-character string>
FLASK_ENV=production
FLASK_DEBUG=False

# ====================================
# SUPABASE CONFIGURATION
# ====================================
# From Step 2 above
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
SUPABASE_SERVICE_KEY=your_service_role_key_here
DATABASE_URL=postgresql://postgres:your_password@db.your-project-id.supabase.co:5432/postgres

# ====================================
# EMAIL CONFIGURATION
# ====================================
# Option 1: Use Gmail (set to False)
USE_SUPABASE_AUTH=False

# Gmail settings (get App Password from https://myaccount.google.com/apppasswords)
MAIL_SERVER=smtp.gmail.com
MAIL_PORT=587
MAIL_USE_TLS=True
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your_16_char_app_password
MAIL_DEFAULT_SENDER=your-email@gmail.com
```

**Generate SECRET_KEY**:
```bash
python -c "import secrets; print(secrets.token_hex(32))"
```

### Step 3: Test Locally

1. Create virtual environment (if not exists):
   ```bash
   python -m venv venv
   ```

2. Activate virtual environment:
   ```bash
   # Windows
   venv\Scripts\activate
   
   # Linux/Mac
   source venv/bin/activate
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

4. Run the application:
   ```bash
   python app.py
   ```

5. Open browser: `http://localhost:5000`

6. **Test Registration**:
   - Go to `/register`
   - Create a test account
   - Check your email for OTP
   - Verify the OTP works

✅ If everything works locally, proceed to deployment!

---

## MilesWeb Deployment

### Deployment Method 1: Shared Hosting with cPanel (Most Common)

#### Step 1: Upload Files via FTP

1. **Connect to FTP**:
   - Use FileZilla or any FTP client
   - Host: Your MilesWeb FTP host (e.g., `ftp.yourdomain.com`)
   - Username: Your cPanel username
   - Password: Your cPanel password
   - Port: 21

2. **Upload Project Files**:
   - Navigate to `public_html` or `www` folder
   - Create a new folder for your app (e.g., `ai-cybershield`)
   - Upload ALL files from your project except:
     - `venv/` folder
     - `__pycache__/` folders
     - `.env` file (you'll create this on server)
     - `instance/` folder

#### Step 2: Set Up Python Environment on cPanel

1. **Log into cPanel**
2. Find **"Setup Python App"** or **"Python Selector"**
3. Click **"Create Application"**:
   - **Python Version**: 3.11 or 3.10
   - **Application Root**: `/home/username/ai-cybershield`
   - **Application URL**: `yourdomain.com` or subdomain
   - **Application Startup File**: `app.py`
   - **Application Entry Point**: `app`

4. Click **"Create"**

#### Step 3: Install Dependencies

1. In the Python App interface, find **"Run Pip Install"**
2. Upload your `requirements.txt` or enter manually:
   ```bash
   pip install -r requirements.txt
   ```

#### Step 4: Configure Environment Variables

**Option A - Using cPanel Environment Variables**:
1. In Python App settings, find **"Environment Variables"**
2. Add each variable from your `.env` file:
   - `SECRET_KEY`: Your generated secret
   - `DATABASE_URL`: Your Supabase connection string
   - `MAIL_USERNAME`: Your Gmail
   - `MAIL_PASSWORD`: Your App Password
   - etc.

**Option B - Upload .env File**:
1. Via FTP, upload your `.env` file to the application root
2. **IMPORTANT**: Make sure `.htaccess` prevents access to `.env`

Create `.htaccess` in your app folder:
```apache
<Files ".env">
    Order allow,deny
    Deny from all
</Files>
```

#### Step 5: Restart Application

1. In Python App settings, click **"Restart"**
2. Wait for the app to restart

### Deployment Method 2: VPS with SSH Access

#### Step 1: Connect to Server

```bash
ssh username@your-server-ip
```

#### Step 2: Upload Project

**Option A - Using Git**:
```bash
cd /var/www/html
git clone <your-repo-url> ai-cybershield
cd ai-cybershield
```

**Option B - Using SCP**:
```bash
# From your local machine
scp -r "c:\Users\ASUS\Downloads\Document from Shubham Kungar\AI-CyberShield-Matrix" username@server-ip:/var/www/html/ai-cybershield
```

#### Step 3: Set Up Python Environment

```bash
cd /var/www/html/ai-cybershield

# Install Python 3.11 if not available
sudo apt update
sudo apt install python3.11 python3.11-venv python3-pip

# Create virtual environment
python3.11 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
```

#### Step 4: Configure Environment Variables

```bash
# Create .env file
nano .env

# Paste your configuration (use right-click to paste)
# Save with Ctrl+X, then Y, then Enter
```

#### Step 5: Set Up Gunicorn Service

Create systemd service file:
```bash
sudo nano /etc/systemd/system/ai-cybershield.service
```

Paste this configuration:
```ini
[Unit]
Description=AI CyberShield Matrix
After=network.target

[Service]
User=www-data
Group=www-data
WorkingDirectory=/var/www/html/ai-cybershield
Environment="PATH=/var/www/html/ai-cybershield/venv/bin"
ExecStart=/var/www/html/ai-cybershield/venv/bin/gunicorn --bind 0.0.0.0:8000 --workers 2 --timeout 120 app:app

[Install]
WantedBy=multi-user.target
```

Enable and start the service:
```bash
sudo systemctl daemon-reload
sudo systemctl enable ai-cybershield
sudo systemctl start ai-cybershield
sudo systemctl status ai-cybershield
```

#### Step 6: Configure Nginx Reverse Proxy

```bash
sudo nano /etc/nginx/sites-available/ai-cybershield
```

Paste configuration:
```nginx
server {
    listen 80;
    server_name yourdomain.herosite.pro;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /static {
        alias /var/www/html/ai-cybershield/static;
    }

    location /uploads {
        alias /var/www/html/ai-cybershield/uploads;
    }
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/ai-cybershield /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

---

## Post-Deployment Testing

### Test 1: Application Access

1. Open browser: `https://yourdomain.herosite.pro`
2. **Expected**: Login page loads without errors

### Test 2: User Registration

1. Click **"Register"**
2. Fill in details:
   - Username: `testuser`
   - Email: Your real email
   - Password: `Test@12345`
3. Click **"Register"**
4. **Expected**: OTP is sent to your email
5. Enter OTP on verification page
6. **Expected**: User is created and redirected to login

### Test 3: Database Connection

1. Log into Supabase dashboard
2. Go to **Table Editor** → **users**
3. **Expected**: See your test user in the table

### Test 4: Login and Tools

1. Log in with test credentials
2. Go to dashboard (`/dashboard`)
3. Try **Password Analyzer**:
   - Enter password: `Test@12345`
   - Click **"Analyze"**
   - **Expected**: Results appear
4. Check **History** (`/history`)
5. **Expected**: Scan report appears

---

## Troubleshooting

### Issue 1: "ModuleNotFoundError" or Import Errors

**Solution**:
```bash
pip install -r requirements.txt --upgrade
```

### Issue 2: "Database connection failed"

**Check**:
1. Verify `DATABASE_URL` is correct in `.env`
2. Ensure database password matches
3. Check if Supabase project is paused (wake it up)
4. Test connection:
   ```bash
   python -c "from app import db; print('DB OK')"
   ```

### Issue 3: "Email sending failed"

**Gmail-specific checks**:
1. Verify App Password is correct (16 characters, no spaces)
2. Enable "Less secure app access" in Gmail settings
3. Check if Gmail blocked the sign-in attempt
4. Try sending test email:
   ```bash
   python -c "from app import mail, Message; msg = Message('Test', recipients=['you@example.com']); mail.send(msg); print('Email sent!')"
   ```

### Issue 4: "500 Internal Server Error"

**Debug steps**:
1. Check server logs:
   ```bash
   # cPanel: Go to Error Logs
   # VPS:
   sudo journalctl -u ai-cybershield -n 50
   ```

2. Enable debug mode temporarily:
   ```bash
   # In .env, change:
   FLASK_DEBUG=True
   ```

3. Restart the application

### Issue 5: "Cannot create database tables"

**Solution**:
Run the schema SQL manually in Supabase SQL Editor (see Supabase Setup Step 3)

### Issue 6: Static files not loading

**For VPS/Nginx**:
```bash
sudo chmod -R 755 /var/www/html/ai-cybershield/static
sudo systemctl restart nginx
```

**For cPanel**:
Check File Manager permissions: `static` folder should be `755`

---

## Default Admin Credentials

After successful deployment, log in with:

- **Email**: `admin@aicybershield.com`
- **Password**: `Admin@123`

**⚠️ CHANGE THIS IMMEDIATELY!**

---

## Support & Next Steps

### Secure Your Application

1. **Change admin password** immediately after first login
2. **Enable HTTPS** (SSL certificate) through MilesWeb cPanel
3. **Set strong SECRET_KEY** in production
4. **Disable debug mode**: `FLASK_DEBUG=False`

### Monitor Your Application

1. **Supabase Dashboard**: Check database usage and logs
2. **cPanel Logs** or **journalctl**: Check application errors
3. **Set up backups**: Both database (Supabase) and files (cPanel backup)

### Need Help?

- **Supabase Issues**: [https://supabase.com/docs](https://supabase.com/docs)
- **MilesWeb Support**: Contact MilesWeb technical support
- **Application Logs**: Check error logs for detailed error messages

---

## Success Checklist

- ✅ Supabase project created and schema deployed
- ✅ Environment variables configured
- ✅ Application running locally
- ✅ Files uploaded to MilesWeb
- ✅ Dependencies installed on server
- ✅ Application accessible via domain
- ✅ User registration and OTP working
- ✅ Database operations functional
- ✅ Admin password changed
- ✅ HTTPS enabled

**🎉 Congratulations! Your AI CyberShield Matrix is now live!**
