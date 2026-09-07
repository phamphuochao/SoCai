"""
core/config.py
Đọc cấu hình từ file .env (hoặc biến môi trường) và cung cấp cho toàn bộ ứng dụng
qua một đối tượng `settings` duy nhất. Không nơi nào khác trong code nên đọc
biến môi trường trực tiếp — luôn import `settings` từ đây.
"""
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    DATABASE_URL: str = "sqlite:///./retail.db"
    SECRET_KEY: str = "change-me-in-.env"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 480

    ADMIN_USERNAME: str = "admin"
    ADMIN_PASSWORD: str = "admin123"
    STAFF_USERNAME: str = "staff"
    STAFF_PASSWORD: str = "staff123"

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")


settings = Settings()
