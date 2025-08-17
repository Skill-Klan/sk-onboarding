#!/usr/bin/env python3
"""
Test script to check connection to Telegram API
"""

import os
import ssl
import urllib3
import requests
from dotenv import load_dotenv

# Disable SSL warnings
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Load environment variables
load_dotenv()

def test_ssl_context():
    """Test SSL context configuration"""
    print("🔧 Testing SSL context configuration...")
    
    try:
        # Create SSL context
        ssl_context = ssl.create_default_context()
        ssl_context.check_hostname = False
        ssl_context.verify_mode = ssl.CERT_NONE
        print("✅ SSL context created successfully")
        return ssl_context
    except Exception as e:
        print(f"❌ Error creating SSL context: {e}")
        return None

def test_requests_with_ssl_disabled():
    """Test requests with SSL verification disabled"""
    print("\n🌐 Testing requests with SSL verification disabled...")
    
    try:
        # Test with requests
        response = requests.get(
            'https://api.telegram.org',
            verify=False,
            timeout=10
        )
        print(f"✅ Requests successful: {response.status_code}")
        print(f"📄 Response: {response.text[:200]}...")
        return True
    except Exception as e:
        print(f"❌ Requests failed: {e}")
        return False

def test_urllib3_with_ssl_disabled():
    """Test urllib3 with SSL verification disabled"""
    print("\n🌐 Testing urllib3 with SSL verification disabled...")
    
    try:
        import urllib3
        http = urllib3.PoolManager(cert_reqs='CERT_NONE', assert_hostname=False)
        response = http.request('GET', 'https://api.telegram.org')
        print(f"✅ Urllib3 successful: {response.status}")
        print(f"📄 Response: {response.data.decode()[:200]}...")
        return True
    except Exception as e:
        print(f"❌ Urllib3 failed: {e}")
        return False

def test_telegram_bot_connection():
    """Test direct connection to Telegram Bot API"""
    print("\n🤖 Testing direct connection to Telegram Bot API...")
    
    bot_token = os.getenv("BOT_TOKEN")
    if not bot_token:
        print("❌ BOT_TOKEN not found in environment")
        return False
    
    try:
        url = f"https://api.telegram.org/bot{bot_token}/getMe"
        response = requests.get(url, verify=False, timeout=10)
        
        if response.status_code == 200:
            data = response.json()
            if data.get('ok'):
                print("✅ Telegram Bot API connection successful!")
                print(f"🤖 Bot info: {data['result']}")
                return True
            else:
                print(f"❌ Telegram API error: {data}")
                return False
        else:
            print(f"❌ HTTP error: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Connection failed: {e}")
        return False

def test_environment_variables():
    """Test environment variables"""
    print("\n🔍 Testing environment variables...")
    
    bot_token = os.getenv("BOT_TOKEN")
    if bot_token:
        print(f"✅ BOT_TOKEN: {bot_token[:10]}...")
    else:
        print("❌ BOT_TOKEN not found")
    
    # Check SSL-related environment variables
    python_https_verify = os.getenv("PYTHONHTTPSVERIFY")
    curl_ca_bundle = os.getenv("CURL_CA_BUNDLE")
    
    print(f"🔧 PYTHONHTTPSVERIFY: {python_https_verify}")
    print(f"🔧 CURL_CA_BUNDLE: {curl_ca_bundle}")

def main():
    print("🧪 Testing Telegram Bot connection...")
    print("=" * 50)
    
    # Test environment variables
    test_environment_variables()
    
    # Test SSL context
    ssl_context = test_ssl_context()
    
    # Test different HTTP clients
    requests_success = test_requests_with_ssl_disabled()
    urllib3_success = test_urllib3_with_ssl_disabled()
    
    # Test Telegram Bot API
    telegram_success = test_telegram_bot_connection()
    
    print("\n" + "=" * 50)
    print("📊 Test Results Summary:")
    print(f"🔧 SSL Context: {'✅' if ssl_context else '❌'}")
    print(f"🌐 Requests: {'✅' if requests_success else '❌'}")
    print(f"🌐 Urllib3: {'✅' if urllib3_success else '❌'}")
    print(f"🤖 Telegram API: {'✅' if telegram_success else '❌'}")
    
    if telegram_success:
        print("\n🎉 All tests passed! Bot should work.")
    else:
        print("\n❌ Some tests failed. Check the errors above.")

if __name__ == "__main__":
    main()
