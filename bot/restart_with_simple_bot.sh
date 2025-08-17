#!/bin/bash

# Скрипт для перезапуску Telegram бота з простим ботом на requests
echo "🔧 Restarting Telegram Bot with simple requests-based bot..."

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
echo "🛑 Stopping current telegram-bot-no-ssl service..."
systemctl stop telegram-bot-no-ssl.service
systemctl disable telegram-bot-no-ssl.service

# Перевірка чи створені нові файли
if [ ! -f "bot_requests.py" ]; then
    echo "❌ Requests-based bot file not found"
    exit 1
fi

if [ ! -f "run_with_health_requests.py" ]; then
    echo "❌ Requests-based health check file not found"
    exit 1
fi

# Копіювання нового сервіс файлу
echo "📋 Installing new simple bot service file..."
cp telegram-bot-simple.service /etc/systemd/system/telegram-bot-simple.service

# Перезавантаження systemd
echo "🔄 Reloading systemd..."
systemctl daemon-reload

# Встановлення та запуск нового сервісу
echo "🚀 Starting new simple bot service..."
systemctl enable telegram-bot-simple.service
systemctl start telegram-bot-simple.service

# Перевірка статусу
echo "📊 Checking service status..."
sleep 5
systemctl status telegram-bot-simple.service

echo ""
echo "🎉 Bot restarted with simple requests-based bot!"
echo "📋 To check logs: sudo journalctl -u telegram-bot-simple.service -f"
echo "📋 To restart: sudo systemctl restart telegram-bot-simple.service"
echo "📋 To stop: sudo systemctl stop telegram-bot-simple.service"
