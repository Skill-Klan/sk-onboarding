#!/bin/bash

# Скрипт для запуску Telegram бота
echo "🚀 Запуск Telegram бота..."

# Перевірка чи існує віртуальне середовище
if [ ! -d "venv" ]; then
    echo "📦 Створення віртуального середовища..."
    python3 -m venv venv
fi

# Активація віртуального середовища та встановлення залежностей
echo "📥 Встановлення залежностей..."
source venv/bin/activate
pip install -r requirements.txt

# Перевірка наявності токена
if [ -z "$(grep -o 'BOT_TOKEN="[^"]*"' .env | cut -d'"' -f2)" ]; then
    echo "⚠️  УВАГА: BOT_TOKEN не налаштований в файлі .env"
    echo "   Додайте токен вашого бота в файл .env"
    echo "   Отримати токен можна у @BotFather"
    exit 1
fi

# Запуск бота
echo "🤖 Запуск бота..."
python3 bot.py
