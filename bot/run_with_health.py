#!/usr/bin/env python3
"""
Main script to run both Telegram bot and health check server
with improved port management and process handling
"""

import os
import sys
import time
import threading
import subprocess
import signal
import socket
import psutil
from pathlib import Path

def signal_handler(signum, frame):
    """Handle shutdown signals gracefully"""
    print(f"\n🛑 Received signal {signum}, shutting down gracefully...")
    sys.exit(0)

def is_port_in_use(port):
    """Check if port is already in use"""
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.bind(('localhost', port))
            return False
    except OSError:
        return True

def kill_process_on_port(port):
    """Kill process using specified port"""
    try:
        for proc in psutil.process_iter(['pid', 'name', 'connections']):
            try:
                for conn in proc.connections():
                    if conn.laddr.port == port:
                        print(f"�� Killing process {proc.pid} ({proc.name()}) on port {port}")
                        proc.terminate()
                        proc.wait(timeout=5)
                        return True
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                continue
    except Exception as e:
        print(f"⚠️ Error killing process on port {port}: {e}")
    return False

def find_free_port(start_port=8081, max_attempts=10):
    """Find a free port starting from start_port"""
    for port in range(start_port, start_port + max_attempts):
        if not is_port_in_use(port):
            return port
    raise RuntimeError(f"Could not find free port in range {start_port}-{start_port + max_attempts}")

def run_health_server():
    """Run health check server in background with port management"""
    try:
        health_script = Path(__file__).parent / "health_check.py"
        print("🏥 Starting health check server...")
        
        # Check if default port is busy
        default_port = int(os.getenv("HEALTH_CHECK_PORT", "8081"))
        if is_port_in_use(default_port):
            print(f"⚠️ Port {default_port} is busy, attempting to free it...")
            if kill_process_on_port(default_port):
                time.sleep(2)  # Wait for process to fully terminate
        
        # Try to start on default port, fallback to free port
        try:
            env = os.environ.copy()
            env["HEALTH_CHECK_PORT"] = str(default_port)
            subprocess.run([sys.executable, str(health_script)], env=env, check=True)
        except subprocess.CalledProcessError:
            print(f"⚠️ Failed to start on port {default_port}, trying free port...")
            free_port = find_free_port(default_port + 1)
            env["HEALTH_CHECK_PORT"] = str(free_port)
            subprocess.run([sys.executable, str(health_script)], env=env, check=True)
            
    except subprocess.CalledProcessError as e:
        print(f"❌ Health server failed: {e}")
    except Exception as e:
        print(f"❌ Health server error: {e}")

def run_bot():
    """Run main Telegram bot"""
    try:
        bot_script = Path(__file__).parent / "bot.py"
        print("🤖 Starting main Telegram bot...")
        subprocess.run([sys.executable, str(bot_script)], check=True)
    except subprocess.CalledProcessError as e:
        print(f"❌ Bot failed: {e}")
    except Exception as e:
        print(f"❌ Bot error: {e}")

def main():
    print("🚀 Starting Telegram Bot with Health Check...")
    
    # Set up signal handlers for graceful shutdown
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    # Start health server in background thread
    health_thread = threading.Thread(target=run_health_server, daemon=True)
    health_thread.start()
    
    print("✅ Health check server started in background")
    
    # Wait a bit for health server to initialize
    time.sleep(5)
    
    print("🤖 Starting main Telegram bot...")
    
    # Run main bot (this will block)
    run_bot()

if __name__ == "__main__":
    main()
