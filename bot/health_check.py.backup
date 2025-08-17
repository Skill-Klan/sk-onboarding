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

def run_health_server(port=8080):
    """Run the health check HTTP server"""
    server = HTTPServer(('localhost', port), HealthCheckHandler)
    server.start_time = time.time()
    
    print(f"Health check server started on port {port}")
    print(f"Health endpoint: http://localhost:{port}/health")
    print(f"Status endpoint: http://localhost:{port}/status")
    
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down health check server...")
        server.shutdown()

if __name__ == "__main__":
    port = int(os.getenv("HEALTH_CHECK_PORT", "8081"))
    run_health_server(port)
