#!/usr/bin/env python3
"""
Fixed version of run_with_health.py to resolve Event loop is closed error
"""

import os
import sys
import time
import threading
import subprocess
import signal
import asyncio
from pathlib import Path

def signal_handler(signum, frame):
    """Handle shutdown signals gracefully"""
    print(f"\n🛑 Received signal {signum}, shutting down gracefully...")
    sys.exit(0)

def run_health_server():
    """Run health check server in background"""
    try:
        health_script = Path(__file__).parent / "health_check.py"
        print("🏥 Starting health check server...")
        # Run health server without check=True to avoid blocking
        subprocess.Popen([sys.executable, str(health_script)], 
                        stdout=subprocess.PIPE, 
                        stderr=subprocess.PIPE)
        print("✅ Health check server started")
    except Exception as e:
        print(f"❌ Health server error: {e}")

def run_bot():
    """Run main Telegram bot"""
    try:
        bot_script = Path(__file__).parent / "bot.py"
        print("🤖 Starting main Telegram bot...")
        # Run bot with proper error handling
        result = subprocess.run([sys.executable, str(bot_script)], 
                              capture_output=True, 
                              text=True)
        if result.returncode != 0:
            print(f"❌ Bot failed with return code {result.returncode}")
            print(f"Bot stdout: {result.stdout}")
            print(f"Bot stderr: {result.stderr}")
        else:
            print("✅ Bot completed successfully")
    except Exception as e:
        print(f"❌ Bot error: {e}")

def main():
    print("🚀 Starting Telegram Bot with Health Check (Fixed Version)...")
    
    # Set up signal handlers for graceful shutdown
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    # Start health server in background thread
    health_thread = threading.Thread(target=run_health_server, daemon=True)
    health_thread.start()
    
    print("✅ Health check server started in background")
    print("🌐 Health endpoint: http://localhost:8081/health")
    print("📊 Status endpoint: http://localhost:8081/status")
    
    # Wait a bit for health server to initialize
    time.sleep(3)
    
    print("🤖 Starting main Telegram bot...")
    
    # Run main bot (this will block)
    run_bot()

if __name__ == "__main__":
    main()
