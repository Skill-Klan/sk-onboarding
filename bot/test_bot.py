#!/usr/bin/env python3
import asyncio
import os
from dotenv import load_dotenv
from telegram.ext import ApplicationBuilder

async def test_bot():
    load_dotenv()
    
    # Створюємо ApplicationBuilder
    app = ApplicationBuilder().token(os.getenv('BOT_TOKEN')).build()
    
    try:
        # Отримуємо інформацію про бота
        bot_info = await app.bot.get_me()
        print(f'✅ Bot info: {bot_info.first_name} (@{bot_info.username})')
        print(f'✅ Bot ID: {bot_info.id}')
        print(f'✅ Can join groups: {bot_info.can_join_groups}')
        print(f'✅ Can read all group messages: {bot_info.can_read_all_group_messages}')
        
        # Перевіряємо змінні середовища
        print(f'✅ BOT_TOKEN: {os.getenv("BOT_TOKEN", "NOT_SET")[:20]}...')
        print(f'✅ LOCAL_ONBOARDING_URL: {os.getenv("LOCAL_ONBOARDING_URL", "NOT_SET")}')
        
        return True
        
    except Exception as e:
        print(f'❌ Error: {e}')
        return False
    finally:
        await app.shutdown()

if __name__ == "__main__":
    success = asyncio.run(test_bot())
    if success:
        print("\n🎉 Bot test successful! You can now run the main bot.")
    else:
        print("\n💥 Bot test failed. Check the error above.")
