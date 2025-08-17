#!/bin/bash
echo "🔧 Налаштування sudo без пароля для CI..."
sudo cp /etc/sudoers /etc/sudoers.backup.$(date +%Y%m%d_%H%M%S)
sudo sed -i "s/^Defaults.*requiretty/#&/" /etc/sudoers
echo "roman ALL=(ALL) NOPASSWD: /bin/systemctl restart telegram-bot, /bin/systemctl daemon-reload, /bin/systemctl stop telegram-bot, /bin/systemctl start telegram-bot, /bin/systemctl status telegram-bot, /bin/kill, /bin/lsof, /bin/pkill, /bin/pgrep" | sudo tee -a /etc/sudoers
sudo visudo -c && echo "✅ Налаштування завершено"
