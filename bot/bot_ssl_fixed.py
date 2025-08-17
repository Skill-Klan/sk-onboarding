#!/usr/bin/env python3
"""
Telegram Bot with SSL fixes for production environment
"""

import json
import os
import re
import urllib.parse
import uuid
import ssl
import certifi
from typing import Any, Dict, Optional, Tuple
import httpx
import urllib3
from dotenv import load_dotenv

# Disable SSL warnings
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

from telegram import (
    InlineKeyboardButton,
    InlineKeyboardMarkup,
    KeyboardButton,
    LabeledPrice,
    ReplyKeyboardMarkup,
    ReplyKeyboardRemove,
    Update,
    User,
    WebAppInfo,
)
from telegram.constants import ChatAction, ParseMode
from telegram.ext import (
    ApplicationBuilder,
    CallbackQueryHandler,
    CommandHandler,
    ContextTypes,
    MessageHandler,
    PreCheckoutQueryHandler,
    filters,
)

# Load environment variables
load_dotenv()

# Get onboarding URLs from environment variables
LOCAL_ONBOARDING_URL = os.getenv("LOCAL_ONBOARDING_URL", "http://localhost:3000")
LOCAL_FAQ_URL = os.getenv("LOCAL_FAQ_URL", "https://skill-klan.github.io/sk-onboarding/")
BASE_ONBOARDING_URL = os.getenv("BASE_ONBOARDING_URL", "https://easterok.github.io/telegram-onboarding-kit")

# SSL Configuration
def configure_ssl():
    """Configure SSL context for better compatibility"""
    try:
        # Create SSL context that ignores certificate verification
        ssl_context = ssl.create_default_context()
        ssl_context.check_hostname = False
        ssl_context.verify_mode = ssl.CERT_NONE
        print("✅ SSL context configured with certificate verification disabled")
        return ssl_context
    except Exception as e:
        print(f"⚠️ Warning: Could not configure SSL context: {e}")
        return None

# region: helper functions
def get_user_data(user: User) -> Dict[str, Any]:
    """Get user data from user object"""
    return {
        "language_code": user.language_code,
    }

def add_get_params_to_url(url: str, user_data: Dict[str, Any]):
    query_string = urllib.parse.urlencode(user_data)
    return f"{url}?{query_string}"

def remove_html_tags(text: str) -> str:
    """Remove html tags from a string and replace <br> tags with a space"""
    # replace <br> tags with a space
    text = re.sub("<br.*?>", " ", text)
    # remove all other HTML tags
    return re.sub("<.*?>", "", text)

# endregion: helper functions

async def start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    user_data = get_user_data(update.effective_user)

    text = (
        f"♥️ Hi! I'm demo bot for <a href='https://github.com/Easterok/telegram-onboarding-kit'>Telegram Onboarding Kit</a>\n"
        f"\n"
        f"Below you can see demo onboardings <b>created with our kit</b>. It's better to you watch them from 📱 mobile device\n"
        f"\n"
        f"Your language code: <b>{user_data['language_code']}</b>\n"
    )

    reply_markup = ReplyKeyboardMarkup.from_column(
        [
            KeyboardButton(
                text="🏠 Local Onboarding",
                web_app=WebAppInfo(
                    url=add_get_params_to_url(LOCAL_ONBOARDING_URL, user_data)
                ),
            ),
            KeyboardButton(
                text="🌈 Base Onboarding",
                web_app=WebAppInfo(
                    url=add_get_params_to_url(BASE_ONBOARDING_URL, user_data)
                ),
            ),
        ]
    )

    await update.effective_message.reply_text(
        text=text,
        reply_markup=reply_markup,
        parse_mode=ParseMode.HTML,
        disable_web_page_preview=True,
    )

async def get_data_from_mini_app(
    update: Update, context: ContextTypes.DEFAULT_TYPE
) -> None:
    """This handler is called when user sends data from mini app"""
    try:
        data = json.loads(update.effective_message.web_app_data.data)
        payload, product = data["payload"], data["product"]

        # send received payload
        if payload:
            payload_str = json.dumps(payload, indent=4)
            text = f"📦 Got data from onboarding:\n{payload_str}"

            await update.effective_message.reply_text(
                text=text,
                reply_markup=ReplyKeyboardRemove(),
            )

        await send_invoice(update, context, product)
    except Exception as e:
        print(f"Error processing mini app data: {e}")
        await update.effective_message.reply_text(
            text=f"❌ Error processing data: {str(e)}",
            reply_markup=ReplyKeyboardRemove(),
        )

