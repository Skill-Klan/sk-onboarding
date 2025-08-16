# 🚀 Налаштування SSH на сервері для GitHub Actions

## 📋 Кроки для виконання НА СЕРВЕРІ (37.57.209.201):

### 1. Підключіться до сервера
```bash
# Через RDP, консоль або інший спосіб
```

### 2. Додайте SSH ключ
```bash
# Створіть .ssh директорію
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Додайте публічний ключ (скопіюйте знизу)
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCg/5VifZvwRvE86E2SdblfPHt+FNjNBAJqQa36dv2jKfWLZ4uGgcnpd8AHBrpEQ0jap11M1uzCTWv0MK7XwiGtdSANQ34naWLAGh8IM5cl+5ei5vgCujjrOGsVuTwlD4YfNu2XRztQvA8HACM9SqrcHjTLTVY7PeMGiwZk3KUvLNNfa8NXHtRh1LbpnGe0v89iPS2NjSfOE3vqg1NwPe4k7CGwF/MF0yUdTO1/53YJabnT+VYkju2RiTfgy/nWzoOpxg37lx9iGsHVbTWPst3Nfju0OqgJ8LNHSveGd4IeuFHD690ZvTHxOEdCQ8xz8ANvZ7IjT8jcxBqwnBTM0z+Xh8aSDZQ3g3JSR2+heDDWO830xBlAqI9RfkO0rzAb+1Gl4QqGY6hhH5rEaB/JaugB0HJyZS3lctpA83rhvzpKhvOeS9b/VJN27ha35xdcPpA8z9WH0rRH0hHBw2heh+gI8UoUmoB5m84up2Pv0Tz+jxvKipM3lMRqFlGWOCUvuJtrBYCBww3/3FPuDqgLCYx4+y0K4WZZbZRt1nhbzY81tS4TXR8Z42IguImcFBu0DxvghZgfJXk82IYto9UrE3GIoLCDHPMjxVK7dpqrEEwAUKxUpIx7QMoY/TPZaW11rl6sODCTHRh/p2JQ5pPIjQl1+ybeXuMG6ya6CLC3a3pKjw== github-actions@telegram-bot" >> ~/.ssh/authorized_keys

# Встановіть правильні права
chmod 600 ~/.ssh/authorized_keys
```

### 3. Перевірте результат
```bash
tail -1 ~/.ssh/authorized_keys
ls -la ~/.ssh/authorized_keys
```

## 🎯 Після налаштування на сервері:

1. **Додайте GitHub Secrets** в репозиторії:
   - `SSH_PRIVATE_KEY` = вміст ~/.ssh/github-actions
   - `SERVER_HOST` = 37.57.209.201
   - `SERVER_USER` = roman
   - `SERVER_PORT` = 22

2. **Перезапустіть failed workflow** або зробіть новий push

## ⚠️ Важливо:
- Ключ має бути доданий в ~/.ssh/authorized_keys користувача roman
- Файл authorized_keys має мати права 600
- Директорія ~/.ssh має мати права 700
