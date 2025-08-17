#!/bin/bash
# Безпечний скрипт для перезапуску бота з очищенням портів

echo "🔄 Безпечний перезапуск бота..."

# Зупиняємо сервіс
echo "⏹️ Зупиняю telegram-bot сервіс..."
sudo systemctl stop telegram-bot

# Чекаємо завершення
sleep 5

# Перевіряємо, чи всі процеси завершилися
echo "🔍 Перевіряю процеси на порту 8081..."
if lsof -ti:8081 > /dev/null 2>&1; then
    echo "⚠️ Процеси на порту 8081 все ще активні, примусово завершую..."
    sudo lsof -ti:8081 | xargs -r sudo kill -9
    sleep 2
fi

# Очищаємо тимчасові файли
echo "🧹 Очищаю тимчасові файли..."
sudo rm -f /tmp/bot-logs.txt /tmp/deployment-status.txt

# Перезапускаємо сервіс
echo "▶️ Перезапускаю telegram-bot сервіс..."
sudo systemctl start telegram-bot

# Чекаємо ініціалізації
echo "⏳ Чекаю ініціалізації сервісу..."
sleep 10

# Перевіряємо статус
echo "📊 Перевіряю статус сервісу..."
sudo systemctl status telegram-bot --no-pager --lines=10

# Перевіряємо health check
echo "🏥 Перевіряю health check..."
if curl -s http://localhost:8081/health > /dev/null; then
    echo "✅ Health check успішний"
else
    echo "❌ Health check не відповідає"
fi

echo "🎉 Перезапуск завершено!"
