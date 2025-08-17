#!/bin/bash
# Скрипт для очищення портів та зайвих процесів перед запуском бота

echo "🧹 Очищення портів та зайвих процесів..."

# Додаємо базові шляхи
export PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Зупиняємо всі зайві Python процеси
echo "🔄 Зупиняю зайві Python процеси..."
/usr/bin/pkill -f "run_with_health_requests.py" || true
/usr/bin/pkill -f "health_check.py" || true
/usr/bin/pkill -f "bot_requests.py" || true
/usr/bin/pkill -f "simple_server.py" || true
/usr/bin/pkill -f "run_with_health.py" || true

# Чекаємо завершення
/usr/bin/sleep 3

# Перевіряємо та очищаємо порт 8081
if /usr/bin/lsof -ti:8081 > /dev/null 2>&1; then
    echo "⚠️ Порт 8081 зайнятий, очищаю..."
    sudo /usr/bin/lsof -ti:8081 | xargs -r sudo /usr/bin/kill -9
    /usr/bin/sleep 2
fi

# Перевіряємо інші можливі порти
for port in 8080 8082 8083; do
    if /usr/bin/lsof -ti:$port > /dev/null 2>&1; then
        echo "⚠️ Порт $port зайнятий, очищаю..."
        sudo /usr/bin/lsof -ti:$port | xargs -r sudo /usr/bin/kill -9
        /usr/bin/sleep 1
    fi
done

# Перевіряємо, чи всі процеси завершилися
echo "🔍 Перевіряю, чи всі процеси завершилися..."
if /usr/bin/pgrep -f "run_with_health\|health_check\|bot_requests\|simple_server" > /dev/null; then
    echo "⚠️ Деякі процеси все ще активні, примусово завершую..."
    /usr/bin/pgrep -f "run_with_health\|health_check\|bot_requests\|simple_server" | xargs -r sudo /usr/bin/kill -9
    /usr/bin/sleep 2
fi

echo "✅ Очищення завершено"
