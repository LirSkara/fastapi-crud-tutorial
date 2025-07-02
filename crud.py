from sqlalchemy.orm import Session
from database import User
from schemas import UserCreate, UserUpdate

# Функции для работы с базой данных

def get_user(db: Session, user_id: int):
    """Получить пользователя по ID"""
    return db.query(User).filter(User.id == user_id).first()

def get_user_by_email(db: Session, email: str):
    """Получить пользователя по email"""
    return db.query(User).filter(User.email == email).first()

def get_users(db: Session, skip: int = 0, limit: int = 100):
    """Получить список пользователей с пагинацией"""
    return db.query(User).offset(skip).limit(limit).all()

def create_user(db: Session, user: UserCreate):
    """Создать нового пользователя"""
    db_user = User(
        name=user.name,
        email=user.email,
        age=user.age
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def update_user(db: Session, user_id: int, user_update: UserUpdate):
    """Обновить данные пользователя"""
    db_user = db.query(User).filter(User.id == user_id).first()
    if not db_user:
        return None
    
    # Обновляем только переданные поля
    if user_update.name is not None:
        db_user.name = user_update.name
    if user_update.email is not None:
        db_user.email = user_update.email
    if user_update.age is not None:
        db_user.age = user_update.age
    
    db.commit()
    db.refresh(db_user)
    return db_user

def delete_user(db: Session, user_id: int):
    """Удалить пользователя"""
    db_user = db.query(User).filter(User.id == user_id).first()
    if db_user:
        db.delete(db_user)
        db.commit()
        return True
    return False
