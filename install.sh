#!/bin/bash

echo "🚀 Установка зависимостей для FastAPI проекта..."

# Создание виртуального окружения (опционально)
if [ ! -d "venv" ]; then
    echo "📦 Создание виртуального окружения..."
    python3 -m venv venv
fi

# Активация виртуального окружения
echo "🔧 Активация виртуального окружения..."
source venv/bin/activate

# Установка зависимостей
echo "📚 Установка зависимостей..."
pip install -r requirements.txt

echo "✅ Установка завершена!"
echo ""
echo "🎯 Для запуска сервера выполните:"
echo "   source venv/bin/activate"
echo "   uvicorn main:app --reload"
echo ""
echo "📖 Документация будет доступна по адресу: http://127.0.0.1:8000/docs"
