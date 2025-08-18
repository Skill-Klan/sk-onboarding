#!/bin/bash
echo "🧹 Очищення Python кешу..."

# Очищаємо __pycache__ директорії
echo "🗑️ Видаляю __pycache__ директорії..."
find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true

# Очищаємо .pyc файли
echo "🗑️ Видаляю .pyc файли..."
find . -name "*.pyc" -delete 2>/dev/null || true

# Очищаємо .pyo файли
echo "🗑️ Видаляю .pyo файли..."
find . -name "*.pyo" -delete 2>/dev/null || true

# Очищаємо .pyd файли
echo "🗑️ Видаляю .pyd файли..."
find . -name "*.pyd" -delete 2>/dev/null || true

echo "✅ Кеш очищено!"
echo "📁 Поточна директорія:"
ls -la | head -20
