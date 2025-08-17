#!/usr/bin/env python3
"""
Main script to run both Simple Telegram Bot (with requests) and health check server
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
    """Run simple Telegram bot with requests"""
    try:
        # Use the requests-based bot
        bot_script = Path(__file__).parent / "bot_requests.py"
        if bot_script.exists():
            print("🔧 Using requests-based bot...")
            subprocess.run([sys.executable, str(bot_script)], check=True)
        else:
            # Fallback to other versions
            print("⚠️ Requests-based bot not found, trying other versions...")
            bot_script = Path(__file__).parent / "bot_no_ssl.py"
            if bot_script.exists():
                subprocess.run([sys.executable, str(bot_script)], check=True)
            else:
                bot_script = Path(__file__).parent / "bot_ssl_fixed.py"
                if bot_script.exists():
                    subprocess.run([sys.executable, str(bot_script)], check=True)
                else:
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
    print("🚀 Starting Simple Telegram Bot with Health Check...")
    
    # Start health server in background thread
    health_thread = threading.Thread(target=run_health_server, daemon=True)
    health_thread.start()
    
    print("✅ Health check server started in background")
    print("🌐 Health endpoint: http://localhost:8080/health")
    print("📊 Status endpoint: http://localhost:8080/status")
    
    # Wait a bit for health server to initialize
    time.sleep(3)
    
    print("🤖 Starting simple Telegram bot with requests...")
    
    # Run main bot (this will block)
    run_bot()

if __name__ == "__main__":
    main()
