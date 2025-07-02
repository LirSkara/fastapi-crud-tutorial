# Простой CRUD API на FastAPI

Учебный проект для изучения FastAPI и CRUD операций с SQLite базой данных.

## 🚀 Быстрое развертывание на Raspberry Pi 5

**Полное развертывание одной командой:**

```bash
git clone https://github.com/LirSkara/fastapi-crud-tutorial.git
cd fastapi-crud-tutorial
sudo ./deploy_full.sh
```

Подробности в [QUICK_DEPLOY.md](QUICK_DEPLOY.md)

## Быстрый старт (локальная разработка)

1. **Установка зависимостей:**
```bash
./install.sh
```

2. **Запуск сервера:**
```bash
./start.sh
```

3. **Откройте в браузере:**
- 🌐 **Веб-интерфейс**: http://127.0.0.1:8000/static/index.html
- 📖 **API документация**: http://127.0.0.1:8000/docs
- 📚 **ReDoc**: http://127.0.0.1:8000/redoc

## Альтернативный запуск

Если скрипты не работают, можно запустить вручную:

```bash
# Создание виртуального окружения
python3 -m venv venv
source venv/bin/activate

# Установка зависимостей
pip install -r requirements.txt

# Запуск сервера
uvicorn main:app --reload
```

## Описание API

### Пользователи (Users)

- `POST /users/` - Создать нового пользователя
- `GET /users/` - Получить список всех пользователей
- `GET /users/{user_id}` - Получить пользователя по ID
- `PUT /users/{user_id}` - Обновить данные пользователя
- `DELETE /users/{user_id}` - Удалить пользователя
- `GET /users/email/{email}` - Получить пользователя по email

### Служебные эндпоинты

- `GET /` - Главная страница
- `GET /health` - Проверка состояния API

## Примеры использования

### Создание пользователя
```bash
curl -X POST "http://127.0.0.1:8000/users/" \
     -H "Content-Type: application/json" \
     -d '{
       "name": "Иван Иванов",
       "email": "ivan@example.com",
       "age": 25
     }'
```

### Получение списка пользователей
```bash
curl -X GET "http://127.0.0.1:8000/users/"
```

### Получение пользователя по ID
```bash
curl -X GET "http://127.0.0.1:8000/users/1"
```

### Обновление пользователя
```bash
curl -X PUT "http://127.0.0.1:8000/users/1" \
     -H "Content-Type: application/json" \
     -d '{
       "name": "Иван Петров",
       "age": 26
     }'
```

### Удаление пользователя
```bash
curl -X DELETE "http://127.0.0.1:8000/users/1"
```

## Структура проекта

- `main.py` - Основное приложение FastAPI с маршрутами
- `database.py` - Настройка базы данных и модели
- `schemas.py` - Pydantic схемы для валидации данных
- `crud.py` - Функции для работы с базой данных
- `requirements.txt` - Зависимости проекта
- `users.db` - SQLite база данных (создается автоматически)

## Развертывание на Raspberry Pi 5 (Ubuntu Server 24)

### Предварительные требования
- Raspberry Pi 5 с установленной Ubuntu Server 24
- SSH доступ к Pi
- Интернет соединение на Pi

### Шаг 1: Подключение к Raspberry Pi

```bash
# Подключитесь по SSH (замените USER и IP_ADDRESS на Пользователя и IP вашего Pi)
ssh USER@IP_ADDRESS

### Шаг 2: Установка зависимостей на Raspberry Pi

```bash
# Обновите систему
sudo apt update && sudo apt upgrade -y

# Установите Python 3 и pip (если не установлены)
sudo apt install python3 python3-pip python3-venv git -y

# Установите дополнительные пакеты
sudo apt install python3-dev build-essential -y
```

### Шаг 3: Клонирование и запуск проекта

```bash
# Клонируйте репозиторий (замените URL на ваш)
git clone https://github.com/LirSkara/fastapi-crud-tutorial.git
cd fastapi-crud-tutorial

# Сделайте скрипты исполняемыми
chmod +x install.sh start.sh

# Установите зависимости
./install.sh

# Запустите сервер
./start.sh
```

### Шаг 4: Настройка доступа по сети

По умолчанию сервер будет доступен только локально. Для доступа с других устройств:

1. **Найдите IP адрес Pi:**
```bash
ip addr show | grep inet
```

2. **Запустите сервер с доступом по сети:**
```bash
# Активируйте виртуальное окружение
source venv/bin/activate

# Запустите с доступом по всем интерфейсам
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

3. **Откройте в браузере на любом устройстве в сети:**
   - `http://IP_АДРЕС_PI:8000/static/index.html`
   - `http://IP_АДРЕС_PI:8000/docs`

### Шаг 5: Настройка автозапуска (systemd)

Создайте systemd сервис для автоматического запуска:

```bash
# Создайте файл сервиса
sudo nano /etc/systemd/system/fastapi-tutorial.service
```

Содержимое файла:
```ini
[Unit]
Description=FastAPI Tutorial Service
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/home/ubuntu/REPO_NAME
Environment=PATH=/home/ubuntu/REPO_NAME/venv/bin
ExecStart=/home/ubuntu/REPO_NAME/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always

[Install]
WantedBy=multi-user.target
```

Активируйте сервис:
```bash
# Перезагрузите systemd
sudo systemctl daemon-reload

# Включите автозапуск
sudo systemctl enable fastapi-tutorial

# Запустите сервис
sudo systemctl start fastapi-tutorial

# Проверьте статус
sudo systemctl status fastapi-tutorial
```

### Шаг 6: Настройка брандмауэра (опционально)

```bash
# Установите ufw если не установлен
sudo apt install ufw -y

# Разрешите SSH
sudo ufw allow ssh

# Разрешите порт 8000
sudo ufw allow 8000

# Включите брандмауэр
sudo ufw enable
```

### Полезные команды для управления

```bash
# Просмотр логов сервиса
sudo journalctl -u fastapi-tutorial -f

# Остановка сервиса
sudo systemctl stop fastapi-tutorial

# Перезапуск сервиса
sudo systemctl restart fastapi-tutorial

# Обновление проекта из GitHub
cd /home/ubuntu/REPO_NAME
git pull origin main
sudo systemctl restart fastapi-tutorial
```

## Что изучается

1. **Создание API** с помощью FastAPI
2. **CRUD операции** (Create, Read, Update, Delete)
3. **Работа с базой данных** через SQLAlchemy
4. **Валидация данных** с помощью Pydantic
5. **HTTP методы** и статус коды
6. **Документирование API** (автоматическая генерация)
7. **Обработка ошибок** и исключений
8. **Развертывание на сервере** (Raspberry Pi)
9. **Работа с Git и GitHub**
10. **Настройка systemd сервисов**
