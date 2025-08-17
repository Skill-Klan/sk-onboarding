#!/bin/bash
echo "🔧 Виправляю sudo на сервері..."

# Додати правило в sudoers
SUDOERS_RULE="roman ALL=(ALL) NOPASSWD: /bin/mkdir, /bin/chown, /bin/cp, /bin/rm, /bin/systemctl, /bin/kill, /bin/lsof, /bin/pkill, /bin/pgrep"

# Перевірити, чи правило вже існує
if ! sudo grep -q "roman ALL=(ALL) NOPASSWD:" /etc/sudoers; then
    echo "$SUDOERS_RULE" | sudo tee -a /etc/sudoers
    echo "✅ sudo правило додано"
else
    echo "ℹ️ Правило вже існує"
fi

# Перевірити синтаксис
if sudo visudo -c; then
    echo "✅ Синтаксис sudoers правильний"
else
    echo "❌ Помилка в синтаксисі sudoers"
    exit 1
fi

echo "🎉 Налаштування sudo завершено!"

