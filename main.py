from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.staticfiles import StaticFiles
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List
import crud
from database import get_db
from schemas import UserCreate, UserUpdate, UserResponse

# Создание приложения FastAPI
app = FastAPI(
    title="Простой CRUD API",
    description="Учебный проект для изучения FastAPI и CRUD операций",
    version="1.0.0"
)

# Настройка CORS для работы с веб-интерфейсом
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Подключение статических файлов
app.mount("/static", StaticFiles(directory="static"), name="static")

@app.get("/", tags=["Root"])
async def root():
    """Главная страница"""
    return {
        "message": "Добро пожаловать в учебный CRUD API!",
        "docs": "Перейдите на /docs для интерактивной документации",
        "web_interface": "Откройте /static/index.html для веб-интерфейса"
    }

# CRUD операции для пользователей

@app.post("/users/", response_model=UserResponse, status_code=status.HTTP_201_CREATED, tags=["Users"])
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    """Создать нового пользователя"""
    # Проверяем, что пользователь с таким email не существует
    db_user = crud.get_user_by_email(db, email=user.email)
    if db_user:
        raise HTTPException(
            status_code=400, 
            detail="Пользователь с таким email уже существует"
        )
    return crud.create_user(db=db, user=user)

@app.get("/users/", response_model=List[UserResponse], tags=["Users"])
def read_users(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Получить список пользователей"""
    users = crud.get_users(db, skip=skip, limit=limit)
    return users

@app.get("/users/{user_id}", response_model=UserResponse, tags=["Users"])
def read_user(user_id: int, db: Session = Depends(get_db)):
    """Получить пользователя по ID"""
    db_user = crud.get_user(db, user_id=user_id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="Пользователь не найден")
    return db_user

@app.put("/users/{user_id}", response_model=UserResponse, tags=["Users"])
def update_user(user_id: int, user_update: UserUpdate, db: Session = Depends(get_db)):
    """Обновить данные пользователя"""
    db_user = crud.update_user(db, user_id=user_id, user_update=user_update)
    if db_user is None:
        raise HTTPException(status_code=404, detail="Пользователь не найден")
    return db_user

@app.delete("/users/{user_id}", tags=["Users"])
def delete_user(user_id: int, db: Session = Depends(get_db)):
    """Удалить пользователя"""
    success = crud.delete_user(db, user_id=user_id)
    if not success:
        raise HTTPException(status_code=404, detail="Пользователь не найден")
    return {"message": "Пользователь успешно удален"}

# Дополнительные эндпоинты для обучения

@app.get("/users/email/{email}", response_model=UserResponse, tags=["Users"])
def read_user_by_email(email: str, db: Session = Depends(get_db)):
    """Получить пользователя по email"""
    db_user = crud.get_user_by_email(db, email=email)
    if db_user is None:
        raise HTTPException(status_code=404, detail="Пользователь не найден")
    return db_user

@app.get("/health", tags=["Health"])
def health_check():
    """Проверка состояния API"""
    return {"status": "OK", "message": "API работает корректно"}
