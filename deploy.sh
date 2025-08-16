#!/bin/bash

# Скрипт для деплою бота на сервер
echo "🚀 Deploy Bot to Server"

# Конфігурація
SERVER_HOST="37.57.209.201"
SERVER_USER="roman"
BOT_DIR="/opt/telegram-bot/bot"
LOCAL_BOT_DIR="./bot"

# Перевірка чи існує директорія бота
if [ ! -d "$LOCAL_BOT_DIR" ]; then
    echo "❌ Помилка: Директорія $LOCAL_BOT_DIR не знайдена"
    exit 1
fi

echo "📁 Локальна директорія: $LOCAL_BOT_DIR"
echo "🌐 Сервер: $SERVER_USER@$SERVER_HOST"
echo "📂 Віддалена директорія: $BOT_DIR"

# Синхронізація файлів
echo "📤 Синхронізація файлів..."
rsync -avz --delete \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='venv' \
    --exclude='__pycache__' \
    --exclude='*.pyc' \
    "$LOCAL_BOT_DIR/" "$SERVER_USER@$SERVER_HOST:$BOT_DIR/"

if [ $? -eq 0 ]; then
    echo "✅ Файли успішно синхронізовані"
else
    echo "❌ Помилка синхронізації"
    exit 1
fi

# Перезапуск бота
echo "🔄 Перезапуск бота..."
ssh "$SERVER_USER@$SERVER_HOST" "
    cd $BOT_DIR
    source venv/bin/activate
    pip install -r requirements.txt
    sudo systemctl restart telegram-bot
    sudo systemctl status telegram-bot --no-pager
"

if [ $? -eq 0 ]; then
    echo "✅ Бот успішно перезапущений"
else
    echo "❌ Помилка перезапуску бота"
    exit 1
fi

# Перевірка статусу
echo "🔍 Перевірка статусу..."
ssh "$SERVER_USER@$SERVER_HOST" "
    echo '📊 Статус сервісу:'
    sudo systemctl is-active telegram-bot
    echo '🌐 Тест веб-сервера:'
    curl -s http://localhost:8080 | head -c 100
    echo ''
"

echo "🎉 Деплой завершено успішно!"
echo "🤖 Бот доступний за адресою: http://$SERVER_HOST:8080"
