"""
Пример клиента для тестирования удаленного подключения к FastAPI серверу

Этот клиент автоматически ищет доступный сервер по следующим адресам:
- http://192.168.4.1:8000 (Wi-Fi AP)
- http://192.168.1.100:8000 (Ethernet, замените на реальный IP)
- http://localhost:8000 (локальное тестирование)

CORS настроен в main.py для поддержки удаленных подключений:
- allow_origins=["*"] - разрешены все источники
- allow_methods=["*"] - разрешены все HTTP методы
- allow_headers=["*"] - разрешены все заголовки

Использование:
    python test_remote_client.py
"""

import requests
import json

# Настройки подключения - автоматическое определение
POSSIBLE_URLS = [
    "http://192.168.4.1:8000",    # Wi-Fi AP адрес
    "http://192.168.1.100:8000",  # Пример Ethernet адреса
    "http://localhost:8000"       # Локальное тестирование
]

def find_server():
    """Поиск доступного сервера"""
    for url in POSSIBLE_URLS:
        try:
            response = requests.get(f"{url}/health", timeout=2)
            if response.status_code == 200:
                print(f"✅ Сервер найден: {url}")
                return url
        except:
            continue
    print("❌ Сервер не найден по всем адресам")
    return None

# Определение BASE_URL
BASE_URL = find_server()

def test_connection():
    """Тест подключения к серверу"""
    if not BASE_URL:
        print("❌ Сервер недоступен")
        return False
        
    try:
        response = requests.get(f"{BASE_URL}/")
        print("✅ Подключение успешно!")
        print(f"Ответ: {response.json()}")
        return True
    except requests.exceptions.RequestException as e:
        print(f"❌ Ошибка подключения: {e}")
        return False

def test_health():
    """Тест health check"""
    if not BASE_URL:
        print("❌ Сервер недоступен")
        return False
        
    try:
        response = requests.get(f"{BASE_URL}/health")
        print("✅ Health check успешен!")
        print(f"Статус: {response.json()}")
        return True
    except requests.exceptions.RequestException as e:
        print(f"❌ Ошибка health check: {e}")
        return False

def create_test_user():
    """Создание тестового пользователя"""
    if not BASE_URL:
        print("❌ Сервер недоступен")
        return None
        
    user_data = {
        "name": "Тест Пользователь",
        "email": "test@example.com",
        "age": 25
    }
    
    try:
        response = requests.post(f"{BASE_URL}/users/", json=user_data)
        if response.status_code == 201:
            print("✅ Пользователь создан!")
            print(f"Данные: {response.json()}")
            return response.json()
        else:
            print(f"⚠️ Ошибка создания: {response.status_code}")
            print(f"Ответ: {response.text}")
            return None
    except requests.exceptions.RequestException as e:
        print(f"❌ Ошибка создания пользователя: {e}")
        return None

def get_users():
    """Получение списка пользователей"""
    try:
        response = requests.get(f"{BASE_URL}/users/")
        if response.status_code == 200:
            users = response.json()
            print(f"✅ Получено пользователей: {len(users)}")
            for user in users:
                print(f"  - {user['name']} ({user['email']})")
            return users
        else:
            print(f"⚠️ Ошибка получения: {response.status_code}")
            return []
    except requests.exceptions.RequestException as e:
        print(f"❌ Ошибка получения пользователей: {e}")
        return []

def main():
    """Основная функция тестирования"""
    print("🧪 Тестирование удаленного подключения к FastAPI")
    print(f"🌐 Сервер: {BASE_URL}")
    print("=" * 50)
    
    # Тест подключения
    print("\n1. Тестирование подключения...")
    if not test_connection():
        print("❌ Не удалось подключиться к серверу")
        print("\n💡 Проверьте:")
        print("   - Запущен ли сервер")
        print("   - Правильно ли указан IP адрес")
        print("   - Доступен ли порт 8000")
        print("   - Настроены ли правила файервола")
        return
    
    # Тест health check
    print("\n2. Тестирование health check...")
    test_health()
    
    # Тест получения пользователей
    print("\n3. Получение списка пользователей...")
    get_users()
    
    # Тест создания пользователя
    print("\n4. Создание тестового пользователя...")
    user = create_test_user()
    
    if user:
        # Повторное получение списка
        print("\n5. Повторное получение списка пользователей...")
        get_users()
    
    print("\n✅ Тестирование завершено!")

if __name__ == "__main__":
    main()
