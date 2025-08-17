# Інструкція для налаштування sudo без пароля

## 🚨 ВАЖЛИВО: Це потрібно виконати на сервері один раз!

### Крок 1: Підключення до сервера
```bash
ssh roman@37.57.209.201
```

### Крок 2: Запуск скрипта налаштування
```bash
cd /opt/telegram-bot/bot
chmod +x setup_sudo_nopasswd.sh
./setup_sudo_nopasswd.sh
```

### Крок 3: Перевірка налаштування
```bash
sudo systemctl status telegram-bot
sudo cp /tmp/test /tmp/test2
```

### Що робить скрипт:
1. **Коментує `requiretty`** - дозволяє sudo без TTY
2. **Додає правило для користувача `roman`**:
   ```
   roman ALL=(ALL) NOPASSWD: /bin/systemctl, /bin/cp, /bin/mkdir, /bin/chown, /bin/kill, /bin/lsof, /bin/pkill, /bin/pgrep
   ```
3. **Перевіряє синтаксис** sudoers файлу

### Безпека:
- ✅ Обмежено тільки потрібними командами
- ✅ Не дає повного sudo доступу
- ✅ Безпечно для production

### Після налаштування:
- CI зможе виконувати sudo команди без пароля
- Деплой та rollback будуть працювати автоматично
- Не потрібно передавати паролі через секрети
