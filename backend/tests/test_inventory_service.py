import pytest

from app.core.exceptions import BusinessError
from app.services import inventory_service
from tests.conftest import create_test_product


def test_ton_kho_khong_the_am(db_session, test_staff):
    product = create_test_product(db_session, stock_quantity=3)
    with pytest.raises(BusinessError):
        inventory_service.apply_inventory_change(
            db_session, product.id, quantity_change=-5, txn_type="ADJUSTMENT", created_by=test_staff.id
        )
    db_session.refresh(product)
    assert product.stock_quantity == 3  # không đổi vì bị từ chối


def test_nhap_kho_tang_dung_so_luong(db_session, test_staff):
    product = create_test_product(db_session, stock_quantity=10)
    updated = inventory_service.import_stock(db_session, product.id, quantity=20, created_by=test_staff.id, note="Nhập thêm")
    assert updated.stock_quantity == 30


def test_moi_thay_doi_ton_kho_deu_tao_ban_ghi_lich_su(db_session, test_staff):
    product = create_test_product(db_session, stock_quantity=10)
    inventory_service.import_stock(db_session, product.id, quantity=5, created_by=test_staff.id)
    transactions = inventory_service.list_transactions(db_session, product_id=product.id)
    assert len(transactions) == 1
    assert transactions[0].type == "IMPORT"
    assert transactions[0].quantity_change == 5


def test_san_pham_duoi_nguong_ton_toi_thieu_hien_thi_canh_bao(db_session):
    from app.services.product_service import update_product
    from app.schemas.product import ProductUpdate

    low = create_test_product(db_session, stock_quantity=2, name="Hàng sắp hết")
    update_product(db_session, low.id, ProductUpdate(min_stock_level=5))
    create_test_product(db_session, stock_quantity=50, name="Hàng còn nhiều")  # đủ tồn, không cảnh báo

    low_stock = inventory_service.list_low_stock_products(db_session)
    names = [p.name for p in low_stock]
    assert "Hàng sắp hết" in names
    assert "Hàng còn nhiều" not in names
