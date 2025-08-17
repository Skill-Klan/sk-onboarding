#!/bin/bash
echo "🔄 Безпечний rollback бота..."
SUDO_PASS="${1:-$SERVER_PASSWORD}"
if [ -z "$SUDO_PASS" ]; then echo "❌ Помилка: не вказано пароль для sudo"; exit 1; fi
cd /opt/telegram-bot
LATEST_BACKUP=$(ls -dt backup-* 2>/dev/null | head -n1)
if [ -n "$LATEST_BACKUP" ] && [ -d "$LATEST_BACKUP" ]; then
    echo "🔄 Відновлюю з backup: $LATEST_BACKUP"
    sudo systemctl stop telegram-bot || true
    sleep 5
    rm -rf bot
    cp -r "$LATEST_BACKUP" bot
    chmod +x bot/*.sh
    sudo systemctl start telegram-bot
    sleep 15
    if systemctl is-active --quiet telegram-bot; then
        echo "✅ Сервіс відновлено та працює після rollback"
    else
        echo "⚠️ Попередження: сервіс не активний після rollback"
        systemctl status telegram-bot --no-pager || true
    fi
else
    echo "❌ Backup не знайдено для rollback"
    exit 1
fi
echo "🎉 Rollback процес завершено"
