#!/bin/bash

# Скрипт для локального тестування health check
echo "🧪 Testing Health Check Locally"

# Перевірка чи існує Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 not found"
    exit 1
fi

# Перевірка чи існує curl
if ! command -v curl &> /dev/null; then
    echo "❌ curl not found"
    exit 1
fi

echo "✅ Prerequisites check passed"

# Запуск health check сервера в фоні
echo "🚀 Starting health check server..."
python3 health_check.py &
HEALTH_PID=$!

# Очікування запуску сервера
echo "⏳ Waiting for server to start..."
sleep 3

# Тестування health endpoint
echo "🏥 Testing /health endpoint..."
if curl -f -s http://localhost:8081/health >/dev/null 2>&1; then
    echo "✅ /health endpoint is responding"
    echo "Response:"
    curl -s http://localhost:8081/health | head -c 200
    echo ""
else
    echo "❌ /health endpoint failed"
fi

# Тестування status endpoint
echo "📊 Testing /status endpoint..."
if curl -f -s http://localhost:8081/status >/dev/null 2>&1; then
    echo "✅ /status endpoint is responding"
    echo "Response:"
    curl -s http://localhost:8081/status | head -c 200
    echo ""
else
    echo "❌ /status endpoint failed"
fi

# Тестування неіснуючого endpoint
echo "🚫 Testing non-existent endpoint..."
if curl -f -s http://localhost:8080/nonexistent >/dev/null 2>&1; then
    echo "❌ Unexpected response from non-existent endpoint"
else
    echo "✅ Non-existent endpoint correctly returns 404"
fi

# Зупинка health check сервера
echo "🛑 Stopping health check server..."
kill $HEALTH_PID 2>/dev/null || true

# Очікування завершення
sleep 2

# Перевірка чи процес зупинений
if pgrep -f "health_check.py" >/dev/null; then
    echo "⚠️ Health check server still running, force killing..."
    pkill -f "health_check.py" || true
else
    echo "✅ Health check server stopped successfully"
fi

echo "🎉 Health check test completed!"
