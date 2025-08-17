#!/bin/bash
# Безпечний скрипт для перевірки статусу бота на сервері
SERVER_HOST="37.57.209.201"
SERVER_USER="roman"
SSH_KEY="~/.ssh/github_deploy"

echo "🔍 Перевіряю статус бота на сервері..."

# Перевірка SSH підключення
if ssh -i "$SSH_KEY" -o ConnectTimeout=10 -o BatchMode=yes "$SERVER_USER@$SERVER_HOST" "echo SSH connection successful"; then
    echo "✅ SSH підключення успішне"
    
    # Перевірка статусу сервісу
    echo "📊 Перевіряю статус сервісу telegram-bot..."
    ssh -i "$SSH_KEY" "$SERVER_USER@$SERVER_HOST" "sudo systemctl status telegram-bot --no-pager --lines=10"
    
    # Перевірка версії коду
    echo "📝 Перевіряю версію коду на сервері..."
    ssh -i "$SSH_KEY" "$SERVER_USER@$SERVER_HOST" "cd /opt/telegram-bot/bot && git log --oneline -3"
    
    # Перевірка health check
    echo "🏥 Перевіряю health check..."
    ssh -i "$SSH_KEY" "$SERVER_USER@$SERVER_HOST" "curl -s http://localhost:8081/status | head -20"
    
else
    echo "❌ Помилка SSH підключення"
    exit 1
fi
