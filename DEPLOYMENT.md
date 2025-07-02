# 🍓 Быстрое развертывание на Raspberry Pi 5

## Краткая инструкция

### На вашем компьютере:

1. **Загрузите проект в GitHub:**
```bash
cd /Users/lirskara/Desktop/sastapitest
git init
git add .
git commit -m "Initial commit"
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
