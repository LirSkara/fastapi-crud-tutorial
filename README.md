# 🍓 FastAPI CRUD Tutorial для Raspberry Pi 5

Полный учебный проект для изучения FastAPI и развертывания на Raspberry Pi 5 с Wi-Fi точкой доступа.

## ⚡ Быстрый старт для Raspberry Pi 5

### Развертывание одной командой

```bash
git clone https://github.com/LirSkara/fastapi-crud-tutorial.git
cd fastapi-crud-tutorial
sudo ./deploy.sh
```

**Это всё!** 🎉 Скрипт автоматически:
- Настроит всю систему
- Запустит FastAPI сервер 
- Запустит Wi-Fi точку доступа
- Настроит автозапуск при перезагрузке

### Результат развертывания

После выполнения команды будет доступно:

#### 📡 Wi-Fi точка доступа
- **Название сети:** `RBPi`
- **Пароль:** `11223344`
- **IP диапазон:** `192.168.4.10-192.168.4.50`

#### 🌐 FastAPI сервер
- **Веб-интерфейс:** `http://192.168.4.1:8000/static/index.html`
- **API документация:** `http://192.168.4.1:8000/docs`
- **ReDoc:** `http://192.168.4.1:8000/redoc`

## 💻 Локальная разработка

> **Примечание:** `start.sh` используется только для **локальной разработки** на вашем компьютере. Для Raspberry Pi используйте `deploy.sh`.

### Быстрый запуск

```bash
# Клонирование проекта
git clone https://github.com/LirSkara/fastapi-crud-tutorial.git
cd fastapi-crud-tutorial

# Запуск (автоматически создает venv и устанавливает зависимости)
./start.sh
```

### Ручная установка

```bash
# Создание виртуального окружения
python3 -m venv venv
source venv/bin/activate

# Установка зависимостей
pip install -r requirements.txt

# Запуск сервера
uvicorn main:app --reload
```

### Доступ к локальному серверу

- **Веб-интерфейс:** http://127.0.0.1:8000/static/index.html
- **API документация:** http://127.0.0.1:8000/docs
- **ReDoc:** http://127.0.0.1:8000/redoc

## 📚 Описание API

### Пользователи (Users)

| Метод | Эндпоинт | Описание |
|-------|----------|----------|
| `POST` | `/users/` | Создать нового пользователя |
| `GET` | `/users/` | Получить список всех пользователей |
| `GET` | `/users/{user_id}` | Получить пользователя по ID |
| `PUT` | `/users/{user_id}` | Обновить данные пользователя |
| `DELETE` | `/users/{user_id}` | Удалить пользователя |
| `GET` | `/users/email/{email}` | Получить пользователя по email |

### Служебные эндпоинты

| Метод | Эндпоинт | Описание |
|-------|----------|----------|
| `GET` | `/` | Главная страница |
| `GET` | `/health` | Проверка состояния API |

## 🔧 Примеры использования API

### Создание пользователя
```bash
curl -X POST "http://192.168.4.1:8000/users/" \
     -H "Content-Type: application/json" \
     -d '{
       "name": "Иван Иванов",
       "email": "ivan@example.com",
       "age": 25
     }'
```

### Получение всех пользователей
```bash
curl -X GET "http://192.168.4.1:8000/users/"
```

### Получение пользователя по ID
```bash
curl -X GET "http://192.168.4.1:8000/users/1"
```

### Обновление пользователя
```bash
curl -X PUT "http://192.168.4.1:8000/users/1" \
     -H "Content-Type: application/json" \
     -d '{
       "name": "Иван Петров",
       "age": 26
     }'
```

### Удаление пользователя
```bash
curl -X DELETE "http://192.168.4.1:8000/users/1"
```

## 📁 Структура проекта

```
fastapi-crud-tutorial/
├── 📄 main.py              # Основное приложение FastAPI
├── 🗄️ database.py          # Настройка базы данных SQLAlchemy
├── 📋 schemas.py           # Pydantic схемы для валидации
├── 🔄 crud.py              # CRUD операции с базой данных
├── 📦 requirements.txt     # Python зависимости
├── 🧪 test_api.py          # Тесты API
├── 🗃️ users.db             # SQLite база данных (создается автоматически)
├── 🌐 static/
│   └── index.html          # Веб-интерфейс для тестирования API
├── 🚀 deploy.sh             # Полное развертывание на Pi
├── ⚡ start.sh               # Локальный запуск для разработки
├── 🌐 test_remote_client.py # Пример удаленного клиента
└── 📖 README.md            # Эта документация
```

