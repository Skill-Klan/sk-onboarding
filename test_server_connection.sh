#!/bin/bash
# Тестування різних портів для підключення до сервера
SERVER_HOST="37.57.209.201"
echo "🔍 Тестую підключення до сервера $SERVER_HOST..."

# Тестування стандартних портів
for port in 22 2222 2200 8080 8081 80 443; do
    echo -n "Порт $port: "
    if timeout 5 bash -c "</dev/tcp/$SERVER_HOST/$port" 2>/dev/null; then
        echo "✅ Відкритий"
    else
        echo "❌ Закритий"
    fi
done

# Тестування health check
echo -e "\n🏥 Тестую health check endpoints:"
for port in 8080 8081 80; do
    echo -n "HTTP $port/status: "
    if curl -s --connect-timeout 5 "http://$SERVER_HOST:$port/status" >/dev/null 2>&1; then
        echo "✅ Відповідає"
    else
        echo "❌ Не відповідає"
    fi
done
