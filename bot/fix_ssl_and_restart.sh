#!/bin/bash

# Скрипт для виправлення SSL проблем та перезапуску Telegram бота
echo "🔧 Fixing SSL issues and restarting Telegram Bot..."

# Перевірка чи запущений як root
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root (use sudo)"
    exit 1
fi

# Шлях до директорії бота
BOT_DIR="/opt/telegram-bot/bot"

echo "📁 Bot directory: $BOT_DIR"

# Перевірка чи існує директорія бота
if [ ! -d "$BOT_DIR" ]; then
    echo "❌ Bot directory not found: $BOT_DIR"
    exit 1
fi

cd "$BOT_DIR"

# Зупинка поточного сервісу
echo "🛑 Stopping current telegram-bot service..."
systemctl stop telegram-bot.service
systemctl disable telegram-bot.service

# Встановлення нових залежностей
echo "📦 Installing new dependencies..."
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# Перевірка чи створені нові файли
if [ ! -f "bot_ssl_fixed.py" ]; then
    echo "❌ SSL-fixed bot file not found"
    exit 1
fi

if [ ! -f "run_with_health_ssl_fixed.py" ]; then
    echo "❌ SSL-fixed health check file not found"
    exit 1
fi

# Копіювання нового сервіс файлу
echo "📋 Installing new service file..."
cp telegram-bot-ssl-fixed.service /etc/systemd/system/telegram-bot-ssl-fixed.service

# Перезавантаження systemd
echo "🔄 Reloading systemd..."
systemctl daemon-reload

# Встановлення та запуск нового сервісу
echo "🚀 Starting new SSL-fixed service..."
systemctl enable telegram-bot-ssl-fixed.service
systemctl start telegram-bot-ssl-fixed.service

# Перевірка статусу
echo "📊 Checking service status..."
sleep 5
systemctl status telegram-bot-ssl-fixed.service

echo ""
echo "🎉 SSL fixes applied and bot restarted!"
echo "📋 To check logs: sudo journalctl -u telegram-bot-ssl-fixed.service -f"
echo "📋 To restart: sudo systemctl restart telegram-bot-ssl-fixed.service"
echo "📋 To stop: sudo systemctl stop telegram-bot-ssl-fixed.service"
