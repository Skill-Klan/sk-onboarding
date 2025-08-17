#!/bin/bash
echo "🚀 Копіюю виправлені файли на сервер..."

# Налаштування сервера
SERVER_HOST="37.57.209.201"
SERVER_USER="roman"
SERVER_PORT="22"

echo "📁 Копіюю run_with_health_fixed.py..."
scp -P $SERVER_PORT bot/run_with_health_fixed.py $SERVER_USER@$SERVER_HOST:/opt/telegram-bot/bot/

echo "📁 Копіюю cleanup_ports.sh..."
scp -P $SERVER_PORT bot/cleanup_ports.sh $SERVER_USER@$SERVER_HOST:/opt/telegram-bot/bot/

echo "✅ Файли скопійовано на сервер!"
echo ""
echo "🔧 Тепер на сервері виконайте:"
echo "chmod +x run_with_health_fixed.py"
echo "chmod +x cleanup_ports.sh"
echo "sudo systemctl restart telegram-bot"
echo "sudo systemctl status telegram-bot"
