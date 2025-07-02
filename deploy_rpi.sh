#!/bin/bash

# Скрипт для развертывания на Raspberry Pi 5 / Ubuntu Server 24

echo "🍓 FastAPI CRUD - Скрипт развертывания для Raspberry Pi"
echo "=================================================="

# Проверка на какой системе запускается
if [[ "$OSTYPE" == "linux-gnu"* ]] && [[ $(uname -m) == "aarch64" ]]; then
    echo "✅ Обнаружена ARM64 система (вероятно Raspberry Pi)"
else
    echo "⚠️  Предупреждение: Скрипт оптимизирован для Raspberry Pi на ARM64"
fi

echo ""
echo "📦 Обновление системы..."
sudo apt update && sudo apt upgrade -y

echo ""
echo "🔧 Установка необходимых пакетов..."
sudo apt install python3 python3-pip python3-venv python3-dev build-essential git nano curl -y

echo ""
echo "📁 Создание виртуального окружения..."
python3 -m venv venv

echo ""
echo "🔄 Активация виртуального окружения..."
source venv/bin/activate

echo ""
echo "📚 Установка Python зависимостей..."
pip install --upgrade pip
pip install -r requirements.txt

echo ""
echo "🗄️ Инициализация базы данных..."
python3 -c "from database import Base, engine; Base.metadata.create_all(bind=engine); print('База данных инициализирована')"

echo ""
echo "🌐 Определение IP адреса..."
IP_ADDRESS=$(ip route get 1 | awk '{print $7; exit}')
echo "   Ваш IP адрес: $IP_ADDRESS"

echo ""
echo "✅ Развертывание завершено!"
echo ""
echo "🚀 Для запуска сервера выполните:"
echo "   ./start_server.sh"
echo ""
echo "🌍 После запуска API будет доступно по адресам:"
echo "   - Веб-интерфейс: http://$IP_ADDRESS:8000/static/index.html"
echo "   - API документация: http://$IP_ADDRESS:8000/docs"
echo "   - Локально: http://127.0.0.1:8000"
