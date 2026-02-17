"""
WSGI Entry Point for AI CyberShield Matrix
This file is used for production deployment with Gunicorn or other WSGI servers
"""

from app import app

if __name__ == "__main__":
    app.run()
