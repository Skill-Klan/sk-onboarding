#!/usr/bin/env python3
"""
Main script to run both Telegram bot and health check server
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
    """Run main Telegram bot"""
    try:
        bot_script = Path(__file__).parent / "bot.py"
        subprocess.run([sys.executable, str(bot_script)], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Bot failed: {e}")
    except Exception as e:
        print(f"Bot error: {e}")

def main():
    print("🚀 Starting Telegram Bot with Health Check...")
    
    # Start health server in background thread
    health_thread = threading.Thread(target=run_health_server, daemon=True)
    health_thread.start()
    
    print("✅ Health check server started in background")
    print("🌐 Health endpoint: http://localhost:8080/health")
    print("📊 Status endpoint: http://localhost:8080/status")
    
    # Wait a bit for health server to initialize
    time.sleep(3)
    
    print("🤖 Starting main Telegram bot...")
    
    # Run main bot (this will block)
    run_bot()

if __name__ == "__main__":
    main()
