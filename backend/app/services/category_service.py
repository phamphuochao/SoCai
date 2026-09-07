from sqlalchemy.orm import Session

from app.core.exceptions import BusinessError
from app.models.category import Category
from app.schemas.category import CategoryCreate, CategoryUpdate


def list_categories(db: Session, active_only: bool = False) -> list[Category]:
    query = db.query(Category)
    if active_only:
        query = query.filter(Category.is_active.is_(True))
    return query.order_by(Category.name).all()


def create_category(db: Session, data: CategoryCreate) -> Category:
    existing = db.query(Category).filter(Category.name == data.name).first()
    if existing:
        raise BusinessError(f"Danh mục '{data.name}' đã tồn tại")
    category = Category(name=data.name, description=data.description)
    db.add(category)
    db.commit()
    db.refresh(category)
    return category


def update_category(db: Session, category_id: int, data: CategoryUpdate) -> Category:
    category = db.query(Category).filter(Category.id == category_id).first()
    if category is None:
        raise BusinessError("Không tìm thấy danh mục")
    for field, value in data.model_dump(exclude_unset=True).items():
        setattr(category, field, value)
    db.commit()
    db.refresh(category)
    return category
