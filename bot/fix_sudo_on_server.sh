#!/bin/bash
# Скрипт для виправлення sudo на сервері

echo "🔧 Виправляю sudo на сервері..."

# Крок 1: Виправляю права доступу до telegram-bot файлу
echo "📋 Виправляю права доступу..."
if [ -f /etc/sudoers.d/telegram-bot ]; then
    sudo chmod 0440 /etc/sudoers.d/telegram-bot
    echo "✅ Права доступу виправлено для /etc/sudoers.d/telegram-bot"
else
    echo "ℹ️ Файл /etc/sudoers.d/telegram-bot не знайдено"
fi

# Крок 2: Перевіряю поточні шляхи до команд
echo "🔍 Перевіряю шляхи до команд..."
MKDIR_PATH=$(which mkdir)
CHOWN_PATH=$(which chown)
CP_PATH=$(which cp)
RM_PATH=$(which rm)
SYSTEMCTL_PATH=$(which systemctl)
KILL_PATH=$(which kill)
LSOF_PATH=$(which lsof)
PKILL_PATH=$(which pkill)
PGREP_PATH=$(which pgrep)

echo "📁 Шляхи до команд:"
echo "  mkdir: $MKDIR_PATH"
echo "  chown: $CHOWN_PATH"
echo "  cp: $CP_PATH"
echo "  rm: $RM_PATH"
echo "  systemctl: $SYSTEMCTL_PATH"
echo "  kill: $KILL_PATH"
echo "  lsof: $LSOF_PATH"
echo "  pkill: $PKILL_PATH"
echo "  pgrep: $PGREP_PATH"

# Крок 3: Додаю sudo правило в основний sudoers
echo "➕ Додаю sudo правило..."
SUDOERS_RULE="roman ALL=(ALL) NOPASSWD: $MKDIR_PATH, $CHOWN_PATH, $CP_PATH, $RM_PATH, $SYSTEMCTL_PATH, $KILL_PATH, $LSOF_PATH, $PKILL_PATH, $PGREP_PATH"

# Перевіряю, чи правило вже існує
if ! sudo grep -q "roman ALL=(ALL) NOPASSWD:" /etc/sudoers; then
    echo "$SUDOERS_RULE" | sudo tee -a /etc/sudoers
    echo "✅ sudo правило додано в /etc/sudoers"
else
    echo "ℹ️ sudo правило вже існує в /etc/sudoers"
fi

# Крок 4: Перевіряю синтаксис
echo "🔍 Перевіряю синтаксис sudoers..."
if sudo visudo -c; then
    echo "✅ Синтаксис sudoers правильний"
else
    echo "❌ Помилка в синтаксисі sudoers"
    exit 1
fi

# Крок 5: Тестую sudo без пароля
echo "🧪 Тестую sudo без пароля..."
if sudo mkdir -p /tmp/test_sudo 2>/dev/null; then
    echo "✅ sudo mkdir працює без пароля"
    sudo rm -rf /tmp/test_sudo
else
    echo "❌ sudo mkdir не працює без пароля"
fi

if sudo systemctl status telegram-bot >/dev/null 2>&1; then
    echo "✅ sudo systemctl працює без пароля"
else
    echo "❌ sudo systemctl не працює без пароля"
fi

echo "🎉 Налаштування sudo завершено!"
echo "Тепер CI може виконувати sudo команди без пароля"
