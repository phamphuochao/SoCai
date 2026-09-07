from decimal import Decimal

import pytest

from app.core.exceptions import BusinessError
from app.schemas.sale import SaleItemCreate
from app.services import sale_service
from tests.conftest import create_test_product


def test_khong_the_ban_vuot_ton_kho(db_session, test_staff):
    product = create_test_product(db_session, stock_quantity=5)
    with pytest.raises(BusinessError):
        sale_service.create_sale(
            db_session, staff_id=test_staff.id,
            items=[SaleItemCreate(product_id=product.id, quantity=10)],
            discount_amount=Decimal("0"), payment_method="CASH",
        )
    db_session.refresh(product)
    assert product.stock_quantity == 5  # không đổi vì đã hủy toàn bộ giao dịch


def test_rollback_khi_1_item_loi(db_session, test_staff):
    p1 = create_test_product(db_session, stock_quantity=10)
    p2 = create_test_product(db_session, stock_quantity=1)
    with pytest.raises(BusinessError):
        sale_service.create_sale(
            db_session, staff_id=test_staff.id,
            items=[
                SaleItemCreate(product_id=p1.id, quantity=2),
                SaleItemCreate(product_id=p2.id, quantity=5),
            ],
            discount_amount=Decimal("0"), payment_method="CASH",
        )
    db_session.refresh(p1)
    assert p1.stock_quantity == 10  # p1 hợp lệ nhưng vẫn KHÔNG bị trừ vì p2 lỗi


def test_ban_hang_thanh_cong_tru_dung_ton_kho_va_tinh_dung_tien(db_session, test_staff):
    product = create_test_product(db_session, stock_quantity=10, selling_price=Decimal("10000"))
    sale = sale_service.create_sale(
        db_session, staff_id=test_staff.id,
        items=[SaleItemCreate(product_id=product.id, quantity=3)],
        discount_amount=Decimal("1000"), payment_method="CASH",
    )
    db_session.refresh(product)
    assert product.stock_quantity == 7
    assert sale.subtotal == Decimal("30000")
    assert sale.total_amount == Decimal("29000")
    assert sale.status == "COMPLETED"


def test_giam_gia_lon_hon_tong_tien_bi_tu_choi(db_session, test_staff):
    product = create_test_product(db_session, stock_quantity=10, selling_price=Decimal("10000"))
    with pytest.raises(BusinessError):
        sale_service.create_sale(
            db_session, staff_id=test_staff.id,
            items=[SaleItemCreate(product_id=product.id, quantity=1)],
            discount_amount=Decimal("999999"), payment_method="CASH",
        )


def test_huy_hoa_don_hoan_lai_ton_kho(db_session, test_staff):
    product = create_test_product(db_session, stock_quantity=10)
    sale = sale_service.create_sale(
        db_session, staff_id=test_staff.id,
        items=[SaleItemCreate(product_id=product.id, quantity=4)],
        discount_amount=Decimal("0"), payment_method="CASH",
    )
    db_session.refresh(product)
    assert product.stock_quantity == 6

    sale_service.cancel_sale(db_session, sale.id, actor_id=test_staff.id)
    db_session.refresh(product)
    assert product.stock_quantity == 10  # hoàn lại đủ số lượng đã bán

    db_session.refresh(sale)
    assert sale.status == "CANCELLED"
