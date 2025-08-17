#!/bin/bash
# Скрипт для очищення зайнятих портів перед запуском бота

echo "🧹 Очищення зайнятих портів..."

# Знаходимо процеси, що використовують порт 8081
PORT=8081
PID=$(lsof -ti:$PORT 2>/dev/null)

if [ -n "$PID" ]; then
    echo "⚠️ Знайдено процес $PID на порту $PORT"
    echo "🔄 Завершую процес..."
    kill -TERM $PID 2>/dev/null
    
    # Чекаємо завершення
    sleep 3
    
    # Якщо процес не завершився, примусово завершуємо
    if kill -0 $PID 2>/dev/null; then
        echo "🔄 Примусово завершую процес..."
        kill -KILL $PID 2>/dev/null
        sleep 1
    fi
    
    echo "✅ Порт $PORT звільнено"
else
    echo "✅ Порт $PORT вільний"
fi

# Перевіряємо, чи є інші процеси бота
BOT_PIDS=$(pgrep -f "bot.py\|health_check.py" 2>/dev/null)
if [ -n "$BOT_PIDS" ]; then
    echo "⚠️ Знайдено процеси бота: $BOT_PIDS"
    echo "🔄 Завершую процеси..."
    kill -TERM $BOT_PIDS 2>/dev/null
    sleep 3
    
    # Примусово завершуємо, якщо потрібно
    for pid in $BOT_PIDS; do
        if kill -0 $pid 2>/dev/null; then
            echo "🔄 Примусово завершую процес $pid..."
            kill -KILL $pid 2>/dev/null
        fi
    done
    
    echo "✅ Всі процеси бота завершено"
fi

echo "🧹 Очищення завершено"
