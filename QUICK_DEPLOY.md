# 🚀 Быстрое развертывание "одной командой"

## Для новой установки на Raspberry Pi 5

### Шаг 1: Клонирование проекта

```bash
git clone https://github.com/LirSkara/fastapi-crud-tutorial.git
cd fastapi-crud-tutorial
```

### Шаг 2: Полное развертывание одной командой

```bash
sudo ./deploy_full.sh
```

**Это всё!** 🎉

Скрипт автоматически:
- ✅ Обновит систему
- ✅ Установит все зависимости
- ✅ Настроит FastAPI проект
- ✅ Настроит Wi-Fi точку доступа
- ✅ Настроит автозапуск всех сервисов
- ✅ Запустит все сервисы

## Результат

После выполнения команды будет доступно:

### 📡 Wi-Fi точка доступа
- **Название сети:** `RaspberryPi-AP`
- **Пароль:** `raspberry123`

### 🌐 FastAPI сервер
- **Веб-интерфейс:** `http://192.168.4.1:8000/static/index.html`
- **API документация:** `http://192.168.4.1:8000/docs`
- **ReDoc:** `http://192.168.4.1:8000/redoc`

## Управление

```bash
# Проверка статуса всех сервисов
sudo systemctl status fastapi-tutorial
sudo systemctl status wifi-ap

# Перезапуск FastAPI
sudo systemctl restart fastapi-tutorial

# Перезапуск Wi-Fi точки доступа
sudo systemctl restart wifi-ap

# Просмотр логов
sudo journalctl -u fastapi-tutorial -f
sudo journalctl -u wifi-ap -f
```

## Обновление проекта

```bash
# Получить обновления из GitHub
git pull origin main

# Перезапустить сервис
sudo systemctl restart fastapi-tutorial
```

## Требования

- Raspberry Pi 5 с Ubuntu Server 24.04
- Ethernet подключение к роутеру (для интернета)
- SSH доступ к Pi

## Архитектура

```
[Роутер] ←--Ethernet--→ [Pi eth0] ← интернет
                         [Pi wlan0] ←--Wi-Fi AP--→ [Планшеты/Телефоны]
                         [FastAPI :8000]
```
