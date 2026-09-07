"""
services/inventory_service.py
Mọi thay đổi tồn kho (nhập hàng, bán hàng, điều chỉnh, hoàn hàng) đều phải đi qua
MỘT hàm duy nhất: apply_inventory_change(). Không nơi nào khác trong code được
phép tự ý sửa product.stock_quantity trực tiếp — nếu làm vậy sẽ mất dấu vết lịch sử
trong bảng inventory_transactions.
"""
from datetime import date

from sqlalchemy.orm import Session

from app.core.exceptions import BusinessError
from app.models.inventory_transaction import InventoryTransaction
from app.services.product_service import get_product_by_id


def apply_inventory_change(
    db: Session,
    product_id: int,
    quantity_change: int,
    txn_type: str,
    created_by: int,
    reference_type: str | None = None,
    reference_id: int | None = None,
    note: str | None = None,
):
    """
    txn_type: "IMPORT" | "SALE" | "ADJUSTMENT" | "RETURN"
    quantity_change: dương = tăng tồn kho, âm = giảm tồn kho.
    Không cho phép tồn kho âm sau khi áp dụng thay đổi.
    """
    product = get_product_by_id(db, product_id, lock=True)
    if product is None:
        raise BusinessError(f"Không tìm thấy sản phẩm id={product_id}")

    new_stock = product.stock_quantity + quantity_change
    if new_stock < 0:
        raise BusinessError(f"Tồn kho '{product.name}' không đủ (hiện có {product.stock_quantity})")

    product.stock_quantity = new_stock
    db.add(
        InventoryTransaction(
            product_id=product_id,
            type=txn_type,
            quantity_change=quantity_change,
            reference_type=reference_type,
            reference_id=reference_id,
            note=note,
            created_by=created_by,
        )
    )
    return product


def import_stock(db: Session, product_id: int, quantity: int, created_by: int, note: str | None = None):
    """Nhập kho thủ công — mục 5.3 kế hoạch."""
    if quantity <= 0:
        raise BusinessError("Số lượng nhập phải lớn hơn 0")
    product = apply_inventory_change(
        db, product_id, quantity_change=quantity, txn_type="IMPORT",
        created_by=created_by, reference_type="MANUAL_IMPORT", note=note,
    )
    db.commit()
    db.refresh(product)
    return product


def adjust_stock(db: Session, product_id: int, quantity_change: int, created_by: int, note: str | None = None):
    """Điều chỉnh tồn kho thủ công (VD kiểm kê phát hiện lệch số liệu)."""
    if quantity_change == 0:
        raise BusinessError("Số lượng điều chỉnh phải khác 0")
    product = apply_inventory_change(
        db, product_id, quantity_change=quantity_change, txn_type="ADJUSTMENT",
        created_by=created_by, reference_type="MANUAL_ADJUSTMENT", note=note,
    )
    db.commit()
    db.refresh(product)
    return product


def list_low_stock_products(db: Session):
    from app.services.product_service import list_products
    return list_products(db, active_only=True, low_stock_only=True)


def list_transactions(
    db: Session,
    product_id: int | None = None,
    date_from: date | None = None,
    date_to: date | None = None,
):
    query = db.query(InventoryTransaction)
    if product_id is not None:
        query = query.filter(InventoryTransaction.product_id == product_id)
    if date_from is not None:
        query = query.filter(InventoryTransaction.created_at >= date_from)
    if date_to is not None:
        query = query.filter(InventoryTransaction.created_at <= date_to)
    return query.order_by(InventoryTransaction.created_at.desc()).all()
