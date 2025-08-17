#!/usr/bin/env python3
"""
Fixed version of run_with_health.py to resolve Event loop is closed error
"""

import os
import sys
import time
import subprocess
import signal

def signal_handler(signum, frame):
    """Handle shutdown signals gracefully"""
    print(f"\n🛑 Received signal {signum}, shutting down gracefully...")
    sys.exit(0)

def main():
    print("🚀 Starting Telegram Bot with Health Check...")
    
    # Set up signal handlers
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    # Start health server in background
    try:
        health_script = "health_check.py"
        print("🏥 Starting health check server...")
        subprocess.Popen([sys.executable, health_script], 
                        stdout=subprocess.PIPE, 
                        stderr=subprocess.PIPE)
        print("✅ Health check server started")
    except Exception as e:
        print(f"❌ Health server error: {e}")
    
    # Start main bot
    try:
        bot_script = "bot.py"
        print("🤖 Starting main Telegram bot...")
        subprocess.run([sys.executable, bot_script])
    except Exception as e:
        print(f"❌ Bot error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
