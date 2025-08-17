# Інструкції по налаштуванню Telegram Bot на сервері

## Проблема
Бот не може запуститися через відсутність `BOT_TOKEN` в `.env` файлі.

## Рішення

### 1. Автоматичне налаштування (рекомендується)
```bash
# На сервері
cd /opt/telegram-bot/bot
sudo ./setup_env.sh
```

### 2. Ручне налаштування
```bash
# На сервері
cd /opt/telegram-bot/bot

# Створити .env файл з example.env
cp example.env .env

# Відредагувати .env файл
sudo nano .env

# Встановити BOT_TOKEN (отримати від @BotFather)
BOT_TOKEN="1234567890:ABCdefGHIjklMNOpqrsTUVwxyz"

# Встановити правильні права
sudo chown roman:roman .env
sudo chmod 600 .env
```

### 3. Оновлення сервісу
```bash
# Копіювати новий сервісний файл
sudo cp telegram-bot-enhanced.service /etc/systemd/system/telegram-bot.service

# Перезавантажити systemd
sudo systemctl daemon-reload

# Перезапустити сервіс
sudo systemctl restart telegram-bot

# Перевірити статус
sudo systemctl status telegram-bot
```

## Перевірка налаштування

### Health Check
```bash
# Перевірити health endpoint
curl http://localhost:8081/health

# Перевірити status endpoint
curl http://localhost:8081/status
```

### Логи
```bash
# Переглянути логи сервісу
sudo journalctl -u telegram-bot -f

# Переглянути останні логи
sudo journalctl -u telegram-bot -n 50
```

## Структура файлів
```
/opt/telegram-bot/bot/
├── .env                    # Конфігурація (створити)
├── example.env             # Приклад конфігурації
├── bot.py                  # Основний код бота
├── health_check.py         # Health check сервер
├── run_with_health.py      # Скрипт запуску з health check
├── telegram-bot-enhanced.service  # Сервісний файл
├── setup_env.sh            # Скрипт налаштування
└── requirements.txt        # Python залежності
```

## Важливо
- **BOT_TOKEN** - обов'язковий параметр для роботи бота
- **.env файл** повинен мати права 600 та власника roman:roman
- **Health check** доступний на порту 8081
- **Сервіс** автоматично перезапускається при збоях
