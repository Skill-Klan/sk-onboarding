#!/usr/bin/env python3
"""
Health check endpoint for Telegram bot
Provides a simple HTTP server to check if the bot is running
"""

import json
import os
import signal
import sys
import threading
import time
import socket
from http.server import HTTPServer, BaseHTTPRequestHandler
from datetime import datetime

class HealthCheckHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/health':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            
            # Basic health check response
            health_data = {
                "status": "healthy",
                "timestamp": datetime.now().isoformat(),
                "bot_running": True,
                "uptime": time.time() - self.server.start_time,
                "version": "1.0.0"
            }
            
            self.wfile.write(json.dumps(health_data, indent=2).encode())
            
        elif self.path == '/status':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            
            # Detailed status response
            status_data = {
                "status": "running",
                "timestamp": datetime.now().isoformat(),
                "bot_running": True,
                "uptime": time.time() - self.server.start_time,
                "environment": {
                    "python_version": sys.version,
                    "bot_token_set": bool(os.getenv("BOT_TOKEN")),
                    "local_onboarding_url": os.getenv("LOCAL_ONBOARDING_URL", "not_set"),
                    "local_faq_url": os.getenv("LOCAL_FAQ_URL", "not_set"),
                    "base_onboarding_url": os.getenv("BASE_ONBOARDING_URL", "not_set")
                }
            }
            
            self.wfile.write(json.dumps(status_data, indent=2).encode())
            
        else:
            self.send_response(404)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            self.wfile.write(b'Not Found')
    
    def log_message(self, format, *args):
        # Suppress access logs for health checks
        if '/health' not in args[0]:
            super().log_message(format, *args)

def find_free_port(start_port=8080, max_attempts=100):
    """Find a free port starting from start_port"""
    for port in range(start_port, start_port + max_attempts):
        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                s.bind(('localhost', port))
                return port
        except OSError:
            continue
    raise RuntimeError(f"Could not find free port in range {start_port}-{start_port + max_attempts}")

def run_health_server(port=None):
    """Run the health check HTTP server with automatic port finding"""
    if port is None:
        port = int(os.getenv("HEALTH_CHECK_PORT", "8081"))
    
    # Try to find free port if default is busy
    try:
        server = HTTPServer(('localhost', port), HealthCheckHandler)
        print(f"✅ Health check server started on port {port}")
    except OSError as e:
        if "Address already in use" in str(e):
            print(f"⚠️ Port {port} is busy, searching for free port...")
            port = find_free_port(port + 1)
            server = HTTPServer(('localhost', port), HealthCheckHandler)
            print(f"✅ Health check server started on free port {port}")
        else:
            raise e
    
    server.start_time = time.time()
    
    print(f"Health endpoint: http://localhost:{port}/health")
    print(f"Status endpoint: http://localhost:{port}/status")
    
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down health check server...")
        server.shutdown()

if __name__ == "__main__":
    run_health_server()