## 🌐 Удаленное подключение

### CORS настройки

Проект **уже настроен** для удаленных подключений:

- ✅ **CORS включен** для всех источников
- ✅ **Сервер принимает** подключения на `0.0.0.0:8000`
- ✅ **Все HTTP методы** разрешены
- ✅ **Все заголовки** разрешены

### Подключение с удаленного клиента

1. **Определите IP адрес сервера:**
   ```bash
   # На сервере
   hostname -I
   ```

2. **Используйте клиент (Python example):**
   ```python
   import requests
   
   # Замените на IP вашего сервера
   BASE_URL = "http://192.168.1.100:8000"
   
   # Тест подключения
   response = requests.get(f"{BASE_URL}/")
   print(response.json())
   
   # Создание пользователя
   user_data = {"name": "Test", "email": "test@example.com", "age": 25}
   response = requests.post(f"{BASE_URL}/users/", json=user_data)
   print(response.json())
   ```

3. **Тестирование готовым клиентом:**
   ```bash
   # Отредактируйте IP в файле
   nano test_remote_client.py
   
   # Запустите тест
   python test_remote_client.py
   ```

### Устранение проблем подключения

| Проблема | Решение |
|----------|---------|
| Подключение отклонено | Проверьте IP адрес и порт 8000 |
| CORS ошибки | Уже настроен, проверьте браузер |
| Timeout | Проверьте файервол на сервере |
| 404 ошибки | Убедитесь что сервер запущен |

### Безопасность

⚠️ **Внимание:** Текущие настройки (`allow_origins=["*"]`) разрешают подключение с любых источников. Для production использования рекомендуется:

```python
# В main.py замените на:
app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://yourdomain.com", "http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["*"],
)
```

## 🍓 Развертывание на Raspberry Pi 5

### Требования

- **Hardware:** Raspberry Pi 5
- **OS:** Ubuntu Server 24.04
- **Network:** Ethernet подключение к роутеру
- **Access:** SSH доступ к Pi

### Архитектура

```
[Интернет] ←--→ [Роутер] ←--Ethernet--→ [Pi5 eth0]
                                         [Pi5 wlan0] ←--Wi-Fi AP--→ [Планшеты/Телефоны]
                                         [FastAPI :8000]
```

### Автоматическое развертывание

1. **Подключитесь к Pi по SSH:**
   ```bash
   ssh ubuntu@IP_RASPBERRY_PI
   ```

2. **Клонируйте и разверните проект:**
   ```bash
   git clone https://github.com/LirSkara/fastapi-crud-tutorial.git
   cd fastapi-crud-tutorial
   sudo ./deploy.sh
   ```

3. **Подключитесь с планшета к Wi-Fi:**
   - Найдите сеть `RBPi`
   - Введите пароль `11223344`
   - Откройте `http://192.168.4.1:8000`

**Никаких дополнительных команд не нужно!** Сервер запустится автоматически.

### Что настраивает deploy.sh

1. ✅ **Обновляет систему Ubuntu**
2. ✅ **Устанавливает Python зависимости** (venv, pip, packages)
3. ✅ **Настраивает FastAPI проект** с автозапуском
4. ✅ **Настраивает Wi-Fi точку доступа** (hostapd, dnsmasq, iptables)
5. ✅ **Создает systemd сервисы** для автозапуска
6. ✅ **Запускает все сервисы** (FastAPI + Wi-Fi AP)

**После выполнения скрипта система полностью готова к работе!**

## 🔧 Управление системой на Pi

### Проверка статуса

```bash
# Статус FastAPI сервера
sudo systemctl status fastapi-tutorial

# Статус Wi-Fi точки доступа
sudo systemctl status wifi-ap

# Статус hostapd (Wi-Fi AP)
sudo systemctl status hostapd

# Статус dnsmasq (DHCP)
sudo systemctl status dnsmasq
```

### Управление сервисами

```bash
# Перезапуск FastAPI
sudo systemctl restart fastapi-tutorial

# Перезапуск Wi-Fi точки доступа
sudo systemctl restart wifi-ap

# Остановка/запуск сервисов
sudo systemctl stop/start service_name
```

### Просмотр логов

```bash
# Логи FastAPI сервера
sudo journalctl -u fastapi-tutorial -f

# Логи Wi-Fi точки доступа
sudo journalctl -u wifi-ap -f

# Системные логи
sudo dmesg | tail
```

### Обновление проекта

