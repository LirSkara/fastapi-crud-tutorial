# 📡 Настройка Wi-Fi точки доступа на Raspberry Pi 5

## Проблема одного Wi-Fi адаптера

Raspberry Pi 5 имеет только **один встроенный Wi-Fi адаптер**, который не может одновременно:
- Подключаться к роутеру (как клиент)
- Работать как точка доступа

## Варианты решения

### 🔌 Вариант 1: Ethernet + Wi-Fi AP (Рекомендуемый)

**Требования:**
- Ethernet кабель для подключения к роутеру
- Встроенный Wi-Fi для точки доступа

**Преимущества:**
- Стабильное соединение
- Не нужно дополнительное оборудование
- Простая настройка

**Запуск:**
```bash
sudo ./setup_wifi_ap.sh
```

### 📶 Вариант 2: Двойной Wi-Fi (USB адаптер)

**Требования:**
- USB Wi-Fi адаптер
- Встроенный Wi-Fi для интернета
- USB Wi-Fi для точки доступа

**Преимущества:**
- Полная беспроводная свобода
- Можно разместить Pi в любом месте

**Недостатки:**
- Нужен дополнительный USB Wi-Fi адаптер
- Более сложная настройка

**Запуск:**
```bash
sudo ./setup_dual_wifi.sh
```

## Рекомендуемые USB Wi-Fi адаптеры

Для точки доступа подходят адаптеры с чипами:
- **RTL8188EU** (дешевый, популярный)
- **RTL8192EU** (более мощный)
- **MT7601U** (хорошая совместимость)

Примеры моделей:
- TP-Link AC600 T2U Plus
- ASUS USB-N13
- Netgear A6100

## Схема подключения

### Вариант 1: Ethernet + Wi-Fi AP
```
[Роутер] ←--Ethernet--→ [Pi5] ←--Wi-Fi AP--→ [Планшет/Телефон]
```

### Вариант 2: Двойной Wi-Fi
```
[Роутер] ←--Wi-Fi--→ [Pi5 встроенный Wi-Fi]
                     [Pi5 USB Wi-Fi] ←--AP--→ [Планшет/Телефон]
```

## Пошаговая инструкция

### Для Ethernet + Wi-Fi AP:

1. **Подключите Pi к роутеру через Ethernet**
2. **Запустите настройку:**
   ```bash
   sudo ./setup_wifi_ap.sh
   ```
3. **Перезагрузите систему:**
   ```bash
   sudo reboot
   ```
4. **Подключитесь к точке доступа:**
   - SSID: `RaspberryPi-AP`
   - Пароль: `raspberry123`
   - IP Pi: `192.168.4.1`

### Для двойного Wi-Fi:

1. **Подключите USB Wi-Fi адаптер**
2. **Запустите настройку:**
   ```bash
   sudo ./setup_dual_wifi.sh
   ```
3. **Отредактируйте настройки роутера:**
   ```bash
   sudo nano /etc/netplan/99-dual-wifi.yaml
   ```
   Замените `ВАШ_РОУТЕР_SSID` и `ВАШ_ПАРОЛЬ_РОУТЕРА`

4. **Примените настройки:**
   ```bash
   sudo netplan apply
   sudo reboot
   ```

## Управление точкой доступа

```bash
# Запуск
sudo systemctl start wifi-ap        # для Ethernet варианта
sudo systemctl start dual-wifi      # для USB варианта

# Остановка
sudo systemctl stop wifi-ap
sudo systemctl stop dual-wifi

# Автозапуск
sudo systemctl enable wifi-ap
sudo systemctl enable dual-wifi

# Статус
sudo systemctl status wifi-ap
sudo systemctl status dual-wifi

# Просмотр логов
sudo journalctl -u wifi-ap -f
sudo journalctl -u dual-wifi -f
```

## Проверка работы

### Проверка интерфейсов:
```bash
ip addr show                    # показать все интерфейсы
iwconfig                       # показать Wi-Fi интерфейсы
```

### Проверка точки доступа:
```bash
sudo systemctl status hostapd  # статус точки доступа
sudo systemctl status dnsmasq  # статус DHCP сервера
```

### Проверка подключенных устройств:
```bash
cat /var/lib/dhcp/dhcpd.leases  # DHCP аренды
arp -a                          # ARP таблица
```

## Доступ к FastAPI

После настройки точки доступа:

1. **Подключитесь к сети `RaspberryPi-AP`**
2. **Откройте в браузере:**
   - Веб-интерфейс: `http://192.168.4.1:8000/static/index.html`
   - API документация: `http://192.168.4.1:8000/docs`

## Устранение проблем

### Не работает точка доступа:
```bash
# Проверка статуса сервисов
sudo systemctl status hostapd
sudo systemctl status dnsmasq

# Перезапуск сервисов
sudo systemctl restart hostapd
sudo systemctl restart dnsmasq
```

### Нет интернета на подключенных устройствах:
```bash
# Проверка IP forwarding
cat /proc/sys/net/ipv4/ip_forward  # должно быть 1

# Проверка iptables правил
sudo iptables -t nat -L
```

### USB Wi-Fi не определяется:
```bash
# Проверка USB устройств
lsusb

# Проверка Wi-Fi интерфейсов
iw dev

# Проверка драйверов
dmesg | grep -i wifi
```

## Безопасность

### Изменение пароля точки доступа:
```bash
sudo nano /etc/hostapd/hostapd.conf
# Измените строку: wpa_passphrase=новый_пароль
sudo systemctl restart hostapd
```

### Изменение SSID:
```bash
sudo nano /etc/hostapd/hostapd.conf
# Измените строку: ssid=Новое_Название
sudo systemctl restart hostapd
```

### Настройка фильтрации MAC адресов:
```bash
sudo nano /etc/hostapd/hostapd.conf
# Добавьте:
# macaddr_acl=1
# accept_mac_file=/etc/hostapd/accept_mac
```
