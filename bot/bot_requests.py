#!/usr/bin/env python3
"""
Simple Telegram Bot using requests library to avoid SSL issues with python-telegram-bot
"""

import json
import os
import time
import requests
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

class SimpleTelegramBot:
    def __init__(self, token):
        self.token = token
        self.base_url = f"https://api.telegram.org/bot{token}"
        self.offset = 0
        
    def get_updates(self):
        """Get updates from Telegram"""
        try:
            url = f"{self.base_url}/getUpdates"
            params = {
                'offset': self.offset,
                'timeout': 30
            }
            
            response = requests.get(url, params=params, verify=False, timeout=35)
            if response.status_code == 200:
                data = response.json()
                if data.get('ok'):
                    updates = data.get('result', [])
                    if updates:
                        self.offset = updates[-1]['update_id'] + 1
                    return updates
                else:
                    print(f"Telegram API error: {data}")
            else:
                print(f"HTTP error: {response.status_code}")
                
        except Exception as e:
            print(f"Error getting updates: {e}")
        
        return []
    
    def send_message(self, chat_id, text, parse_mode='HTML'):
        """Send message to chat"""
        try:
            url = f"{self.base_url}/sendMessage"
            data = {
                'chat_id': chat_id,
                'text': text,
                'parse_mode': parse_mode
            }
            
            response = requests.post(url, json=data, verify=False, timeout=10)
            if response.status_code == 200:
                result = response.json()
                if result.get('ok'):
                    print(f"✅ Message sent to {chat_id}")
                    return True
                else:
                    print(f"❌ Failed to send message: {result}")
            else:
                print(f"❌ HTTP error: {response.status_code}")
                
        except Exception as e:
            print(f"❌ Error sending message: {e}")
        
        return False
    
    def send_keyboard(self, chat_id, text, keyboard):
        """Send message with keyboard"""
        try:
            url = f"{self.base_url}/sendMessage"
            data = {
                'chat_id': chat_id,
                'text': text,
                'parse_mode': 'HTML',
                'reply_markup': keyboard
            }
            
            response = requests.post(url, json=data, verify=False, timeout=10)
            if response.status_code == 200:
                result = response.json()
                if result.get('ok'):
                    print(f"✅ Keyboard sent to {chat_id}")
                    return True
                else:
                    print(f"❌ Failed to send keyboard: {result}")
            else:
                print(f"❌ HTTP error: {response.status_code}")
                
        except Exception as e:
            print(f"❌ Error sending keyboard: {e}")
        
        return False
    
    def handle_start_command(self, chat_id, user_data):
        """Handle /start command"""
        text = (
            f"bot_requests.py"
        )
        
        # Create keyboard with onboarding buttons
        keyboard = {
            'keyboard': [
                [
                    {
                        'text': '🏠 Local Onboarding',
                        'web_app': {
                            'url': 'https://skill-klan.github.io/sk-onboarding/'
                        }
                    }
                ],
                [
                    {
                        'text': '🌈 Base Onboarding',
                        'web_app': {
                            'url': 'https://easterok.github.io/telegram-onboarding-kit'
                        }
                    }
                ]
            ],
            'resize_keyboard': True,
            'one_time_keyboard': False
        }
        
        return self.send_keyboard(chat_id, text, keyboard)
    
    def handle_web_app_data(self, chat_id, web_app_data):
        """Handle data from web app"""
        try:
            data = json.loads(web_app_data)
            payload = data.get("payload", {})
            product = data.get("product", {})
            
            # Send received payload
            if payload:
                payload_str = json.dumps(payload, indent=4)
                text = f"📦 Got data from onboarding:\n{payload_str}"
                self.send_message(chat_id, text)
            
            # Send invoice info
            if product:
                text = (
                    f"💰 Product: {product.get('title', 'Unknown')}\n"
                    f"💵 Price: {product.get('price', '0')} {product.get('currency', 'USD')}\n"
                    f"📝 Description: {product.get('description', 'No description')}\n"
                    f"💳 Payment method: {product.get('payment_method', 'Unknown')}"
                )
                self.send_message(chat_id, text)
                
        except Exception as e:
            print(f"Error handling web app data: {e}")
            self.send_message(chat_id, f"❌ Error processing data: {str(e)}")
    
    def process_update(self, update):
        """Process single update"""
        try:
            # Handle message
            if 'message' in update:
                message = update['message']
                chat_id = message['chat']['id']
                user = message.get('from', {})
                
                # Handle text messages
                if 'text' in message:
                    text = message['text']
                    if text == '/start':
                        user_data = {
                            'language_code': user.get('language_code', 'unknown')
                        }
                        self.handle_start_command(chat_id, user_data)
                    else:
                        # Echo message
                        self.send_message(chat_id, f"📝 You said: {text}")
                
                # Handle web app data
                elif 'web_app_data' in message:
                    web_app_data = message['web_app_data']['data']
                    self.handle_web_app_data(chat_id, web_app_data)
                
                # Handle other message types
                else:
                    self.send_message(chat_id, "📱 I received your message!")
            
            # Handle callback queries
            elif 'callback_query' in update:
                callback_query = update['callback_query']
                chat_id = callback_query['message']['chat']['id']
                data = callback_query['data']
                
                self.send_message(chat_id, f"🔘 Button clicked: {data}")
                
        except Exception as e:
            print(f"Error processing update: {e}")
    
    def run(self):
        """Main bot loop"""
        print("🤖 Starting Simple Telegram Bot...")
        print(f"🔑 Bot token: {self.token[:10]}...")
        print("🔄 Starting polling loop...")
        
        while True:
            try:
                updates = self.get_updates()
                
                for update in updates:
                    self.process_update(update)
                
                time.sleep(1)  # Small delay between requests
                
            except KeyboardInterrupt:
                print("\n🛑 Bot stopped by user")
                break
            except Exception as e:
                print(f"❌ Error in main loop: {e}")
                time.sleep(5)  # Wait before retrying

def main():
    # Load environment variables
    bot_token = os.getenv("BOT_TOKEN")
    if not bot_token:
        raise ValueError("Invalid BOT_TOKEN in .env file")
    
    # Create and run bot
    bot = SimpleTelegramBot(bot_token)
    bot.run()

if __name__ == "__main__":
    main()
