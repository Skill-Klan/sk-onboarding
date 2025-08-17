#!/bin/bash

# Скрипт для оновлення сервісу Telegram бота з health check
echo "🔄 Updating Telegram Bot Service with Health Check..."

# Перевірка чи запущений як root
if [ "$EUID" -ne 0 ]; then
    echo "❌ This script must be run as root (use sudo)"
    exit 1
fi

# Шлях до директорії бота
BOT_DIR="/opt/telegram-bot/bot"
SERVICE_NAME="telegram-bot"

echo "📁 Bot directory: $BOT_DIR"
echo "🔧 Service name: $SERVICE_NAME"

# Перевірка чи існує директорія бота
if [ ! -d "$BOT_DIR" ]; then
    echo "❌ Bot directory not found: $BOT_DIR"
    exit 1
fi

# Зупинка поточного сервісу
echo "🛑 Stopping current service..."
systemctl stop "$SERVICE_NAME" || true

# Очікування завершення процесів
echo "⏳ Waiting for processes to stop..."
sleep 5

# Перевірка чи всі процеси зупинені
if pgrep -f "bot.py\|health_check.py" > /dev/null; then
    echo "⚠️ Some bot processes still running, force killing..."
    pkill -f "bot.py\|health_check.py" || true
    sleep 2
fi

# Копіювання нового сервісного файлу
echo "📋 Installing new service file..."
cp "$BOT_DIR/telegram-bot-enhanced.service" "/etc/systemd/system/$SERVICE_NAME.service"

# Перезавантаження systemd
echo "🔄 Reloading systemd..."
systemctl daemon-reload

# Встановлення залежностей
echo "📦 Installing dependencies..."
cd "$BOT_DIR"
if [ -f "requirements.txt" ]; then
    source venv/bin/activate
    pip install -r requirements.txt
    echo "✅ Python dependencies installed"
else
    echo "⚠️ No requirements.txt found"
fi

# Запуск сервісу
echo "🚀 Starting service..."
systemctl start "$SERVICE_NAME"

# Очікування запуску
echo "⏳ Waiting for service to start..."
sleep 10

# Перевірка статусу
echo "🔍 Checking service status..."
if systemctl is-active --quiet "$SERVICE_NAME"; then
    echo "✅ Service is active"
else
    echo "❌ Service failed to start"
    systemctl status "$SERVICE_NAME" --no-pager
    echo "📋 Recent logs:"
    journalctl -u "$SERVICE_NAME" -n 20 --no-pager
    exit 1
fi

# Health check
echo "🏥 Performing health check..."
sleep 5

if command -v curl >/dev/null 2>&1; then
    if curl -f -s http://localhost:8081/health >/dev/null 2>&1; then
        echo "✅ Health endpoint is responding"
    else
        echo "⚠️ Health endpoint not responding"
    fi
    
    if curl -f -s http://localhost:8081/status >/dev/null 2>&1; then
        echo "✅ Status endpoint is responding"
    else
        echo "⚠️ Status endpoint not responding"
    fi
else
    echo "⚠️ curl not available, skipping HTTP health checks"
fi

# Включення автозапуску
echo "🔧 Enabling service autostart..."
systemctl enable "$SERVICE_NAME"

# Фінальна перевірка
echo "📊 Final service status:"
systemctl status "$SERVICE_NAME" --no-pager --lines=10

echo "🎉 Service update completed successfully!"
echo "🤖 Bot is running with health check endpoints:"
echo "   Health: http://localhost:8080/health"
echo "   Status: http://localhost:8080/status"
