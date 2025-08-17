#!/bin/bash

# Скрипт для перезапуску Telegram бота з версією без SSL
echo "🔧 Restarting Telegram Bot with SSL completely disabled..."

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
echo "🛑 Stopping current telegram-bot-ssl-fixed service..."
systemctl stop telegram-bot-ssl-fixed.service
systemctl disable telegram-bot-ssl-fixed.service

# Перевірка чи створені нові файли
if [ ! -f "bot_no_ssl.py" ]; then
    echo "❌ No-SSL bot file not found"
    exit 1
fi

if [ ! -f "run_with_health_no_ssl.py" ]; then
    echo "❌ No-SSL health check file not found"
    exit 1
fi

# Копіювання нового сервіс файлу
echo "📋 Installing new no-SSL service file..."
cp telegram-bot-no-ssl.service /etc/systemd/system/telegram-bot-no-ssl.service

# Перезавантаження systemd
echo "🔄 Reloading systemd..."
systemctl daemon-reload

# Встановлення та запуск нового сервісу
echo "🚀 Starting new no-SSL service..."
systemctl enable telegram-bot-no-ssl.service
systemctl start telegram-bot-no-ssl.service

# Перевірка статусу
echo "📊 Checking service status..."
sleep 5
systemctl status telegram-bot-no-ssl.service

echo ""
echo "🎉 Bot restarted with SSL completely disabled!"
echo "📋 To check logs: sudo journalctl -u telegram-bot-no-ssl.service -f"
echo "📋 To restart: sudo systemctl restart telegram-bot-no-ssl.service"
echo "📋 To stop: sudo systemctl stop telegram-bot-no-ssl.service"
