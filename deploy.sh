#!/bin/bash

# 🚀 Универсальный скрипт полного развертывания FastAPI проекта
# Raspberry Pi 5 + Ubuntu Server 24.04

echo "🍓 Полное развертывание FastAPI проекта на Raspberry Pi 5"
echo "============================================================"
echo ""

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция для вывода с цветом
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[ℹ]${NC} $1"
}

# Проверка прав root
if [ "$EUID" -ne 0 ]; then
    print_error "Запустите скрипт с правами root: sudo $0"
    exit 1
fi

echo "🎯 Этот скрипт выполнит:"
echo "   1. Обновление системы"
echo "   2. Установка зависимостей Python"
echo "   3. Настройку FastAPI проекта"
echo "   4. Настройку Wi-Fi точки доступа (Ethernet + Wi-Fi AP)"
echo "   5. Настройку автозапуска сервисов"
echo "   6. Запуск всех сервисов"
echo ""

read -p "Продолжить? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "Развертывание отменено."
    exit 0
fi

# Получение пути к проекту
PROJECT_DIR=$(pwd)
print_info "Папка проекта: $PROJECT_DIR"

# 1. Обновление системы
echo ""
print_info "Шаг 1/6: Обновление системы..."
apt update && apt upgrade -y
print_status "Система обновлена"

# 2. Установка системных зависимостей
echo ""
print_info "Шаг 2/6: Установка системных зависимостей..."
apt install -y python3 python3-pip python3-venv git curl \
               hostapd dnsmasq iptables-persistent \
               wireless-tools iw net-tools
print_status "Системные зависимости установлены"

# 3. Настройка FastAPI проекта
echo ""
print_info "Шаг 3/6: Настройка FastAPI проекта..."

# Создание виртуального окружения от имени пользователя
REAL_USER=$(who am i | awk '{print $1}')
if [ -z "$REAL_USER" ]; then
    REAL_USER="ubuntu"
fi

print_info "Настройка для пользователя: $REAL_USER"

# Установка зависимостей Python
if [ -f "requirements.txt" ]; then
    sudo -u $REAL_USER bash -c "
        cd '$PROJECT_DIR'
        if [ ! -d 'venv' ]; then
            python3 -m venv venv
        fi
        source venv/bin/activate
        pip install --upgrade pip
        pip install -r requirements.txt
    "
    print_status "Python зависимости установлены"
else
    print_error "Файл requirements.txt не найден!"
    exit 1
fi

