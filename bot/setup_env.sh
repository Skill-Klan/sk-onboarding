#!/bin/bash

# Скрипт для налаштування .env файлу на сервері
echo "🔧 Setting up .env file for Telegram Bot"

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

# Перевірка наявності example.env
if [ ! -f "example.env" ]; then
    echo "❌ example.env file not found"
    exit 1
fi

# Створення .env файлу з example.env
if [ ! -f ".env" ]; then
    echo "📋 Creating .env file from example.env..."
    cp example.env .env
    echo "✅ .env file created"
else
    echo "📋 .env file already exists"
fi

# Перевірка BOT_TOKEN
if grep -q '^BOT_TOKEN=""' .env || ! grep -q '^BOT_TOKEN=' .env; then
    echo "⚠️ WARNING: BOT_TOKEN not configured in .env file!"
    echo ""
    echo "📝 Please edit .env file and set your BOT_TOKEN:"
    echo "   sudo nano $BOT_DIR/.env"
    echo ""
    echo "🔑 You can get BOT_TOKEN from @BotFather on Telegram"
    echo ""
    echo "📋 Current .env content:"
    cat .env
    echo ""
    echo "❌ Bot cannot start without valid BOT_TOKEN"
    exit 1
else
    echo "✅ BOT_TOKEN configured in .env file"
fi

# Перевірка прав доступу
echo "🔐 Setting correct permissions..."
chown roman:roman .env
chmod 600 .env
echo "✅ Permissions set correctly"

echo ""
echo "🎉 .env file setup completed!"
echo "🤖 Bot should now be able to start with valid BOT_TOKEN"
echo ""
echo "📋 To restart bot service:"
echo "   sudo systemctl restart telegram-bot"
