#!/bin/bash
# Скрипт для очищення портів та зайвих процесів перед запуском бота

echo "🧹 Очищення портів та зайвих процесів..."

# Зупиняємо всі зайві Python процеси
echo "🔄 Зупиняю зайві Python процеси..."
pkill -f "run_with_health_requests.py" || true
pkill -f "health_check.py" || true
pkill -f "bot_requests.py" || true
pkill -f "simple_server.py" || true
pkill -f "run_with_health.py" || true

# Чекаємо завершення
sleep 3

# Перевіряємо та очищаємо порт 8081
if lsof -ti:8081 > /dev/null 2>&1; then
    echo "⚠️ Порт 8081 зайнятий, очищаю..."
    sudo lsof -ti:8081 | xargs -r sudo kill -9
    sleep 2
fi

# Перевіряємо інші можливі порти
for port in 8080 8082 8083; do
    if lsof -ti:$port > /dev/null 2>&1; then
        echo "⚠️ Порт $port зайнятий, очищаю..."
        sudo lsof -ti:$port | xargs -r sudo kill -9
        sleep 1
    fi
done

# Перевіряємо, чи всі процеси завершилися
echo "🔍 Перевіряю, чи всі процеси завершилися..."
if pgrep -f "run_with_health\|health_check\|bot_requests\|simple_server" > /dev/null; then
    echo "⚠️ Деякі процеси все ще активні, примусово завершую..."
    pgrep -f "run_with_health\|health_check\|bot_requests\|simple_server" | xargs -r sudo kill -9
    sleep 2
fi

echo "✅ Очищення завершено"
