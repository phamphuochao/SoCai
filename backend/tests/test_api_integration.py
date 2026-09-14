from datetime import date
from decimal import Decimal

import pytest
from fastapi.testclient import TestClient
from pydantic import ValidationError
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app import models  # noqa: F401
from app.core.config import Settings
from app.core.database import Base, get_db
from app.core.security import hash_password
from app.main import app
from app.models.product import Product
from app.models.user import User


@pytest.fixture()
def api_client():
    engine = create_engine(
        "sqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    testing_session = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    Base.metadata.create_all(bind=engine)

    with testing_session() as db:
        db.add_all(
            [
                User(
                    username="admin_api",
                    hashed_password=hash_password("admin-pass"),
                    full_name="API Admin",
                    role="admin",
                ),
                User(
                    username="staff_api",
                    hashed_password=hash_password("staff-pass"),
                    full_name="API Staff",
                    role="staff",
                ),
                Product(
                    sku="API-001",
                    name="Sản phẩm API",
                    cost_price=Decimal("6000"),
                    selling_price=Decimal("10000"),
                    stock_quantity=5,
                    min_stock_level=2,
                ),
            ]
        )
        db.commit()

    def override_get_db():
        db = testing_session()
        try:
            yield db
        finally:
            db.close()

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as client:
        yield client
    app.dependency_overrides.clear()
    engine.dispose()


def login_headers(client: TestClient, username: str, password: str) -> dict[str, str]:
    response = client.post("/api/v1/auth/login", json={"username": username, "password": password})
    assert response.status_code == 200
    return {"Authorization": f"Bearer {response.json()['access_token']}"}


def test_json_login_me_and_openapi_bearer_scheme(api_client):
    headers = login_headers(api_client, "staff_api", "staff-pass")
    me = api_client.get("/api/v1/auth/me", headers=headers)

    assert me.status_code == 200
    assert me.json()["username"] == "staff_api"
    assert me.json()["role"] == "staff"

    security_scheme = api_client.get("/openapi.json").json()["components"]["securitySchemes"]["BearerAuth"]
    assert security_scheme == {"type": "http", "scheme": "bearer"}


def test_admin_guards_product_and_inventory_mutations(api_client):
    staff_headers = login_headers(api_client, "staff_api", "staff-pass")
    denied = api_client.post(
        "/api/v1/products",
        headers=staff_headers,
        json={"sku": "API-002", "name": "Chỉ admin tạo", "selling_price": "12000"},
    )
    assert denied.status_code == 403

    denied_adjustment = api_client.post(
        "/api/v1/inventory/adjust",
        headers=staff_headers,
        json={"product_id": 1, "quantity_change": 1, "note": "Kiểm kê"},
    )
    assert denied_adjustment.status_code == 403

    admin_headers = login_headers(api_client, "admin_api", "admin-pass")
    categories = api_client.get("/api/v1/categories", headers=admin_headers)
    assert categories.status_code == 200

    first_category = api_client.post(
        "/api/v1/categories", headers=admin_headers, json={"name": "Đồ uống", "description": "Test"}
    )
    second_category = api_client.post(
        "/api/v1/categories", headers=admin_headers, json={"name": "Khác", "description": "Test"}
    )
    assert first_category.status_code == second_category.status_code == 200
    duplicate_name = api_client.patch(
        f"/api/v1/categories/{second_category.json()['id']}", headers=admin_headers, json={"name": "Đồ uống"}
    )
    assert duplicate_name.status_code == 400

    invalid_category = api_client.post(
        "/api/v1/products",
        headers=admin_headers,
        json={"sku": "BAD-CATEGORY", "name": "Sai danh mục", "category_id": 999, "selling_price": "1000"},
    )
    assert invalid_category.status_code == 400

    created = api_client.post(
        "/api/v1/products",
        headers=admin_headers,
        json={"sku": "API-002", "name": "Sản phẩm mới", "selling_price": "12000"},
    )
    assert created.status_code == 200
    product_id = created.json()["id"]

    updated = api_client.patch(
        f"/api/v1/products/{product_id}",
        headers=admin_headers,
        json={"name": "Sản phẩm đã sửa"},
    )
    assert updated.status_code == 200
    assert updated.json()["name"] == "Sản phẩm đã sửa"

    deactivated = api_client.delete(f"/api/v1/products/{product_id}", headers=admin_headers)
    assert deactivated.status_code == 200
    assert deactivated.json()["is_active"] is False

    product_list = api_client.get("/api/v1/products", headers=admin_headers)
    assert product_list.status_code == 200
    assert len(product_list.json()) == 2

    first_product_page = api_client.get("/api/v1/products?offset=0&limit=1", headers=admin_headers)
    second_product_page = api_client.get("/api/v1/products?offset=1&limit=1", headers=admin_headers)
    assert len(first_product_page.json()) == len(second_product_page.json()) == 1
    assert first_product_page.json()[0]["id"] != second_product_page.json()[0]["id"]
    inactive_products = api_client.get("/api/v1/products?is_active=false&limit=21", headers=admin_headers)
    assert [item["id"] for item in inactive_products.json()] == [product_id]
    assert api_client.get("/api/v1/products?limit=0", headers=admin_headers).status_code == 422

    imported = api_client.post(
        "/api/v1/inventory/import",
        headers=staff_headers,
        json={"product_id": 1, "quantity": 1, "note": "Nhập API"},
    )
    assert imported.status_code == 200
    assert imported.json()["stock_quantity"] == 6

    adjusted = api_client.post(
        "/api/v1/inventory/adjust",
        headers=admin_headers,
        json={"product_id": 1, "quantity_change": 2, "note": "Kiểm kê"},
    )
    assert adjusted.status_code == 200
    assert adjusted.json()["stock_quantity"] == 8

    history = api_client.get("/api/v1/inventory/transactions?product_id=1", headers=admin_headers)
    assert history.status_code == 200
    assert [item["type"] for item in history.json()] == ["ADJUSTMENT", "IMPORT"]
    history_page = api_client.get(
        "/api/v1/inventory/transactions?product_id=1&offset=1&limit=1", headers=admin_headers
    )
    assert [item["type"] for item in history_page.json()] == ["IMPORT"]
    assert api_client.get("/api/v1/inventory/low-stock", headers=admin_headers).status_code == 200


def test_sale_validation_rollback_cancel_and_report(api_client):
    headers = login_headers(api_client, "staff_api", "staff-pass")

    invalid_payment = api_client.post(
        "/api/v1/sales",
        headers=headers,
        json={"items": [{"product_id": 1, "quantity": 1}], "payment_method": "BITCOIN"},
    )
    assert invalid_payment.status_code == 422

    failed_sale = api_client.post(
        "/api/v1/sales",
        headers=headers,
        json={"items": [{"product_id": 1, "quantity": 99}], "payment_method": "CASH"},
    )
    assert failed_sale.status_code == 400
    assert api_client.get("/api/v1/products/1", headers=headers).json()["stock_quantity"] == 5

    created = api_client.post(
        "/api/v1/sales",
        headers=headers,
        json={
            "items": [{"product_id": 1, "quantity": 2}],
            "discount_amount": "1000",
            "payment_method": "TRANSFER",
            "customer_name": "Khách API",
        },
    )
    assert created.status_code == 200
    sale = created.json()
    assert Decimal(str(sale["total_amount"])) == Decimal("19000")
    assert api_client.get("/api/v1/products/1", headers=headers).json()["stock_quantity"] == 3

    invoice_list = api_client.get("/api/v1/sales", headers=headers)
    assert invoice_list.status_code == 200
    assert invoice_list.json()[0]["id"] == sale["id"]
    assert len(api_client.get("/api/v1/sales?limit=1", headers=headers).json()) == 1
    invoice_detail = api_client.get(f"/api/v1/sales/{sale['id']}", headers=headers)
    assert invoice_detail.status_code == 200
    assert invoice_detail.json()["invoice_code"] == sale["invoice_code"]

    summary = api_client.get("/api/v1/reports/summary", headers=headers)
    assert summary.status_code == 200
    assert Decimal(str(summary.json()["net_revenue"])) == Decimal("19000")
    assert api_client.get("/api/v1/reports/top-products", headers=headers).status_code == 200
    assert api_client.get("/api/v1/reports/revenue-by-day", headers=headers).status_code == 200

    cancelled = api_client.post(f"/api/v1/sales/{sale['id']}/cancel", headers=headers)
    assert cancelled.status_code == 200
    assert cancelled.json()["status"] == "CANCELLED"
    assert api_client.get("/api/v1/products/1", headers=headers).json()["stock_quantity"] == 5

    repeated = api_client.post(f"/api/v1/sales/{sale['id']}/cancel", headers=headers)
    assert repeated.status_code == 400
    assert api_client.get("/api/v1/products/1", headers=headers).json()["stock_quantity"] == 5


def test_expense_endpoint_affects_net_profit(api_client):
    headers = login_headers(api_client, "admin_api", "admin-pass")
    response = api_client.post(
        "/api/v1/expenses",
        headers=headers,
        json={
            "expense_type": "Điện nước",
            "amount": "50000",
            "expense_date": date.today().isoformat(),
            "note": "Test API",
        },
    )
    assert response.status_code == 200
    expense_list = api_client.get("/api/v1/expenses", headers=headers)
    assert expense_list.status_code == 200
    assert expense_list.json()[0]["expense_type"] == "Điện nước"
    assert len(api_client.get("/api/v1/expenses?limit=1", headers=headers).json()) == 1

    summary = api_client.get("/api/v1/reports/summary", headers=headers).json()
    assert Decimal(str(summary["net_profit"])) == Decimal("-50000")


def test_production_rejects_default_secret():
    with pytest.raises(ValidationError, match="Production yêu cầu SECRET_KEY"):
        Settings(ENVIRONMENT="production", SECRET_KEY="change-me-in-.env", _env_file=None)

    settings = Settings(ENVIRONMENT="production", SECRET_KEY="a-unique-production-secret", _env_file=None)
    assert settings.ENVIRONMENT == "production"
