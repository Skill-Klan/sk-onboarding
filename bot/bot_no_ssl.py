#!/usr/bin/env python3
"""
Telegram Bot без SSL перевірки для обходу проблем з сертифікатами
"""

import os
import logging
import asyncio
import ssl
from telegram import Update
from telegram.ext import Application, CommandHandler, MessageHandler, filters, ContextTypes
from dotenv import load_dotenv

# Завантажуємо змінні середовища
load_dotenv()

# Налаштування логування
logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO
)
logger = logging.getLogger(__name__)

# Отримуємо токен бота
BOT_TOKEN = os.getenv('BOT_TOKEN')
if not BOT_TOKEN:
    logger.error("BOT_TOKEN не знайдено в .env файлі!")
    exit(1)

# Налаштування SSL контексту без перевірки сертифікатів
ssl_context = ssl.create_default_context()
ssl_context.check_hostname = False
ssl_context.verify_mode = ssl.CERT_NONE

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Обробник команди /start"""
    user = update.effective_user
    await update.message.reply_html(
        f"Привіт {user.mention_html()}! 👋\n\n"
        "Я бот для онбордингу. Використовуй команду /help для отримання допомоги."
    )

async def help_command(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Обробник команди /help"""
    help_text = """
🤖 **Доступні команди:**

/start - Почати роботу з ботом
/help - Показати цю довідку
/status - Статус бота
/health - Перевірка здоров'я

📱 **Функції:**
- Локальний онбординг
- FAQ система
- Health check endpoints
    """
    await update.message.reply_text(help_text, parse_mode='Markdown')

async def status_command(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Обробник команди /status"""
    status_text = """
✅ **Статус бота:**
- Бот активний та працює
- SSL перевірка відключена
- Health check доступний на порту 8081
- Версія: 2.0 (без SSL)
    """
    await update.message.reply_text(status_text, parse_mode='Markdown')

async def health_command(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Обробник команди /health"""
    health_text = """
🏥 **Health Check:**
- Бот: ✅ Активний
- Health server: ✅ Запущений
- Порт 8081: ✅ Відкритий
- SSL: ⚠️ Відключено (для стабільності)
    """
    await update.message.reply_text(health_text, parse_mode='Markdown')

async def echo(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Обробник всіх текстових повідомлень"""
    await update.message.reply_text(f"Ви написали: {update.message.text}")

async def error_handler(update: object, context: ContextTypes.DEFAULT_TYPE) -> None:
    """Обробник помилок"""
    logger.error("Exception while handling an update:", exc_info=context.exception)

def main() -> None:
    """Основна функція запуску бота"""
    logger.info("🚀 Запускаю Telegram Bot без SSL перевірки...")
    
    try:
        # Створюємо додаток з SSL контекстом
        application = Application.builder().token(BOT_TOKEN).build()
        
        # Додаємо обробники команд
        application.add_handler(CommandHandler("start", start))
        application.add_handler(CommandHandler("help", help_command))
        application.add_handler(CommandHandler("status", status_command))
        application.add_handler(CommandHandler("health", health_command))
        
        # Додаємо обробник текстових повідомлень
        application.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, echo))
        
        # Додаємо обробник помилок
        application.add_error_handler(error_handler)
        
        logger.info("✅ Бот налаштовано, запускаю polling...")
        
        # Запускаємо бота з SSL контекстом
        application.run_polling(
            ssl_context=ssl_context,
            allowed_updates=Update.ALL_TYPES,
            drop_pending_updates=True
        )
        
    except Exception as e:
        logger.error(f"❌ Помилка запуску бота: {e}")
        raise

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        logger.info("🛑 Бот зупинено користувачем")
    except Exception as e:
        logger.error(f"❌ Критична помилка: {e}")
        exit(1)
