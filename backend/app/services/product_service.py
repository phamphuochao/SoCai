from sqlalchemy.orm import Session

from app.core.exceptions import BusinessError
from app.models.category import Category
from app.models.product import Product
from app.schemas.product import ProductCreate, ProductUpdate


def get_product_by_id(db: Session, product_id: int, lock: bool = False) -> Product | None:
    """Lấy sản phẩm và khóa dòng khi database hỗ trợ SELECT FOR UPDATE."""
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
    is_active: bool | None = None,
    offset: int = 0,
    limit: int | None = None,
) -> list[Product]:
    query = db.query(Product)
    if keyword:
        like = f"%{keyword}%"
        query = query.filter((Product.name.ilike(like)) | (Product.sku.ilike(like)))
    if category_id is not None:
        query = query.filter(Product.category_id == category_id)
    if is_active is not None:
        query = query.filter(Product.is_active.is_(is_active))
    elif active_only:
        query = query.filter(Product.is_active.is_(True))
    if low_stock_only:
        query = query.filter(Product.stock_quantity <= Product.min_stock_level)
    query = query.order_by(Product.name, Product.id)
    if offset:
        query = query.offset(offset)
    if limit is not None:
        query = query.limit(limit)
    return query.all()


def create_product(db: Session, data: ProductCreate) -> Product:
    existing = db.query(Product).filter(Product.sku == data.sku).first()
    if existing:
        raise BusinessError(f"SKU '{data.sku}' đã tồn tại")
    if data.category_id is not None and db.query(Category).filter(Category.id == data.category_id).first() is None:
        raise BusinessError("Không tìm thấy danh mục")

    product = Product(**data.model_dump())
    db.add(product)
    db.commit()
    db.refresh(product)
    return product


def update_product(db: Session, product_id: int, data: ProductUpdate) -> Product:
    product = get_product_by_id(db, product_id)
    if product is None:
        raise BusinessError("Không tìm thấy sản phẩm")
    changes = data.model_dump(exclude_unset=True)
    category_id = changes.get("category_id")
    if category_id is not None and db.query(Category).filter(Category.id == category_id).first() is None:
        raise BusinessError("Không tìm thấy danh mục")
    for field, value in changes.items():
        setattr(product, field, value)
    db.commit()
    db.refresh(product)
    return product


def deactivate_product(db: Session, product_id: int) -> Product:
    """Ngừng bán sản phẩm nhưng vẫn giữ dữ liệu hóa đơn cũ."""
    product = get_product_by_id(db, product_id)
    if product is None:
        raise BusinessError("Không tìm thấy sản phẩm")
    product.is_active = False
    db.commit()
    db.refresh(product)
    return product