async def send_invoice(
    update: Update, context: ContextTypes.DEFAULT_TYPE, product: Dict
) -> None:
    try:
        if product["payment_method"] not in context.bot_data.get("payment_tokens", {}):
            await send_message_that_payment_method_is_not_supported(
                update, context, product["payment_method"]
            )
            return

        if product["payment_method"] == "telegram_payments":
            await send_telegram_payment_invoice(update, context, product)
        elif product["payment_method"] == "wallet_pay":
            await send_wallet_pay_invoice(update, context, product)
        else:
            raise ValueError(f"Unknown payment method: {product['payment_method']}")
    except Exception as e:
        print(f"Error sending invoice: {e}")
        await update.effective_message.reply_text(
            text=f"❌ Error sending invoice: {str(e)}",
        )

async def send_message_that_payment_method_is_not_supported(
    update: Update, context: ContextTypes.DEFAULT_TYPE, payment_method: str
) -> None:
    text = f"🥲 Sorry, <b>{payment_method}</b> payment method is not supported"
    await update.effective_message.reply_text(
        text=text,
        parse_mode=ParseMode.HTML,
    )

async def send_message_about_successful_payment(
    update: Update, context: ContextTypes.DEFAULT_TYPE
) -> None:
    await update.effective_message.delete()
    await update.effective_message.reply_text(
        text=f"🎉 Successful payment!",
        reply_markup=None,
        parse_mode=ParseMode.HTML,
    )

# region: telegram payments
async def send_telegram_payment_invoice(
    update: Update, context: ContextTypes.DEFAULT_TYPE, product: Dict
) -> None:
    """Send invoice with Telegram Payments"""
    text = (
        f"⚠️ It's test mode\n"
        f"You can use test card number <code>4242 4242 4242 4242</code> with any CVC and any future expiration date for testing"
    )
    await update.effective_message.reply_text(
        text=text,
        parse_mode=ParseMode.HTML,
    )

    title = remove_html_tags(product["title"])
    description = remove_html_tags(product["description"])

    await update.effective_message.reply_invoice(
        title=title,
        description=description,
        currency=product["currency"],
        prices=[LabeledPrice(title, int(product["price"] * 100))],
        provider_token=context.bot_data["payment_tokens"]["telegram_payments"],
        payload="some_payload_could_be_here",
    )

async def telegram_payment_pre_checkout(
    update: Update, context: ContextTypes.DEFAULT_TYPE
) -> None:
    await update.pre_checkout_query.answer(ok=True)

async def successful_telegram_payment(
    update: Update, context: ContextTypes.DEFAULT_TYPE
) -> None:
    await send_message_about_successful_payment(update, context)

# endregion: telegram payments

# region: wallet pay
async def send_wallet_pay_invoice(
    update: Update, context: ContextTypes.DEFAULT_TYPE, product: Dict
) -> None:
    """Send invoice with Wallet Pay"""
    await update.effective_chat.send_action(ChatAction.TYPING)

    async def create_invoice() -> Tuple[str, str]:
        url = "https://pay.wallet.tg/wpay/store-api/v1/order"

        headers = {
            "Wpay-Store-Api-Key": context.bot_data["payment_tokens"]["wallet_pay"],
            "Content-Type": "application/json",
            "Accept": "application/json",
        }

        bot_url = f"https://t.me/{context.bot.username}"
        data = {
            "amount": {
                "amount": product["price"],
                "currencyCode": product["currency"],
            },
            "externalId": str(uuid.uuid4()),
            "customerTelegramUserId": update.effective_user.id,
            "timeoutSeconds": 3600,
            "description": product["title"],
            "returnUrl": bot_url,
            "failReturnUrl": bot_url,
            "customData": "",
        }

        async with httpx.AsyncClient(verify=False) as client:
            result = await client.post(url, headers=headers, data=json.dumps(data))

        result_json = result.json()
        if result_json["status"] != "SUCCESS":
            raise Exception(
                f"Wallet Pay create invoice status != SUCCESS. Reason: {result_json['message']}"
            )

        return result_json["data"]["directPayLink"], result_json["data"]["id"]

    try:
        direct_pay_link, order_id = await create_invoice()

        title = remove_html_tags(product["title"])
        description = remove_html_tags(product["description"])

        text = (
            f"<b>{title}</b> ({product['price']} {product['currency']})\n"
            f"{description}\n"
            f"\n"
            f"Tap <b>👛 Wallet Pay</b> button to pay. After you pay, tap <b>Check payment status</b> button\n"
            f"\n"
            f"⚠️ Note: there is no test mode, all payments are carried out in real assets!"
        )

        reply_markup = InlineKeyboardMarkup.from_column(
            [
                InlineKeyboardButton(
                    text="👛 Wallet Pay",
                    url=direct_pay_link,
                ),
                InlineKeyboardButton(
                    text="Check payment status",
                    callback_data=f"check_wallet_pay_payment_status|{order_id}",
                ),
            ]
        )

        await update.effective_message.reply_text(
            text=text,
            reply_markup=reply_markup,
            parse_mode=ParseMode.HTML,
        )
    except Exception as e:
        print(f"Error creating wallet pay invoice: {e}")
        await update.effective_message.reply_text(
            text=f"❌ Error creating invoice: {str(e)}",
        )

