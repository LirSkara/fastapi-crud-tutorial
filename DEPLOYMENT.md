# 🍓 Быстрое развертывание на Raspberry Pi 5

## Краткая инструкция

### На вашем компьютере:

1. **Загрузите проект в GitHub:**
```bash
cd /Users/lirskara/Desktop/sastapitest
git init
git add .
git commit -m "🚀 Учебный проект: простой CRUD API на FastAPI"
git remote add origin https://github.com/YOUR_USERNAME/REPO_NAME.git
git push -u origin main
```

### На Raspberry Pi 5:

2. **Подключитесь по SSH:**
```bash
ssh ubuntu@IP_RASPBERRY_PI
```

3. **Клонируйте и разверните:**
```bash
git clone https://github.com/YOUR_USERNAME/REPO_NAME.git
cd REPO_NAME
chmod +x *.sh
./deploy_rpi.sh
```

4. **Запустите сервер:**
```bash
./start_server.sh
```

5. **Настройте автозапуск:**
```bash
./setup_service.sh
```

## 📡 Настройка точки доступа Wi-Fi (опционально)

Если нужен доступ через Wi-Fi с планшета/телефона:

### Вариант 1: Ethernet + Wi-Fi AP (Рекомендуемый)
```bash
# Подключите Pi к роутеру через Ethernet кабель
sudo ./setup_wifi_ap.sh
sudo reboot
```

### Вариант 2: Двойной Wi-Fi (нужен USB Wi-Fi адаптер)
```bash
# Подключите USB Wi-Fi адаптер
sudo ./setup_dual_wifi.sh
# Отредактируйте настройки роутера в /etc/netplan/99-dual-wifi.yaml
sudo netplan apply
sudo reboot
```

**Подключение к точке доступа:**
- SSID: `RaspberryPi-AP`
- Пароль: `raspberry123`

Подробности в [WIFI_SETUP.md](WIFI_SETUP.md)

### Готово! 🎉

- **Веб-интерфейс:** `http://IP_RASPBERRY_PI:8000/static/index.html`
- **API документация:** `http://IP_RASPBERRY_PI:8000/docs`

## Полезные команды

```bash
# Обновление проекта
git pull origin main
sudo systemctl restart fastapi-tutorial

# Просмотр логов
sudo journalctl -u fastapi-tutorial -f

# Управление сервисом
sudo systemctl status/start/stop/restart fastapi-tutorial
```
