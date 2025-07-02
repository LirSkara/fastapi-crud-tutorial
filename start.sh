#!/bin/bash

echo "🚀 Запуск FastAPI сервера..."
echo ""

# Проверяем, установлены ли зависимости
if [ ! -d "venv" ]; then
    echo "⚠️  Виртуальное окружение не найдено."
    echo "   Сначала запустите: ./install.sh"
    exit 1
fi

# Активируем виртуальное окружение
source venv/bin/activate

# Проверяем установку uvicorn
if ! command -v uvicorn &> /dev/null; then
    echo "⚠️  uvicorn не установлен. Устанавливаю зависимости..."
    pip install -r requirements.txt
fi

echo "🌐 Запуск сервера на http://127.0.0.1:8000"
echo ""
echo "📚 Доступные ссылки:"
echo "   API документация: http://127.0.0.1:8000/docs"
echo "   Веб-интерфейс:    http://127.0.0.1:8000/static/index.html"
echo "   ReDoc:            http://127.0.0.1:8000/redoc"
echo ""
echo "Нажмите Ctrl+C для остановки сервера"
echo ""

uvicorn main:app --reload --host 127.0.0.1 --port 8000
