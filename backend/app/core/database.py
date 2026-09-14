"""Khởi tạo SQLAlchemy engine, session factory và database dependency."""
from sqlalchemy import create_engine, event
from sqlalchemy.orm import sessionmaker, declarative_base

from app.core.config import settings

# FastAPI có thể dùng cùng SQLite connection từ nhiều worker thread.
is_sqlite = settings.DATABASE_URL.startswith("sqlite")
engine = create_engine(
    settings.DATABASE_URL,
    connect_args={"check_same_thread": False, "timeout": 30} if is_sqlite else {},
)


if is_sqlite:
    @event.listens_for(engine, "connect")
    def configure_sqlite_connection(dbapi_connection, _connection_record):
        """Cấu hình tính toàn vẹn dữ liệu và thời gian chờ ghi cho SQLite."""
        cursor = dbapi_connection.cursor()
        cursor.execute("PRAGMA foreign_keys=ON")
        cursor.execute("PRAGMA busy_timeout=30000")
        if ":memory:" not in settings.DATABASE_URL:
            cursor.execute("PRAGMA journal_mode=WAL")
        cursor.close()

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()


def get_db():
    """Cấp một database session cho mỗi request và đóng session khi hoàn tất."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
