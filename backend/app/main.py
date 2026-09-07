"""
main.py — "Nút bấm khởi động cả văn phòng"
File duy nhất bạn chạy để mở toàn bộ hệ thống: `uvicorn app.main:app --reload`
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.database import Base, engine
from app import models  # noqa: F401 — import để SQLAlchemy biết đủ các bảng
from app.routers import auth, categories, products, inventory, sales, expenses, reports

# Tạo bảng nếu chưa có. Với đồ án, dùng create_all() là đủ (không cần Alembic).
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Hệ thống quản lý doanh thu bán lẻ",
    description="Backend FastAPI cho đồ án — xem chi tiết từng endpoint tại /docs",
    version="1.0.0",
)

# Cho phép Flutter (web/desktop/mobile) gọi API từ origin khác trong lúc phát triển.
# Với đồ án, mở rộng "*" là chấp nhận được; siết lại nếu triển khai thật.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
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
