#!/bin/bash

echo "🚀 Запуск FastAPI сервера..."
echo ""

# Проверяем, установлены ли зависимости
if [ ! -d "venv" ]; then
    echo "📦 Создание виртуального окружения..."
    python3 -m venv venv
    echo "✅ Виртуальное окружение создано"
fi

# Активируем виртуальное окружение
echo "🔧 Активация виртуального окружения..."
source venv/bin/activate

# Проверяем и устанавливаем зависимости
if [ -f "requirements.txt" ]; then
    echo "📋 Установка зависимостей..."
    pip install --upgrade pip > /dev/null 2>&1
    pip install -r requirements.txt > /dev/null 2>&1
    echo "✅ Зависимости установлены"
fi

# Получаем IP адрес для вывода
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    LOCAL_IP=$(ifconfig | grep 'inet ' | grep -v '127.0.0.1' | head -1 | awk '{print $2}')
else
    # Linux
    LOCAL_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "localhost")
fi

if [ -z "$LOCAL_IP" ]; then
    LOCAL_IP="localhost"
fi

echo ""
echo "🌐 FastAPI сервер запускается..."
echo ""
echo "📚 Доступные ссылки:"
echo "   🏠 Локально:        http://localhost:8000"
echo "   🌍 В сети:          http://$LOCAL_IP:8000"
echo "   📖 Документация:    http://localhost:8000/docs"
echo "   🎨 Веб-интерфейс:   http://localhost:8000/static/index.html"
echo ""
echo "Нажмите Ctrl+C для остановки сервера"
echo ""

# Запускаем FastAPI с поддержкой удаленных подключений
uvicorn main:app --reload --host 0.0.0.0 --port 8000
