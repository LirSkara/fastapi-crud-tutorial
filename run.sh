#!/bin/bash

echo "🚀 Запуск FastAPI echo ""
echo "🌐 FastAPI сервер запускается..."
echo ""
echo "📚 Доступные ссылки:"
echo "   🏠 Локально (на Pi):     http://localhost:8000"
echo "   🌍 Ethernet сеть:        http://$LOCAL_IP:8000"
echo "   📡 Wi-Fi точка доступа:  http://192.168.4.1:8000"
echo ""
echo "📱 Для планшетов (через Wi-Fi AP):"
echo "   🎨 Веб-интерфейс:        http://192.168.4.1:8000/static/index.html"
echo "   📖 API документация:     http://192.168.4.1:8000/docs"
echo ""
echo "💡 IP 192.168.4.1:8000 работает даже без интернета!"
echo ""
echo "Нажмите Ctrl+C для остановки сервера"
echo ""ho ""

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
echo "   � Wi-Fi AP:        http://192.168.4.1:8000 (работает без интернета)"
echo "   �📖 Документация:    http://localhost:8000/docs"
echo "   🎨 Веб-интерфейс:   http://192.168.4.1:8000/static/index.html"
echo ""
echo "💡 Для планшетов используйте: http://192.168.4.1:8000"
echo ""
echo "Нажмите Ctrl+C для остановки сервера"
echo ""

# Запускаем FastAPI с поддержкой удаленных подключений
uvicorn main:app --reload --host 0.0.0.0 --port 8000
