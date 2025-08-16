#!/usr/bin/env python3
"""
Простий веб-сервер для тестування доступності
"""

import http.server
import socketserver
import os

PORT = 8080

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        super().end_headers()

    def do_GET(self):
        if self.path == '/':
            self.path = '/index.html'
        return super().do_GET()

if __name__ == "__main__":
    # Змінюємо директорію на корінь проекту
    os.chdir('/opt/telegram-bot/app/dist')
    
    with socketserver.TCPServer(("", PORT), MyHTTPRequestHandler) as httpd:
        print(f"🚀 Веб-сервер запущений на порту {PORT}")
        print(f"🌐 Доступний за адресою: http://localhost:{PORT}")
        print(f"🌍 Публічна адреса: http://37.57.209.201:{PORT}")
        print("⏹️  Для зупинки натисніть Ctrl+C")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n�� Сервер зупинено")
