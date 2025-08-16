#!/bin/bash

echo "🔍 Діагностика мережевих налаштувань..."
echo "=================================="

echo "📡 Локальна IP адреса:"
hostname -I

echo -e "\n🌍 Публічна IP адреса:"
curl -s ifconfig.me

echo -e "\n🔒 Статус брандмауера:"
sudo ufw status

echo -e "\n📡 Відкриті порти:"
sudo netstat -tlnp | grep -E ":(80|8080|3000)"

echo -e "\n🌐 Тест локального доступу:"
echo "Порт 80 (nginx):"
curl -s -o /dev/null -w "HTTP код: %{http_code}\n" http://localhost

echo -e "Порт 8080 (Python сервер):"
curl -s -o /dev/null -w "HTTP код: %{http_code}\n" http://localhost:8080

echo -e "\n🌍 Тест публічного доступу:"
echo "Порт 80:"
timeout 5 curl -s -o /dev/null -w "HTTP код: %{http_code}\n" http://37.57.209.201 || echo "Таймаут"

echo -e "Порт 8080:"
timeout 5 curl -s -o /dev/null -w "HTTP код: %{http_code}\n" http://37.57.209.201:8080 || echo "Таймаут"

echo -e "\n📋 Статус сервісів:"
echo "Nginx:"
sudo systemctl is-active nginx

echo -e "Telegram Web:"
sudo systemctl is-active telegram-web

echo -e "\n✅ Діагностика завершена!"