```bash
# Получить обновления из GitHub
git pull origin main

# Перезапустить FastAPI сервер
sudo systemctl restart fastapi-tutorial
```

## 🌐 Сетевая конфигурация

### IP адресация

- **Ethernet (eth0):** Получает IP от роутера (DHCP)
- **Wi-Fi AP (wlan0):** Статический IP `192.168.4.1`
- **Клиенты Wi-Fi:** Диапазон `192.168.4.10-192.168.4.50`

### Доступ к сервисам

| Сервис | Ethernet | Wi-Fi AP |
|--------|----------|----------|
| FastAPI | `http://ETH_IP:8000` | `http://192.168.4.1:8000` |
| Веб-интерфейс | `http://ETH_IP:8000/static/index.html` | `http://192.168.4.1:8000/static/index.html` |
| API Docs | `http://ETH_IP:8000/docs` | `http://192.168.4.1:8000/docs` |

### Проверка сети

```bash
# Показать все сетевые интерфейсы
ip addr show

# Показать Wi-Fi интерфейсы
iwconfig

# Показать подключенные Wi-Fi клиенты
sudo iw dev wlan0 station dump

# Проверить DHCP аренды
sudo cat /var/lib/dhcp/dhcpd.leases
```

## 🔒 Безопасность

### Изменение пароля Wi-Fi

```bash
sudo nano /etc/hostapd/hostapd.conf
# Измените: wpa_passphrase=новый_пароль
sudo systemctl restart hostapd
```

### Изменение названия сети

```bash
sudo nano /etc/hostapd/hostapd.conf
# Измените: ssid=Новое_Название
sudo systemctl restart hostapd
```

### Настройка брандмауэра

```bash
# Установка ufw
sudo apt install ufw

# Разрешить SSH
sudo ufw allow ssh

# Разрешить HTTP (FastAPI)
sudo ufw allow 8000

# Включить брандмауэр
sudo ufw enable
```

## 🛠️ Устранение проблем

### FastAPI не запускается

```bash
# Проверить логи
sudo journalctl -u fastapi-tutorial -n 50

# Проверить Python зависимости
cd /path/to/project
source venv/bin/activate
pip list

# Ручной запуск для отладки
source venv/bin/activate
uvicorn main:app --host 0.0.0.0 --port 8000
```

### Wi-Fi точка доступа не работает

```bash
# Проверить статус hostapd
sudo systemctl status hostapd

# Проверить конфигурацию
sudo hostapd -d /etc/hostapd/hostapd.conf

# Проверить Wi-Fi интерфейс
iwconfig wlan0

# Перезапустить сетевые настройки
sudo netplan apply
```

### Нет интернета на подключенных устройствах

```bash
# Проверить IP forwarding
cat /proc/sys/net/ipv4/ip_forward  # должно быть 1

# Проверить iptables правила
sudo iptables -t nat -L

# Проверить Ethernet подключение
ping google.com
```

## 📖 Что изучают студенты

### Backend разработка
1. **FastAPI framework** - современный Python веб-фреймворк
2. **RESTful API** - проектирование REST API
3. **CRUD операции** - Create, Read, Update, Delete
4. **SQLAlchemy ORM** - работа с базой данных
5. **Pydantic** - валидация и сериализация данных
6. **SQLite** - локальная база данных

### DevOps и системное администрирование
1. **Linux (Ubuntu Server)** - администрирование сервера
2. **systemd** - управление сервисами
3. **Networking** - настройка сети, Wi-Fi, DHCP
4. **Git** - система контроля версий
5. **SSH** - удаленное подключение
6. **Автоматизация** - скрипты развертывания

### Мобильная разработка
1. **HTTP клиенты** - работа с API из мобильных приложений
2. **JSON** - формат обмена данными
3. **REST API** - интеграция с внешними сервисами
4. **Тестирование API** - инструменты и методы

## 📞 Поддержка

При возникновении проблем:

1. **Проверьте логи:** `sudo journalctl -u fastapi-tutorial -f`
2. **Перезапустите сервисы:** `sudo systemctl restart fastapi-tutorial`
3. **Проверьте сеть:** `ip addr show`
4. **Проверьте процессы:** `ps aux | grep uvicorn`

## 📄 Лицензия

Этот проект создан в образовательных целях и распространяется свободно.

## 🤝 Вклад в проект

Приветствуются pull requests и issues для улучшения проекта!

---

**Создано для обучения студентов современной веб-разработке и системному администрированию** 🎓
