from sqlalchemy.orm import Session

from app.core.exceptions import BusinessError
from app.models.product import Product
from app.schemas.product import ProductCreate, ProductUpdate


def get_product_by_id(db: Session, product_id: int, lock: bool = False) -> Product | None:
    """
    lock=True được dùng khi cần khóa dòng trong lúc trừ/cộng tồn kho, để 2 giao dịch
    cùng lúc không đọc cùng một số tồn kho "cũ" rồi cùng ghi đè sai (race condition).
    Lưu ý: SQLite không hỗ trợ khóa dòng thật sự như PostgreSQL — with_for_update()
    trên SQLite gần như không có tác dụng khóa, nhưng vẫn giữ tham số này để code
    dễ chuyển sang PostgreSQL sau này (mục 3.3 kế hoạch mở rộng) mà không cần sửa logic.
    """
    query = db.query(Product).filter(Product.id == product_id)
    if lock and db.bind.dialect.name != "sqlite":
        query = query.with_for_update()
    return query.first()


def list_products(
    db: Session,
    keyword: str | None = None,
    category_id: int | None = None,
    active_only: bool = False,
    low_stock_only: bool = False,
) -> list[Product]:
    query = db.query(Product)
    if keyword:
        like = f"%{keyword}%"
        query = query.filter((Product.name.ilike(like)) | (Product.sku.ilike(like)))
    if category_id is not None:
        query = query.filter(Product.category_id == category_id)
    if active_only:
        query = query.filter(Product.is_active.is_(True))
    if low_stock_only:
        query = query.filter(Product.stock_quantity <= Product.min_stock_level)
    return query.order_by(Product.name).all()


def create_product(db: Session, data: ProductCreate) -> Product:
    existing = db.query(Product).filter(Product.sku == data.sku).first()
    if existing:
        raise BusinessError(f"SKU '{data.sku}' đã tồn tại")

    product = Product(**data.model_dump())
    db.add(product)
    db.commit()
    db.refresh(product)
    return product


def update_product(db: Session, product_id: int, data: ProductUpdate) -> Product:
    product = get_product_by_id(db, product_id)
    if product is None:
        raise BusinessError("Không tìm thấy sản phẩm")
    for field, value in data.model_dump(exclude_unset=True).items():
        setattr(product, field, value)
    db.commit()
    db.refresh(product)
    return product


def deactivate_product(db: Session, product_id: int) -> Product:
    """Không xóa cứng sản phẩm đã có thể xuất hiện trong hóa đơn — chỉ chuyển ngừng bán."""
    product = get_product_by_id(db, product_id)
    if product is None:
        raise BusinessError("Không tìm thấy sản phẩm")
    product.is_active = False
    db.commit()
    db.refresh(product)
    return product
