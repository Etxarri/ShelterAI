from sqlalchemy import create_engine, Column, Integer, String, Boolean, Float, DateTime, Text, text, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from typing import List, Optional
from .config import settings

# Crear engine de SQLAlchemy
engine = create_engine(settings.DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# ===== MODELOS DE BASE DE DATOS =====

class Refugee(Base):
    """Modelo de refugiado en la base de datos"""
    __tablename__ = "refugees"
    
    id = Column(Integer, primary_key=True, index=True)
    first_name = Column(String(100), nullable=False)
    last_name = Column(String(100), nullable=False)
    age = Column(Integer)
    gender = Column(String(20))
    nationality = Column(String(100))
    family_size = Column(Integer, default=1)
    has_children = Column(Boolean, default=False)
    children_count = Column(Integer, default=0)
    medical_conditions = Column(String(500))
    has_disability = Column(Boolean, default=False)
    psychological_distress = Column(Boolean, default=False)
    requires_medical_facilities = Column(Boolean, default=False)
    languages_spoken = Column(String(500))
    status = Column(String(50), default="refugee")
    special_needs = Column(String(500))
    vulnerability_score = Column(Float)
    created_at = Column(DateTime)
    updated_at = Column(DateTime)


class Shelter(Base):
    """Modelo de refugio en la base de datos"""
    __tablename__ = "shelters"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    address = Column(String(500))
    phone_number = Column(String(20))
    email = Column(String(100))
    max_capacity = Column(Integer)
    current_occupancy = Column(Integer)
    has_medical_facilities = Column(Boolean)
    has_childcare = Column(Boolean)
    has_disability_access = Column(Boolean)
    languages_spoken = Column(String(200))
    latitude = Column(Float)
    longitude = Column(Float)
    shelter_type = Column(String(50))
    services_offered = Column(String(500))
    created_at = Column(DateTime)
    updated_at = Column(DateTime)


class Assignment(Base):
    """Modelo de asignación de refugiado a refugio"""
    __tablename__ = "assignments"
    
    id = Column(Integer, primary_key=True, index=True)
    refugee_id = Column(Integer, ForeignKey("refugees.id"), nullable=False)
    shelter_id = Column(Integer, ForeignKey("shelters.id"), nullable=False)
    status = Column(String(50), default="pending")
    assigned_at = Column(DateTime)
    notes = Column(String(500))
    created_at = Column(DateTime)
    updated_at = Column(DateTime)


# ===== FUNCIONES DE BASE DE DATOS =====

def get_db():
    """Dependency para obtener sesión de base de datos"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def get_available_shelters(db) -> List[Shelter]:
    """
    Obtiene todos los refugios con capacidad disponible
    """
    shelters = db.query(Shelter).filter(
        Shelter.current_occupancy < Shelter.max_capacity
    ).all()
    return shelters


def get_shelter_by_id(db, shelter_id: int) -> Optional[Shelter]:
    """
    Obtiene un refugio específico por su ID
    """
    return db.query(Shelter).filter(Shelter.id == shelter_id).first()


def check_database_connection() -> bool:
    """
    Verifica si la conexión a la base de datos funciona
    """
    try:
        db = SessionLocal()
        db.execute(text("SELECT 1"))
        db.close()
        return True
    except Exception as e:
        print(f"Error conectando a la base de datos: {e}")
        return False


def get_all_shelters(db) -> List[Shelter]:
    """
    Obtiene todos los refugios (incluso los llenos)
    """
    return db.query(Shelter).all()
