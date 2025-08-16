# 🚀 Telegram Bot + Web App - Автоматичний деплой

Цей проєкт включає Telegram бота та веб-додаток з автоматичним деплоєм через GitHub Actions.

## 📁 Структура проєкту

```
sk-onboarding/
├── app/                    # Веб-додаток (Vue.js + FAQ)
├── bot/                   # Telegram бот (Python)
├── .github/workflows/     # GitHub Actions для CI/CD
└── packages/              # Спільні пакети
```

## 🚀 Швидкий старт

### 1. Локальний запуск бота

```bash
cd bot/
chmod +x run.sh
./run.sh
```

### 2. Локальний запуск веб-додатку

```bash
cd app/
npm install
npm run dev
```

## 🔑 Налаштування GitHub Actions

### Автоматичне налаштування SSH

```bash
chmod +x setup_github_actions.sh
./setup_github_actions.sh
```

### Ручне налаштування

1. **Створіть SSH ключ:**
   ```bash
   ssh-keygen -t rsa -b 4096 -C "github-actions@telegram-bot" -f ~/.ssh/github-actions
   ```

2. **Додайте публічний ключ на сервер:**
   ```bash
   # На сервері 37.57.209.201
   mkdir -p ~/.ssh
   chmod 700 ~/.ssh
   echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCg/5VifZvwRvE86E2SdblfPHt+FNjNBAJqQa36dv2jKfWLZ4uGgcnpd8AHBrpEQ0jap11M1uzCTWv0MK7XwiGtdSANQ34naWLAGh8IM5cl+5ei5vgCujjrOGsVuTwlD4YfNu2XRztQvA8HACM9SqrcHjTLTVY7PeMGiwZk3KUvLNNfa8NXHtRh1LbpnGe0v89iPS2NjSfOE3vqg1NwPe4k7CGwF/MF0yUdTO1/53YJabnT+VYkju2RiTfgy/nWzoOpxg37lx9iGsHVbTWPst3Nfju0OqgJ8LNHSveGd4IeuFHD690ZvTHxOEdCQ8xz8ANvZ7IjT8jcxBqwnBTM0z+Xh8aSDZQ3g3JSR2+heDDWO830xBlAqI9RfkO0rzAb+1Gl4QqGY6hhH5rEaB/JaugB0HJyZS3lctpA83rhvzpKhvOeS9b/VJN27ha35xdcPpA8z9WH0rRH0hHBw2heh+gI8UoUmoB5m84up2Pv0Tz+jxvKipM3lMRqFlGWOCUvuJtrBYCBww3/3FPuDqgLCYx4+y0K4WZZbZRt1nhbzY81tS4TXR8Z42IguImcFBu0DxvghZgfJXk82IYto9UrE3GIoLCDHPMjxVK7dpqrEEwAUKxUpIx7QMoY/TPZaW11rl6sODCTHRh/p2JQ5pPIjQl1+ybeXuMG6ya6CLC3a3pKjw== github-actions@telegram-bot" >> ~/.ssh/authorized_keys
   chmod 600 ~/.ssh/authorized_keys
   ```

3. **Додайте GitHub Secrets:**
   - `SSH_PRIVATE_KEY` = вміст ~/.ssh/github-actions
   - `SERVER_HOST` = 37.57.209.201
   - `SERVER_USER` = roman
   - `SERVER_PORT` = 22

## 🔄 Автоматичний деплой

### Що відбувається при push в main:

1. **Веб-додаток** - автоматично деплоїться на GitHub Pages
2. **Telegram бот** - автоматично оновлюється на сервері та перезапускається
3. **Всі зміни** - синхронізуються автоматично

### Workflow файли:

- `.github/workflows/deploy.yml` - основний workflow для деплою

## 📱 Особливості

### Telegram Bot
- Python + python-telegram-bot
- Підтримка платежів (Telegram Payments, Wallet Pay)
- Автоматичний перезапуск через systemd

### Web App
- Vue.js + TypeScript
- FAQ система з пошуком
- Локалізація (EN/UK)
- Responsive дизайн

## 🛠️ Технології

- **Backend:** Python 3.12, python-telegram-bot
- **Frontend:** Vue.js 3, TypeScript, SCSS
- **CI/CD:** GitHub Actions
- **Deployment:** GitHub Pages + SSH + rsync
- **Server:** Ubuntu + systemd + Nginx

## 📚 Документація

- `SERVER_SSH_SETUP.md` - детальні інструкції по налаштуванню SSH
- `setup_github_actions.sh` - автоматичне налаштування GitHub Actions
- `bot/README.md` - інструкції по запуску бота

## 🚨 Важливо

- Переконайтеся, що SSH ключ додано на сервер
- Всі GitHub Secrets мають бути налаштовані
- Бот має працювати під користувачем `roman` на сервері

## 📞 Підтримка

При проблемах перевірте:
1. GitHub Actions logs
2. Server logs: `journalctl -u telegram-bot`
3. SSH з'єднання: `ssh roman@37.57.209.201`

---

**🎯 Після налаштування: просто робіть `git push` і все оновиться автоматично!**
