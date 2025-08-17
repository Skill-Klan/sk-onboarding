#!/bin/bash
echo "🧹 Очищення портів перед запуском бота..."
if lsof -ti:8081 > /dev/null 2>&1; then
    echo "⚠️ Порт 8081 зайнятий, очищаю..."
    sudo lsof -ti:8081 | xargs -r sudo kill -9
    sleep 2
fi
echo "✅ Очищення портів завершено"
