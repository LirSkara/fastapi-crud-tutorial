#!/bin/bash

# 🍓 Настройка Raspberry Pi 5 с двумя Wi-Fi адаптерами
# Ubuntu Server 24.04
# ТРЕБОВАНИЯ: Внешний USB Wi-Fi адаптер для точки доступа

echo "🍓 Настройка двойного Wi-Fi: встроенный для интернета + USB для AP..."
echo ""
echo "📋 Требования:"
echo "   1. USB Wi-Fi адаптер (будет использован как точка доступа)"
echo "   2. Встроенный Wi-Fi (останется для подключения к роутеру)"
echo ""

# Проверка запуска под root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Запустите скрипт с правами root: sudo $0"
    exit 1
fi

# Проверка наличия USB Wi-Fi адаптера
echo "🔍 Поиск Wi-Fi адаптеров..."
wifi_interfaces=$(iw dev | awk '$1=="Interface"{print $2}')
interface_count=$(echo "$wifi_interfaces" | wc -l)

echo "Найдено Wi-Fi интерфейсов: $interface_count"
echo "$wifi_interfaces"

if [ "$interface_count" -lt 2 ]; then
    echo "❌ ОШИБКА: Нужно минимум 2 Wi-Fi адаптера!"
    echo "   Подключите USB Wi-Fi адаптер."
    echo ""
    echo "💡 Альтернативы:"
    echo "   1. Используйте Ethernet + встроенный Wi-Fi (запустите setup_wifi_ap.sh)"
    echo "   2. Купите USB Wi-Fi адаптер (рекомендуем с чипом RTL8188EU или аналогичным)"
    exit 1
fi

# Определение интерфейсов
builtin_wifi="wlan0"  # Встроенный
usb_wifi="wlan1"      # USB адаптер

echo ""
echo "📡 Конфигурация:"
echo "   🌍 $builtin_wifi (встроенный) - для подключения к роутеру"
echo "   📱 $usb_wifi (USB) - точка доступа"
echo ""

# Обновление системы
echo "📦 Обновление системы..."
apt update && apt upgrade -y

# Установка необходимых пакетов
echo "📦 Установка hostapd и dnsmasq..."
apt install -y hostapd dnsmasq iptables-persistent

# Остановка сервисов для настройки
systemctl stop hostapd
systemctl stop dnsmasq

# Настройка netplan для двух Wi-Fi интерфейсов
echo "🌐 Настройка сетевых интерфейсов..."
cat > /etc/netplan/99-dual-wifi.yaml << EOF
network:
  version: 2
  wifis:
    $builtin_wifi:
      dhcp4: true
      access-points:
        "ВАШ_РОУТЕР_SSID":
          password: "ВАШ_ПАРОЛЬ_РОУТЕРА"
    $usb_wifi:
      dhcp4: false
      addresses:
        - 192.168.4.1/24
EOF

echo "⚠️  ВАЖНО: Отредактируйте файл /etc/netplan/99-dual-wifi.yaml"
echo "   Замените ВАШ_РОУТЕР_SSID и ВАШ_ПАРОЛЬ_РОУТЕРА на реальные данные!"

# Настройка hostapd для USB адаптера
echo "📡 Настройка hostapd для USB Wi-Fi..."
cat > /etc/hostapd/hostapd.conf << EOF
# USB Wi-Fi интерфейс для точки доступа
interface=$usb_wifi

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

# Настройка dnsmasq для USB Wi-Fi
echo "🌐 Настройка DHCP сервера..."
cp /etc/dnsmasq.conf /etc/dnsmasq.conf.backup

cat > /etc/dnsmasq.conf << EOF
# USB Wi-Fi интерфейс для DHCP
interface=$usb_wifi

# Диапазон IP адресов для клиентов
dhcp-range=192.168.4.10,192.168.4.50,255.255.255.0,24h

# DNS сервер
dhcp-option=3,192.168.4.1
dhcp-option=6,8.8.8.8,8.8.4.4

# Отключить DHCP для встроенного Wi-Fi
no-dhcp-interface=$builtin_wifi

# Логирование
log-queries
log-dhcp

# Локальный домен
domain=local
EOF

# Настройка IP forwarding
echo "🔄 Настройка IP forwarding..."
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf

# Настройка iptables для NAT между USB Wi-Fi и встроенным Wi-Fi
echo "🔥 Настройка iptables (NAT)..."
iptables -F
iptables -t nat -F

# NAT для раздачи интернета с встроенного Wi-Fi на USB Wi-Fi
iptables -t nat -A POSTROUTING -o $builtin_wifi -j MASQUERADE
iptables -A FORWARD -i $builtin_wifi -o $usb_wifi -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i $usb_wifi -o $builtin_wifi -j ACCEPT

# Сохранение правил iptables
iptables-save > /etc/iptables/rules.v4

# Включение сервисов
echo "🚀 Включение сервисов..."
systemctl enable hostapd
systemctl enable dnsmasq

# Создание скрипта для запуска
cat > /usr/local/bin/start-dual-wifi << 'EOF'
#!/bin/bash
echo "🍓 Запуск двойного Wi-Fi режима..."

# Включение IP forwarding
sysctl -w net.ipv4.ip_forward=1

# Применение правил iptables
iptables-restore < /etc/iptables/rules.v4

# Применение сетевых настроек
netplan apply

# Запуск сервисов
systemctl start hostapd
systemctl start dnsmasq

echo "✅ Двойной Wi-Fi режим запущен!"
echo "🌍 Интернет: встроенный Wi-Fi (подключен к роутеру)"
echo "📱 Точка доступа: USB Wi-Fi (RaspberryPi-AP)"
echo "🔑 Пароль: raspberry123"
echo "🌐 IP шлюза: 192.168.4.1"
echo "🚀 FastAPI доступен по: http://192.168.4.1:8000"
EOF

chmod +x /usr/local/bin/start-dual-wifi

# Создание systemd сервиса
cat > /etc/systemd/system/dual-wifi.service << 'EOF'
[Unit]
Description=Dual WiFi Mode (Internet + AP)
After=network.target
Wants=hostapd.service dnsmasq.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/start-dual-wifi
RemainAfterExit=yes
StandardOutput=journal

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

echo ""
echo "🎉 Настройка двойного Wi-Fi завершена!"
echo ""
echo "⚠️  СЛЕДУЮЩИЕ ШАГИ:"
echo "   1. Отредактируйте /etc/netplan/99-dual-wifi.yaml"
echo "      Укажите SSID и пароль вашего роутера"
echo "   2. Примените настройки: sudo netplan apply"
echo "   3. Перезагрузите систему: sudo reboot"
echo ""
echo "📡 После настройки:"
echo "   🌍 $builtin_wifi - подключение к интернету"
echo "   📱 $usb_wifi - точка доступа RaspberryPi-AP"
echo ""
echo "🚀 Управление:"
echo "   sudo systemctl enable dual-wifi  # автозапуск"
echo "   sudo systemctl start dual-wifi   # запуск"
