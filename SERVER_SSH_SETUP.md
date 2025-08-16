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
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHcUryBl6naiT2gXetBSfgg/MbHnOU+l4IdODyCg8txD github-actions@telegram-bot" >> ~/.ssh/authorized_keys

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
   - `SERVER_PORT` = 2222

2. **Перезапустіть failed workflow** або зробіть новий push

## ⚠️ Важливо:
- Ключ має бути доданий в ~/.ssh/authorized_keys користувача roman
- Файл authorized_keys має мати права 600
- Директорія ~/.ssh має мати права 700