# Настройка прав на файлы
chown -R $REAL_USER:$REAL_USER "$PROJECT_DIR"
chmod +x "$PROJECT_DIR"/*.sh
print_status "Права на файлы настроены"

# 4. Настройка Wi-Fi точки доступа
echo ""
print_info "Шаг 4/6: Настройка Wi-Fi точки доступа..."

# Проверка Ethernet подключения
if ip link show eth0 | grep -q "state UP"; then
    print_status "Ethernet подключение активно"
else
    print_warning "Ethernet не подключен - подключите кабель к роутеру"
fi

# Настройка netplan для Ethernet + Wi-Fi AP
cat > /etc/netplan/99-wifi-ap.yaml << 'EOF'
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
      optional: true
  wifis:
    wlan0:
      dhcp4: false
      addresses:
        - 192.168.4.1/24
EOF

chmod 600 /etc/netplan/99-wifi-ap.yaml

# Настройка hostapd
cat > /etc/hostapd/hostapd.conf << 'EOF'
interface=wlan0
driver=nl80211
ssid=RPBPi-AP
hw_mode=g
channel=7
max_num_sta=10
wpa=2
wpa_passphrase=11223344
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
country_code=RU
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
EOF

echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' > /etc/default/hostapd

# Настройка dnsmasq
cp /etc/dnsmasq.conf /etc/dnsmasq.conf.backup 2>/dev/null || true

cat > /etc/dnsmasq.conf << 'EOF'
interface=wlan0
dhcp-range=192.168.4.10,192.168.4.50,255.255.255.0,24h
dhcp-option=3,192.168.4.1
dhcp-option=6,8.8.8.8,8.8.4.4
no-dhcp-interface=eth0
log-queries
log-dhcp
domain=local
EOF

# Настройка IP forwarding
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf

# Настройка iptables
iptables -F
iptables -t nat -F
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
iptables-save > /etc/iptables/rules.v4

print_status "Wi-Fi точка доступа настроена"

# 5. Настройка автозапуска сервисов
echo ""
print_info "Шаг 5/6: Настройка автозапуска сервисов..."

# Размаскировка и включение hostapd
systemctl unmask hostapd >/dev/null 2>&1 || true
systemctl enable hostapd
systemctl enable dnsmasq

# Создание systemd сервиса для FastAPI
cat > /etc/systemd/system/fastapi-tutorial.service << EOF
[Unit]
Description=FastAPI Tutorial Service
After=network.target

[Service]
Type=simple
User=$REAL_USER
WorkingDirectory=$PROJECT_DIR
Environment=PATH=$PROJECT_DIR/venv/bin
ExecStart=$PROJECT_DIR/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Создание systemd сервиса для Wi-Fi точки доступа
cat > /etc/systemd/system/wifi-ap.service << 'EOF'
[Unit]
Description=WiFi Access Point
After=network.target
Wants=hostapd.service dnsmasq.service

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'sysctl -w net.ipv4.ip_forward=1; iptables-restore < /etc/iptables/rules.v4; systemctl start hostapd; systemctl start dnsmasq'
RemainAfterExit=yes
ExecStop=/bin/bash -c 'systemctl stop hostapd; systemctl stop dnsmasq'
StandardOutput=journal

[Install]
WantedBy=multi-user.target
EOF

# Перезагрузка systemd и включение сервисов
systemctl daemon-reload
systemctl enable fastapi-tutorial
systemctl enable wifi-ap

print_status "Автозапуск сервисов настроен"

# 6. Запуск сервисов
echo ""
print_info "Шаг 6/6: Запуск сервисов..."

# Применение сетевых настроек
netplan apply
sleep 2

# Запуск Wi-Fi точки доступа
systemctl start wifi-ap
sleep 3

# Запуск FastAPI сервера
systemctl start fastapi-tutorial
sleep 2

print_status "Все сервисы запущены"

# Проверка статуса сервисов
echo ""
print_info "Проверка статуса сервисов:"

if systemctl is-active --quiet wifi-ap; then
    print_status "Wi-Fi точка доступа: АКТИВНА"
else
    print_warning "Wi-Fi точка доступа: НЕАКТИВНА"
fi

if systemctl is-active --quiet fastapi-tutorial; then
    print_status "FastAPI сервер: АКТИВЕН"
else
    print_warning "FastAPI сервер: НЕАКТИВЕН"
fi

if systemctl is-active --quiet hostapd; then
    print_status "hostapd: АКТИВЕН"
else
    print_warning "hostapd: НЕАКТИВЕН"
fi

if systemctl is-active --quiet dnsmasq; then
    print_status "dnsmasq: АКТИВЕН"
else
    print_warning "dnsmasq: НЕАКТИВЕН"
fi

# Получение IP адресов
ETH_IP=$(ip addr show eth0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1 | head -1)
WIFI_IP=$(ip addr show wlan0 | grep 'inet ' | awk '{print $2}' | cut -d/ -f1 | head -1)

echo ""
echo "🎉 РАЗВЕРТЫВАНИЕ ЗАВЕРШЕНО!"
echo "=========================="
echo ""
echo "📋 Информация о системе:"
echo "   🌍 Ethernet IP: ${ETH_IP:-не подключен}"
echo "   📡 Wi-Fi AP IP: ${WIFI_IP:-192.168.4.1}"
echo ""
echo "📱 Wi-Fi точка доступа:"
echo "   📡 Название сети: RaspberryPi-AP"
echo "   🔑 Пароль: raspberry123"
echo "   🌐 IP диапазон: 192.168.4.10-192.168.4.50"
echo ""
echo "🚀 FastAPI доступен по адресам:"
if [ ! -z "$ETH_IP" ]; then
echo "   🌍 Ethernet: http://$ETH_IP:8000"
fi
echo "   📱 Wi-Fi AP: http://192.168.4.1:8000"
echo "   📖 Документация: http://192.168.4.1:8000/docs"
echo "   🎨 Веб-интерфейс: http://192.168.4.1:8000/static/index.html"
echo ""
echo "🔧 Управление сервисами:"
echo "   sudo systemctl status/start/stop/restart fastapi-tutorial"
echo "   sudo systemctl status/start/stop/restart wifi-ap"
echo ""
echo "📱 Для подключения с планшета:"
echo "   1. Найдите сеть 'RaspberryPi-AP'"
echo "   2. Введите пароль 'raspberry123'"
echo "   3. Откройте http://192.168.4.1:8000"
echo ""
print_status "Система готова к работе!"
