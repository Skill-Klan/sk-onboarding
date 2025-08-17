#!/bin/bash
# Правильне налаштування sudo без пароля для CI

echo "🔧 Налаштування sudo без пароля для CI..."

# Перевіряємо, чи є sudo
if ! command -v sudo >/dev/null 2>&1; then
    echo "❌ sudo не встановлено"
    exit 1
fi

# Створюємо backup sudoers
echo "📋 Створюю backup sudoers..."
sudo cp /etc/sudoers /etc/sudoers.backup.$(date +%Y%m%d_%H%M%S)

# Перевіряємо поточну конфігурацію
echo "🔍 Перевіряю поточну конфігурацію sudo..."
if sudo grep -q "requiretty" /etc/sudoers; then
    echo "⚠️ Знайдено requiretty, коментую..."
    sudo sed -i 's/^Defaults.*requiretty/#&/' /etc/sudoers
fi

# Знаходимо шляхи до команд
echo "🔍 Знаходжу шляхи до команд..."
SYSTEMCTL_PATH=$(which systemctl)
CP_PATH=$(which cp)
MKDIR_PATH=$(which mkdir)
CHOWN_PATH=$(which chown)
KILL_PATH=$(which kill)
LSOF_PATH=$(which lsof)
PKILL_PATH=$(which pkill)
PGREP_PATH=$(which pgrep)

echo "📁 Шляхи до команд:"
echo "  systemctl: $SYSTEMCTL_PATH"
echo "  cp: $CP_PATH"
echo "  mkdir: $MKDIR_PATH"
echo "  chown: $CHOWN_PATH"
echo "  kill: $KILL_PATH"
echo "  lsof: $LSOF_PATH"
echo "  pkill: $PKILL_PATH"
echo "  pgrep: $PGREP_PATH"

# Додаємо правило для CI користувача
echo "➕ Додаю правило для CI користувача..."
CI_USER="roman"
SUDOERS_RULE="$CI_USER ALL=(ALL) NOPASSWD: $SYSTEMCTL_PATH, $CP_PATH, $MKDIR_PATH, $CHOWN_PATH, $KILL_PATH, $LSOF_PATH, $PKILL_PATH, $PGREP_PATH"

# Перевіряємо, чи правило вже існує
if ! sudo grep -q "$CI_USER ALL=(ALL) NOPASSWD:" /etc/sudoers; then
    echo "$SUDOERS_RULE" | sudo tee -a /etc/sudoers
    echo "✅ Правило додано"
else
    echo "ℹ️ Правило вже існує, оновлюю..."
    # Видаляємо старе правило
    sudo sed -i "/$CI_USER ALL=(ALL) NOPASSWD:/d" /etc/sudoers
    # Додаємо нове
    echo "$SUDOERS_RULE" | sudo tee -a /etc/sudoers
    echo "✅ Правило оновлено"
fi

# Перевіряємо синтаксис sudoers
echo "🔍 Перевіряю синтаксис sudoers..."
if sudo visudo -c; then
    echo "✅ Синтаксис sudoers правильний"
else
    echo "❌ Помилка в синтаксисі sudoers, відновлюю backup..."
    sudo cp /etc/sudoers.backup.* /etc/sudoers
    exit 1
fi

echo "🎉 Налаштування sudo завершено!"
echo "Тепер CI може виконувати sudo команди без пароля для:"
echo "  - systemctl (управління сервісами)"
echo "  - cp (копіювання файлів)"
echo "  - mkdir (створення директорій)"
echo "  - chown (зміна власника)"
echo "  - kill, lsof, pkill, pgrep (управління процесами)"
