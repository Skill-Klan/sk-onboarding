#!/bin/bash
# Безпечний скрипт для перезапуску бота з очищенням портів

echo "🔄 Безпечний перезапуск бота..."

# Додаємо базові шляхи
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Зупиняємо сервіс
echo "⏹️ Зупиняю telegram-bot сервіс..."
sudo systemctl stop telegram-bot

# Чекаємо завершення
/usr/bin/sleep 5

# Очищаємо зайві процеси
echo "🧹 Очищаю зайві процеси..."
/usr/bin/pkill -f "run_with_health_requests.py" || true
/usr/bin/pkill -f "health_check.py" || true
/usr/bin/pkill -f "bot_requests.py" || true
/usr/bin/pkill -f "simple_server.py" || true
/usr/bin/pkill -f "run_with_health.py" || true

# Перевіряємо, чи всі процеси завершилися
if /usr/bin/pgrep -f "run_with_health\|health_check\|bot_requests\|simple_server" > /dev/null; then
    echo "⚠️ Деякі процеси все ще активні, примусово завершую..."
    /usr/bin/pgrep -f "run_with_health\|health_check\|bot_requests\|simple_server" | xargs -r sudo /usr/bin/kill -9
    /usr/bin/sleep 2
fi

# Перевіряємо порт 8081
echo "🔍 Перевіряю процеси на порту 8081..."
if /usr/bin/lsof -ti:8081 > /dev/null 2>&1; then
    echo "⚠️ Процеси на порту 8081 все ще активні, примусово завершую..."
    sudo /usr/bin/lsof -ti:8081 | xargs -r sudo /usr/bin/kill -9
    /usr/bin/sleep 2
fi

# Очищаємо тимчасові файли
echo "🧹 Очищаю тимчасові файли..."
sudo rm -f /tmp/bot-logs.txt /tmp/deployment-status.txt

# Перезапускаємо сервіс
echo "▶️ Перезапускаю telegram-bot сервіс..."
sudo systemctl start telegram-bot

# Чекаємо ініціалізації
echo "⏳ Чекаю ініціалізації сервісу..."
/usr/bin/sleep 15

# Перевіряємо статус
echo "📊 Перевіряю статус сервісу..."
sudo systemctl status telegram-bot --no-pager --lines=10

# Перевіряємо health check
echo "🏥 Перевіряю health check..."
if /usr/bin/curl -s http://localhost:8081/health > /dev/null; then
    echo "✅ Health check успішний"
else
    echo "❌ Health check не відповідає"
fi

echo "🎉 Перезапуск завершено!"
