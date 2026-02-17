#!/bin/bash
# ========================================
# AI CyberShield Matrix - Quick Setup Script (Linux/Mac)
# ========================================

echo ""
echo "======================================="
echo "AI CyberShield Matrix - Quick Setup"
echo "======================================="
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "[ERROR] Python 3 is not installed!"
    echo "Please install Python 3.10 or 3.11"
    exit 1
fi

echo "[✓] Python found: $(python3 --version)"
echo ""

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "[INFO] Creating .env file from template..."
    cp .env.example .env
    echo "[!] IMPORTANT: Edit .env file and configure your Supabase and email settings!"
    echo ""
else
    echo "[✓] .env file already exists"
    echo ""
fi

# Create virtual environment if it doesn't exist
if [ ! -d venv ]; then
    echo "[INFO] Creating virtual environment..."
    python3 -m venv venv
    echo "[✓] Virtual environment created"
    echo ""
else
    echo "[✓] Virtual environment already exists"
    echo ""
fi

# Activate virtual environment and install dependencies
echo "[INFO] Installing dependencies..."
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

if [ $? -ne 0 ]; then
    echo ""
    echo "[ERROR] Failed to install dependencies!"
    exit 1
fi

echo ""
echo "[✓] Dependencies installed successfully"
echo ""

# Create uploads folder if it doesn't exist
if [ ! -d uploads ]; then
    mkdir -p uploads
    echo "[✓] Created uploads folder"
    echo ""
fi

echo ""
echo "======================================="
echo "Setup Complete!"
echo "======================================="
echo ""
echo "Next Steps:"
echo "1. Edit .env file with your Supabase and Gmail credentials"
echo "2. Set up Supabase database (see README.md)"
echo "3. Run: source venv/bin/activate && python app.py"
echo ""
echo "For full deployment guide, see DEPLOYMENT_GUIDE.md"
echo ""
