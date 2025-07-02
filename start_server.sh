#!/bin/bash

# Скрипт запуска сервера на Raspberry Pi с доступом по сети

echo "🍓 Запуск FastAPI сервера на Raspberry Pi..."
echo ""

# Проверяем виртуальное окружение
if [ ! -d "venv" ]; then
    echo "❌ Виртуальное окружение не найдено!"
    echo "   Сначала запустите: ./deploy_rpi.sh"
    exit 1
fi

# Активируем виртуальное окружение
source venv/bin/activate

# Получаем IP адрес
IP_ADDRESS=$(ip route get 1 | awk '{print $7; exit}')

echo "🌐 IP адрес сервера: $IP_ADDRESS"
echo "🚀 Запуск FastAPI сервера..."
echo ""
echo "📍 Доступные адреса:"
echo "   🌍 Веб-интерфейс:    http://$IP_ADDRESS:8000/static/index.html"
echo "   📖 API документация: http://$IP_ADDRESS:8000/docs"
echo "   📚 ReDoc:            http://$IP_ADDRESS:8000/redoc"
echo "   🏠 Локальный доступ: http://127.0.0.1:8000"
echo ""
echo "Нажмите Ctrl+C для остановки сервера"
echo ""

# Запускаем сервер с доступом по всем интерфейсам
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
