#!/bin/bash
echo "🚀 Деплой бота без кешу..."

# Очищаємо кеш перед деплоєм
echo "🧹 Очищаю кеш..."
./cleanup_cache.sh

# Зупиняємо сервіс
echo "⏹️ Зупиняю сервіс..."
sudo systemctl stop telegram-bot

# Копіюємо новий сервіс без SSL
echo "📋 Копіюю сервіс без SSL..."
sudo cp telegram-bot-no-ssl.service /etc/systemd/system/telegram-bot.service

# Перезавантажуємо systemd
echo "🔄 Перезавантажую systemd..."
sudo systemctl daemon-reload

# Запускаємо новий сервіс
echo "🚀 Запускаю новий сервіс без SSL..."
sudo systemctl start telegram-bot

# Перевіряємо статус
echo "📊 Перевіряю статус..."
sleep 5
sudo systemctl status telegram-bot --no-pager --lines=20

echo "✅ Деплой завершено!"
echo "🌐 Health check: http://localhost:8081/health"
echo "📊 Status: http://localhost:8081/status"
