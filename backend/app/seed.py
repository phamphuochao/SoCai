"""
seed.py — "Người dựng văn phòng lần đầu, đặt sẵn bàn ghế mẫu"
Chạy 1 lần: `python -m app.seed`
Tạo tài khoản admin/staff, vài danh mục và sản phẩm mẫu để có dữ liệu demo ngay.
An toàn khi chạy lại nhiều lần — sẽ bỏ qua nếu dữ liệu đã tồn tại.
"""
from decimal import Decimal

from app.core.config import settings
from app.core.database import Base, engine, SessionLocal
from app.core.security import hash_password
from app import models  # noqa: F401
from app.models.category import Category
from app.models.product import Product
from app.models.user import User


def seed():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        # ---- Tài khoản ----
        if not db.query(User).filter(User.username == settings.ADMIN_USERNAME).first():
            db.add(User(
                username=settings.ADMIN_USERNAME,
                hashed_password=hash_password(settings.ADMIN_PASSWORD),
                full_name="Quản trị viên",
                role="admin",
            ))
            print(f"Đã tạo tài khoản admin: {settings.ADMIN_USERNAME}/{settings.ADMIN_PASSWORD}")

        if not db.query(User).filter(User.username == settings.STAFF_USERNAME).first():
            db.add(User(
                username=settings.STAFF_USERNAME,
                hashed_password=hash_password(settings.STAFF_PASSWORD),
                full_name="Nhân viên bán hàng",
                role="staff",
            ))
            print(f"Đã tạo tài khoản staff: {settings.STAFF_USERNAME}/{settings.STAFF_PASSWORD}")

        db.commit()

        # ---- Danh mục ----
        category_names = ["Đồ uống", "Thực phẩm", "Gia dụng", "Văn phòng phẩm"]
        categories = {}
        for name in category_names:
            cat = db.query(Category).filter(Category.name == name).first()
            if cat is None:
                cat = Category(name=name, description=f"Danh mục {name}")
                db.add(cat)
                db.flush()
            categories[name] = cat
        db.commit()

        # ---- Sản phẩm mẫu ----
        if db.query(Product).count() == 0:
            sample_products = [
                ("DU001", "Nước suối 500ml", "Đồ uống", 3000, 6000, 100, 10),
                ("DU002", "Trà xanh không độ", "Đồ uống", 6000, 10000, 80, 10),
                ("DU003", "Coca Cola lon", "Đồ uống", 7000, 12000, 60, 10),
                ("DU004", "Cà phê sữa đá đóng chai", "Đồ uống", 8000, 15000, 40, 5),
                ("DU005", "Sting dâu", "Đồ uống", 6500, 11000, 50, 10),
                ("TP001", "Mì tôm Hảo Hảo", "Thực phẩm", 3500, 5000, 200, 20),
                ("TP002", "Bánh Chocopie hộp", "Thực phẩm", 25000, 38000, 30, 5),
                ("TP003", "Snack Oishi", "Thực phẩm", 5000, 8000, 70, 10),
                ("TP004", "Sữa tươi Vinamilk 1L", "Thực phẩm", 28000, 34000, 45, 5),
                ("TP005", "Xúc xích Vissan", "Thực phẩm", 15000, 22000, 6, 10),  # tồn thấp để demo cảnh báo
                ("GD001", "Bột giặt Omo 800g", "Gia dụng", 45000, 58000, 25, 5),
                ("GD002", "Nước rửa chén Sunlight", "Gia dụng", 22000, 30000, 30, 5),
                ("GD003", "Khăn giấy Pulppy", "Gia dụng", 18000, 25000, 40, 5),
                ("GD004", "Bóng đèn LED 9W", "Gia dụng", 20000, 32000, 3, 5),  # tồn thấp
                ("GD005", "Pin tiểu AA (vỉ 4 viên)", "Gia dụng", 15000, 24000, 50, 10),
                ("VP001", "Bút bi Thiên Long", "Văn phòng phẩm", 2000, 4000, 150, 20),
                ("VP002", "Vở học sinh 96 trang", "Văn phòng phẩm", 6000, 10000, 90, 10),
                ("VP003", "Giấy A4 Double A (ram)", "Văn phòng phẩm", 65000, 85000, 20, 5),
                ("VP004", "Băng keo trong", "Văn phòng phẩm", 4000, 7000, 60, 10),
                ("VP005", "Kẹp giấy hộp", "Văn phòng phẩm", 5000, 9000, 35, 5),
            ]
            for sku, name, cat_name, cost, price, stock, min_stock in sample_products:
                db.add(Product(
                    sku=sku, name=name, category_id=categories[cat_name].id,
                    cost_price=Decimal(cost), selling_price=Decimal(price),
                    stock_quantity=stock, min_stock_level=min_stock,
                ))
            db.commit()
            print(f"Đã tạo {len(sample_products)} sản phẩm mẫu.")
        else:
            print("Sản phẩm đã có dữ liệu, bỏ qua bước tạo mẫu.")

        print("Seed hoàn tất.")
    finally:
        db.close()


if __name__ == "__main__":
    seed()
