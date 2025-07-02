#!/bin/bash

# Скрипт для настройки systemd сервиса на Raspberry Pi

echo "⚙️ Настройка systemd сервиса для автозапуска..."

# Получаем текущую директорию
CURRENT_DIR=$(pwd)
USERNAME=$(whoami)

echo "📁 Рабочая директория: $CURRENT_DIR"
echo "👤 Пользователь: $USERNAME"

# Создаем файл сервиса с правильными путями
cat > fastapi-tutorial.service << EOF
[Unit]
Description=FastAPI CRUD Tutorial Service
After=network.target
Wants=network.target

[Service]
Type=simple
User=$USERNAME
Group=$USERNAME
WorkingDirectory=$CURRENT_DIR
Environment=PATH=$CURRENT_DIR/venv/bin
ExecStart=$CURRENT_DIR/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000
ExecReload=/bin/kill -s HUP \$MAINPID
Restart=always
RestartSec=3
KillMode=mixed
TimeoutStopSec=5

[Install]
WantedBy=multi-user.target
EOF

# Копируем файл сервиса в systemd
echo "📋 Копирование файла сервиса..."
sudo cp fastapi-tutorial.service /etc/systemd/system/

# Перезагружаем systemd
echo "🔄 Перезагрузка systemd..."
sudo systemctl daemon-reload

# Включаем автозапуск
echo "✅ Включение автозапуска..."
sudo systemctl enable fastapi-tutorial

# Запускаем сервис
echo "🚀 Запуск сервиса..."
sudo systemctl start fastapi-tutorial

# Проверяем статус
echo ""
echo "📊 Статус сервиса:"
sudo systemctl status fastapi-tutorial --no-pager

echo ""
echo "✅ Настройка systemd сервиса завершена!"
echo ""
echo "🔧 Полезные команды:"
echo "   sudo systemctl status fastapi-tutorial   # Проверить статус"
echo "   sudo systemctl stop fastapi-tutorial     # Остановить"
echo "   sudo systemctl start fastapi-tutorial    # Запустить"
echo "   sudo systemctl restart fastapi-tutorial  # Перезапустить"
echo "   sudo journalctl -u fastapi-tutorial -f   # Просмотр логов"