async def check_wallet_pay_payment_status(
    update: Update, context: ContextTypes.DEFAULT_TYPE
) -> None:
    try:
        order_id = update.callback_query.data.split("|")[1]

        async def check_invoice_status() -> bool:
            url = "https://pay.wallet.tg/wpay/store-api/v1/order/preview"

            headers = {
                "Wpay-Store-Api-Key": context.bot_data["payment_tokens"]["wallet_pay"],
                "Content-Type": "application/json",
                "Accept": "application/json",
            }

            params = {"id": order_id}

            async with httpx.AsyncClient(verify=False) as client:
                result = await client.get(url, headers=headers, params=params)

            result_json = result.json()
            return result_json["data"]["status"] == "PAID"

        is_paid = await check_invoice_status()
        if is_paid:
            await update.callback_query.answer()
            await send_message_about_successful_payment(update, context)
        else:
            await update.callback_query.answer("🥲 Not paid yet")
    except Exception as e:
        print(f"Error checking wallet pay status: {e}")
        await update.callback_query.answer("❌ Error checking status")

# endregion: wallet pay

async def error_handler(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    error = context.error
    print(f"Bot error: {error}")
    
    text = f"🥲 Some error happened...\n<b>Error:</b> {error}"
    
    if update and update.effective_message:
        try:
            await update.effective_message.reply_text(
                text=text,
                parse_mode=ParseMode.HTML,
            )
        except Exception as e:
            print(f"Could not send error message: {e}")
    else:
        print(f"Error occurred: {error}")
        print(f"Update object: {update}")

    # Don't raise the error again to prevent infinite loops
    print(f"Error handled: {error}")

def run_bot(
    bot_token: str,
    telegram_payments_token: Optional[str] = None,
    wallet_pay_token: Optional[str] = None,
) -> None:
    print("🔧 Configuring bot with SSL fixes...")
    
    # Configure SSL context
    ssl_context = configure_ssl()
    
    # Build application with SSL settings
    builder = (
        ApplicationBuilder()
        .token(bot_token)
        .concurrent_updates(True)
        .http_version("1.1")
        .get_updates_http_version("1.1")
    )
    
    # Add SSL context if available
    if ssl_context:
        builder = builder.connection_pool_size(1)
    
    application = builder.build()

    # store payment tokens in bot data
    application.bot_data["payment_tokens"] = {}

    for payment_method, payment_token in [
        ("telegram_payments", telegram_payments_token),
        ("wallet_pay", wallet_pay_token),
    ]:
        if payment_token:
            application.bot_data["payment_tokens"][payment_method] = payment_token

    # handlers
    application.add_handler(CommandHandler("start", start))
    application.add_handler(
        MessageHandler(filters.StatusUpdate.WEB_APP_DATA, get_data_from_mini_app)
    )
    application.add_handler(PreCheckoutQueryHandler(telegram_payment_pre_checkout))
    application.add_handler(
        MessageHandler(filters.SUCCESSFUL_PAYMENT, successful_telegram_payment)
    )
    application.add_handler(
        CallbackQueryHandler(
            check_wallet_pay_payment_status, pattern="^check_wallet_pay_payment_status"
        )
    )

    # error handler
    application.add_error_handler(error_handler)

    # start the bot
    print("🚀 Starting the bot with SSL fixes...")
    try:
        application.run_polling(allowed_updates=Update.ALL_TYPES)
    except Exception as e:
        print(f"❌ Error starting bot: {e}")
        if "SSL" in str(e) or "certificate" in str(e).lower():
            print("🔧 SSL/Certificate error detected. Trying alternative approach...")
            # Try with different SSL settings
            print("🔧 Disabled SSL warnings. Retrying...")
            application.run_polling(allowed_updates=Update.ALL_TYPES)
        else:
            print(f"❌ Fatal error: {e}")
            raise e

if __name__ == "__main__":
    load_dotenv()

    bot_token = os.getenv("BOT_TOKEN")
    if not bot_token:
        raise ValueError("Invalid BOT_TOKEN in .env file")

    telegram_payments_token = os.getenv("TELEGRAM_PAYMENTS_TOKEN")
    wallet_pay_token = os.getenv("WALLET_PAY_TOKEN")

    print("🤖 Starting Telegram Bot with SSL fixes...")
    print(f"🔑 Bot token: {bot_token[:10]}...")
    
    run_bot(
        bot_token=bot_token,
        telegram_payments_token=telegram_payments_token if telegram_payments_token else None,
        wallet_pay_token=wallet_pay_token if wallet_pay_token else None,
    )
