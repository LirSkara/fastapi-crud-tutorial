#!/bin/bash

# 🍓 Настройка Raspberry Pi 5 как точки доступа Wi-Fi
# Ubuntu Server 24.04
# ТРЕБОВАНИЯ: Pi должен быть подключен к интернету через Ethernet!

echo "🍓 Настройка Raspberry Pi 5 как точки доступа Wi-Fi..."
echo "⚠️  ВАЖНО: Подключите Raspberry Pi к интернету через Ethernet кабель!"
echo "   Wi-Fi адаптер будет использоваться только как точка доступа."
echo ""

# Проверка запуска под root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Запустите скрипт с правами root: sudo $0"
    exit 1
fi

# Проверка Ethernet подключения
echo "🔍 Проверка Ethernet подключения..."
if ! ip link show eth0 | grep -q "state UP"; then
    echo "⚠️  ВНИМАНИЕ: Ethernet интерфейс (eth0) не активен!"
    echo "   Подключите кабель к роутеру для доступа в интернет."
    read -p "Продолжить настройку? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Настройка отменена."
        exit 1
    fi
fi

# Обновление системы
echo "📦 Обновление системы..."
apt update && apt upgrade -y

# Установка необходимых пакетов
echo "📦 Установка hostapd и dnsmasq..."
apt install -y hostapd dnsmasq iptables-persistent

# Остановка сервисов для настройки
systemctl stop hostapd
systemctl stop dnsmasq

# Настройка статического IP для wlan0
echo "🌐 Настройка статического IP для Wi-Fi интерфейса..."

# Настройка netplan конфигурации для Ethernet + WiFi AP
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

# Применение настроек netplan
netplan apply

# Настройка hostapd
echo "📡 Настройка hostapd..."
cat > /etc/hostapd/hostapd.conf << 'EOF'
# Интерфейс для точки доступа
interface=wlan0

# Драйвер
driver=nl80211

# Название сети (SSID)
ssid=RaspberryPi-AP

# Режим работы (g = 2.4GHz)
hw_mode=g

# Канал
channel=7

# Максимальное количество подключений
max_num_sta=10

# Включить WPA2
wpa=2
wpa_passphrase=raspberry123
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP

# Страна (для соответствия регулированию)
country_code=RU

# Прочие настройки
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
EOF

# Указание файла конфигурации для hostapd
echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' >> /etc/default/hostapd

# Настройка dnsmasq (DHCP и DNS)
echo "🌐 Настройка DHCP сервера..."

# Резервная копия оригинального файла
cp /etc/dnsmasq.conf /etc/dnsmasq.conf.backup

cat > /etc/dnsmasq.conf << 'EOF'
# Интерфейс для DHCP
interface=wlan0

# Диапазон IP адресов для клиентов
dhcp-range=192.168.4.10,192.168.4.50,255.255.255.0,24h

# DNS сервер
dhcp-option=3,192.168.4.1
dhcp-option=6,8.8.8.8,8.8.4.4

# Отключить DNS для проводного интерфейса
no-dhcp-interface=eth0

# Логирование
log-queries
log-dhcp

# Локальный домен
domain=local
EOF

# Настройка IP forwarding
echo "🔄 Настройка IP forwarding..."
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf

# Настройка iptables для NAT
echo "🔥 Настройка iptables (NAT)..."

# Очистка существующих правил
iptables -F
iptables -t nat -F

# Настройка NAT для раздачи интернета
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT

# Сохранение правил iptables
iptables-save > /etc/iptables/rules.v4

# Включение сервисов
echo "🚀 Включение сервисов..."
systemctl enable hostapd
systemctl enable dnsmasq

# Создание скрипта для запуска точки доступа
cat > /usr/local/bin/start-wifi-ap << 'EOF'
#!/bin/bash
echo "🍓 Запуск точки доступа Wi-Fi..."

# Включение IP forwarding
sysctl -w net.ipv4.ip_forward=1

# Применение правил iptables
iptables-restore < /etc/iptables/rules.v4

# Запуск сервисов
systemctl start hostapd
systemctl start dnsmasq

echo "✅ Точка доступа запущена!"
echo "📡 Сеть: RaspberryPi-AP"
echo "🔑 Пароль: raspberry123"
echo "🌐 IP шлюза: 192.168.4.1"
echo "🚀 FastAPI доступен по: http://192.168.4.1:8000"
EOF

chmod +x /usr/local/bin/start-wifi-ap

# Создание скрипта для остановки точки доступа
cat > /usr/local/bin/stop-wifi-ap << 'EOF'
#!/bin/bash
echo "🛑 Остановка точки доступа Wi-Fi..."

systemctl stop hostapd
systemctl stop dnsmasq

echo "✅ Точка доступа остановлена!"
EOF

chmod +x /usr/local/bin/stop-wifi-ap

# Создание systemd сервиса для автозапуска
cat > /etc/systemd/system/wifi-ap.service << 'EOF'
[Unit]
Description=WiFi Access Point
After=network.target
Wants=hostapd.service dnsmasq.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/start-wifi-ap
RemainAfterExit=yes
ExecStop=/usr/local/bin/stop-wifi-ap
StandardOutput=journal

[Install]
WantedBy=multi-user.target
EOF

# Перезагрузка systemd
systemctl daemon-reload

echo ""
echo "🎉 Настройка завершена!"
echo ""
echo "📋 Информация о точке доступа:"
echo "   📡 Название сети (SSID): RaspberryPi-AP"
echo "   🔑 Пароль: raspberry123"
echo "   🌐 IP адрес Pi: 192.168.4.1"
echo "   📱 Диапазон IP для устройств: 192.168.4.10-192.168.4.50"
echo "   🌍 Интернет через: Ethernet (eth0)"
echo ""
echo "🚀 Команды управления:"
echo "   Запуск:     sudo systemctl start wifi-ap"
echo "   Остановка:  sudo systemctl stop wifi-ap"
echo "   Автозапуск: sudo systemctl enable wifi-ap"
echo "   Статус:     sudo systemctl status wifi-ap"
echo ""
echo "⚠️  ВАЖНО:"
echo "   1. Подключите Ethernet кабель к роутеру для интернета"
echo "   2. ПЕРЕЗАГРУЗИТЕ СИСТЕМУ: sudo reboot"
echo ""
echo "📱 После перезагрузки подключитесь к сети RaspberryPi-AP"
echo "🌐 FastAPI будет доступен по адресу: http://192.168.4.1:8000"
