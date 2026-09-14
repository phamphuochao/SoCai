"""Khởi tạo FastAPI app và đăng ký các router."""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.database import Base, engine
from app.core.config import settings
from app import models  # noqa: F401
from app.routers import auth, categories, products, inventory, sales, expenses, reports

# Tạo schema khi ứng dụng khởi động nếu database chưa có bảng.
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Hệ thống quản lý doanh thu bán lẻ",
    description="API quản lý sản phẩm, bán hàng, tồn kho, chi phí và báo cáo.",
    version="1.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials="*" not in settings.CORS_ORIGINS,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health", tags=["Health"])
def health_check():
    return {"status": "ok"}


app.include_router(auth.router)
app.include_router(categories.router)
app.include_router(products.router)
app.include_router(inventory.router)
app.include_router(sales.router)
app.include_router(expenses.router)
app.include_router(reports.router)
