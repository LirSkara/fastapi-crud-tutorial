import requests
import json

# Базовый URL API
BASE_URL = "http://127.0.0.1:8000"

def test_api():
    """Простые тесты для проверки работы API"""
    
    print("🧪 Тестирование FastAPI CRUD операций\n")
    
    # 1. Проверка здоровья API
    print("1. Проверка состояния API...")
    response = requests.get(f"{BASE_URL}/health")
    print(f"   Статус: {response.status_code}")
    print(f"   Ответ: {response.json()}\n")
    
    # 2. Создание пользователя
    print("2. Создание нового пользователя...")
    user_data = {
        "name": "Анна Смирнова",
        "email": "anna@example.com",
        "age": 28
    }
    response = requests.post(f"{BASE_URL}/users/", json=user_data)
    print(f"   Статус: {response.status_code}")
    if response.status_code == 201:
        created_user = response.json()
        print(f"   Создан пользователь: {created_user}")
        user_id = created_user["id"]
    else:
        print(f"   Ошибка: {response.json()}")
        return
    print()
    
    # 3. Получение всех пользователей
    print("3. Получение списка пользователей...")
    response = requests.get(f"{BASE_URL}/users/")
    print(f"   Статус: {response.status_code}")
    users = response.json()
    print(f"   Найдено пользователей: {len(users)}")
    for user in users:
        print(f"   - {user['name']} ({user['email']})")
    print()
    
    # 4. Получение пользователя по ID
    print(f"4. Получение пользователя с ID {user_id}...")
    response = requests.get(f"{BASE_URL}/users/{user_id}")
    print(f"   Статус: {response.status_code}")
    user = response.json()
    print(f"   Пользователь: {user['name']}, возраст: {user['age']}")
    print()
    
    # 5. Обновление пользователя
    print(f"5. Обновление пользователя с ID {user_id}...")
    update_data = {"age": 30}
    response = requests.put(f"{BASE_URL}/users/{user_id}", json=update_data)
    print(f"   Статус: {response.status_code}")
    updated_user = response.json()
    print(f"   Обновлен возраст: {updated_user['age']}")
    print()
    
    # 6. Поиск по email
    print("6. Поиск пользователя по email...")
    response = requests.get(f"{BASE_URL}/users/email/{user_data['email']}")
    print(f"   Статус: {response.status_code}")
    user = response.json()
    print(f"   Найден: {user['name']}")
    print()
    
    # 7. Удаление пользователя
    print(f"7. Удаление пользователя с ID {user_id}...")
    response = requests.delete(f"{BASE_URL}/users/{user_id}")
    print(f"   Статус: {response.status_code}")
    print(f"   Ответ: {response.json()}")
    print()
    
    print("✅ Тестирование завершено!")

if __name__ == "__main__":
    try:
        test_api()
    except requests.exceptions.ConnectionError:
        print("❌ Не удается подключиться к API.")
        print("   Убедитесь, что сервер запущен: uvicorn main:app --reload")
