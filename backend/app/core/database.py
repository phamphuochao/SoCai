"""
core/database.py
"Cầu nối tới kho hồ sơ thật" — mở kết nối tới file SQLite và quản lý phiên
làm việc (session) với database. Mọi file khác cần dùng database phải đi qua
đây (import engine / SessionLocal / Base / get_db), không tự tạo kết nối riêng.
"""
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

from app.core.config import settings

# check_same_thread=False: cần thiết vì FastAPI có thể gọi từ nhiều thread khác nhau
# khi dùng SQLite (mặc định SQLite chỉ cho phép 1 thread truy cập 1 connection).
engine = create_engine(
    settings.DATABASE_URL,
    connect_args={"check_same_thread": False} if settings.DATABASE_URL.startswith("sqlite") else {},
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()


def get_db():
    """
    Dependency cho FastAPI: mở 1 session cho mỗi request, tự đóng lại sau khi xong.
    Dùng trong router như: db: Session = Depends(get_db)
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
