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

# Оновлення сервісу та перезапуск бота
echo "🔄 Оновлення сервісу та перезапуск бота..."
ssh "$SERVER_USER@$SERVER_HOST" "
    cd $BOT_DIR
    source venv/bin/activate
    pip install -r requirements.txt
    
    # Setup .env file with BOT_TOKEN
    if [ ! -f ".env" ]; then
        echo "📋 Creating .env file from example.env..."
        cp example.env .env
    fi
    
    # Update BOT_TOKEN in .env file
    BOT_TOKEN="8294414477:AAFRsKrEE2PqcE2kBj8o7hbsZ3re5hPold0"
    echo "✅ Updating BOT_TOKEN in .env file..."
    sed -i "s/^BOT_TOKEN=.*/BOT_TOKEN=\"$BOT_TOKEN\"/" .env
    echo "✅ BOT_TOKEN configured successfully"
    
    # Set correct permissions
    chmod 600 .env
    echo "✅ .env file permissions set correctly"
    
    # Оновлення сервісного файлу
    echo '📋 Updating service file...'
    sudo cp telegram-bot-enhanced.service /etc/systemd/system/telegram-bot.service
    sudo systemctl daemon-reload
    
    # Перезапуск сервісу
    echo '🔄 Restarting telegram-bot service...'
    sudo systemctl restart telegram-bot
    
    # Очікування стабілізації
    echo '⏳ Waiting for service to stabilize...'
    sleep 15
    
    # Перевірка статусу
    echo '🔍 Checking service status...'
    if sudo systemctl is-active --quiet telegram-bot; then
        echo '✅ Service is active'
    else
        echo '❌ Service failed to start'
        sudo systemctl status telegram-bot --no-pager
        exit 1
    fi
    
    # Health check
    echo '🏥 Performing health check...'
    sleep 5
    
    if command -v curl >/dev/null 2>&1; then
        if curl -f -s http://localhost:8081/health >/dev/null 2>&1; then
            echo '✅ Health endpoint is responding'
        else
            echo '⚠️ Health endpoint not responding'
        fi
        
        if curl -f -s http://localhost:8081/status >/dev/null 2>&1; then
            echo '✅ Status endpoint is responding'
        else
            echo '⚠️ Status endpoint not responding'
        fi
    else
        echo '⚠️ curl not available, skipping HTTP health checks'
    fi
    
    # Детальний статус
    echo '📊 Detailed service status:'
    sudo systemctl status telegram-bot --no-pager --lines=20
    
    echo '📋 Recent logs:'
    sudo journalctl -u telegram-bot -n 40 --no-pager
"

if [ $? -eq 0 ]; then
    echo "✅ Бот успішно перезапущений з health check"
else
    echo "❌ Помилка перезапуску бота"
    exit 1
fi

# Фінальна перевірка
echo "🔍 Фінальна перевірка..."
ssh "$SERVER_USER@$SERVER_HOST" "
    echo '📊 Статус сервісу:'
    sudo systemctl is-active telegram-bot
    
    echo '🌐 Health check:'
    if command -v curl >/dev/null 2>&1; then
        curl -s http://localhost:8080/health | head -c 100
        echo ''
    else
        echo 'curl not available'
    fi
    
    echo '📋 Останні логи:'
    sudo journalctl -u telegram-bot -n 20 --no-pager
"

echo "🎉 Деплой завершено успішно!"
echo "🤖 Бот доступний за адресою: http://$SERVER_HOST:8080"
echo "🏥 Health check: http://$SERVER_HOST:8080/health"
echo "📊 Status: http://$SERVER_HOST:8080/status"
