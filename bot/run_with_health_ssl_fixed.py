#!/usr/bin/env python3
"""
Main script to run both Telegram bot and health check server with SSL fixes
"""

import os
import sys
import time
import threading
import subprocess
from pathlib import Path

def run_health_server():
    """Run health check server in background"""
    try:
        health_script = Path(__file__).parent / "health_check.py"
        subprocess.run([sys.executable, str(health_script)], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Health server failed: {e}")
    except Exception as e:
        print(f"Health server error: {e}")

def run_bot():
    """Run main Telegram bot with SSL fixes"""
    try:
        # Try the SSL-fixed version first
        bot_script = Path(__file__).parent / "bot_ssl_fixed.py"
        if bot_script.exists():
            print("🔧 Using SSL-fixed bot version...")
            subprocess.run([sys.executable, str(bot_script)], check=True)
        else:
            # Fallback to original bot
            print("⚠️ SSL-fixed version not found, using original bot...")
            bot_script = Path(__file__).parent / "bot.py"
            subprocess.run([sys.executable, str(bot_script)], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Bot failed: {e}")
        print("🔧 Trying to restart bot in 10 seconds...")
        time.sleep(10)
        run_bot()  # Recursive restart
    except Exception as e:
        print(f"Bot error: {e}")
        print("🔧 Trying to restart bot in 10 seconds...")
        time.sleep(10)
        run_bot()  # Recursive restart

def main():
    print("🚀 Starting Telegram Bot with Health Check and SSL fixes...")
    
    # Start health server in background thread
    health_thread = threading.Thread(target=run_health_server, daemon=True)
    health_thread.start()
    
    print("✅ Health check server started in background")
    print("🌐 Health endpoint: http://localhost:8080/health")
    print("📊 Status endpoint: http://localhost:8080/status")
    
    # Wait a bit for health server to initialize
    time.sleep(3)
    
    print("🤖 Starting main Telegram bot with SSL fixes...")
    
    # Run main bot (this will block)
    run_bot()

if __name__ == "__main__":
    main()
