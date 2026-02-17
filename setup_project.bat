@echo off
REM ========================================
REM AI CyberShield Matrix - Quick Setup Script
REM ========================================

echo.
echo =======================================
echo AI CyberShield Matrix - Quick Setup
echo =======================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python is not installed or not in PATH!
    echo Please install Python 3.10 or 3.11 from https://www.python.org/downloads/
    pause
    exit /b 1
)

echo [✓] Python found
echo.

REM Create .env file if it doesn't exist
if not exist .env (
    echo [INFO] Creating .env file from template...
    copy .env.example .env
    echo [!] IMPORTANT: Edit .env file and configure your Supabase and email settings!
    echo.
) else (
    echo [✓] .env file already exists
    echo.
)

REM Create virtual environment if it doesn't exist
if not exist venv (
    echo [INFO] Creating virtual environment...
    python -m venv venv
    echo [✓] Virtual environment created
    echo.
) else (
    echo [✓] Virtual environment already exists
    echo.
)

REM Activate virtual environment and install dependencies
echo [INFO] Installing dependencies...
call venv\Scripts\activate.bat
pip install --upgrade pip
pip install -r requirements.txt

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Failed to install dependencies!
    pause
    exit /b 1
)

echo.
echo [✓] Dependencies installed successfully
echo.

REM Create uploads folder if it doesn't exist
if not exist uploads (
    mkdir uploads
    echo [✓] Created uploads folder
    echo.
)

echo.
echo =======================================
echo Setup Complete!
echo =======================================
echo.
echo Next Steps:
echo 1. Edit .env file with your Supabase and Gmail credentials
echo 2. Set up Supabase database (see README.md)
echo 3. Run: python app.py
echo.
echo For full deployment guide, see DEPLOYMENT_GUIDE.md
echo.
pause
