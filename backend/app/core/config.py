"""Cấu hình ứng dụng đọc từ biến môi trường và file .env."""
from typing import Literal

from pydantic import model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    ENVIRONMENT: Literal["development", "test", "production"] = "development"
    DATABASE_URL: str = "sqlite:///./retail.db"
    SECRET_KEY: str = "change-me-in-.env"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 480
    CORS_ORIGINS: list[str] = ["*"]

    ADMIN_USERNAME: str = "admin"
    ADMIN_PASSWORD: str = "admin123"
    STAFF_USERNAME: str = "staff"
    STAFF_PASSWORD: str = "staff123"

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    @model_validator(mode="after")
    def require_safe_production_secret(self):
        weak_secrets = {"", "change-me-in-.env", "doi-chuoi-nay-thanh-chuoi-bi-mat-that-dai-va-random"}
        if self.ENVIRONMENT == "production" and self.SECRET_KEY in weak_secrets:
            raise ValueError("Production yêu cầu SECRET_KEY riêng, dài và ngẫu nhiên")
        return self


settings = Settings()
