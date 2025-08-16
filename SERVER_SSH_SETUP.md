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
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDVf2/YPT9Ag04gFgd1xFDuT+/4jLP0Iu7eF81c51jQr7XcpUUgPHiqV0ueMjSF1UG8O597h4AnRz87kni4a6MhSgkgL/FpMBDKwmffGqysBwo75jz0cFV/t5Jkn1kVZz3aMukn3sRes9TQaR596gfiMe0t7VNXtnulKFWXKljGLT8q49SHw0qureSzgGkJ/YtwyJAoUK1qtJBPq8XAZ/YSdLNi/g2TIfh9VQSum4TPnset+Rh7rPe/tkyIBYXv1FXyTrxChtfpWzgOAVPrPzWcDZ1tJm8yt72T7L+1weLx+ApCy1PGtv+/g2L/gSz1gPlys9ZOC0hFNczpJhf6/Qxls5VU7o5MwuolnllKgnDcNIhhAK4awZ7Us7e4GCv/IPJm8dr02yH9TgmqvngIe2PneIVWs1lnx5zuo/tXHi7F0ihaRkF2SgWkPH/5Km5HR5DB2g/B37oJUsQbasxPwBAvOtq5wS93JM+h+Xb0aERyPFLO1Lf/J/fY7nSrgQA0vj5y85lF6Fmvq3F4A1KzuoRGJcJ1U2ZP/J8ShXiLfrF7dBCJuIhpBUKdwHugmxp5l6UGNvpC9m0/cO4uLHoTSAjO2JO9geYPDRZhsxmxd6I+FySvbq4IEz4QtOsZ4ggBrEips/+soeAzJOok7k7qJYgYvzhZAc9WGAr8KlKD3MoJKQ== github-actions@telegram-bot" >> ~/.ssh/authorized_keys

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
