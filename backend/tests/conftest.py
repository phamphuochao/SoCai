import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.core.database import Base
from app import models  # noqa: F401
from app.core.security import hash_password
from app.models.product import Product
from app.models.user import User


@pytest.fixture()
def db_session():
    """Mỗi test chạy trên một database SQLite in-memory riêng, sạch từ đầu."""
    engine = create_engine("sqlite:///:memory:", connect_args={"check_same_thread": False})
    TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    Base.metadata.create_all(bind=engine)

    session = TestingSessionLocal()
    try:
        yield session
    finally:
        session.close()
        engine.dispose()


@pytest.fixture()
def test_staff(db_session):
    user = User(username="staff_test", hashed_password=hash_password("x"), full_name="Test Staff", role="staff")
    db_session.add(user)
    db_session.commit()
    db_session.refresh(user)
    return user


def create_test_product(db_session, stock_quantity=10, selling_price=10000, cost_price=6000, name="Sản phẩm test", sku=None):
    import uuid
    product = Product(
        sku=sku or f"TEST-{uuid.uuid4().hex[:8]}",
        name=name,
        cost_price=cost_price,
        selling_price=selling_price,
        stock_quantity=stock_quantity,
        min_stock_level=0,
    )
    db_session.add(product)
    db_session.commit()
    db_session.refresh(product)
    return product
