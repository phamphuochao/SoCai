"""Tạo, hủy và tra cứu hóa đơn bán hàng."""
from datetime import date, datetime, timezone
from decimal import Decimal

from sqlalchemy import func, update
from sqlalchemy.orm import Session, joinedload

from app.core.exceptions import BusinessError
from app.models.sale import Sale
from app.models.sale_item import SaleItem
from app.schemas.sale import PaymentMethod, SaleItemCreate
from app.services.inventory_service import apply_inventory_change
from app.services.product_service import get_product_by_id


def generate_invoice_code(db: Session) -> str:
    """Mã dạng HD20260807-0001, tăng dần theo từng ngày."""
    today_str = date.today().strftime("%Y%m%d")
    prefix = f"HD{today_str}-"
    last_sale = (
        db.query(Sale)
        .filter(Sale.invoice_code.like(f"{prefix}%"))
        .order_by(Sale.invoice_code.desc())
        .first()
    )
    next_number = 1 if last_sale is None else int(last_sale.invoice_code.split("-")[-1]) + 1
    return f"{prefix}{next_number:04d}"


def create_sale(
    db: Session,
    staff_id: int,
    items: list[SaleItemCreate],
    discount_amount: Decimal,
    payment_method: str,
    customer_name: str | None = None,
) -> Sale:
    if len(items) == 0:
        raise BusinessError("Đơn hàng phải có ít nhất 1 sản phẩm")

    payment_method_value = payment_method.value if isinstance(payment_method, PaymentMethod) else payment_method
    valid_payment_methods = {method.value for method in PaymentMethod}
    if payment_method_value not in valid_payment_methods:
        raise BusinessError("Phương thức thanh toán không hợp lệ")

    try:
        subtotal = Decimal("0")
        sale_items_data = []
        stock_updates = []

        for item in items:
            product = get_product_by_id(db, item.product_id, lock=True)

            if product is None or not product.is_active:
                raise BusinessError(f"Sản phẩm id={item.product_id} không tồn tại hoặc ngừng bán")
            if item.quantity <= 0:
                raise BusinessError("Số lượng phải lớn hơn 0")
            if item.quantity > product.stock_quantity:
                raise BusinessError(f"'{product.name}' không đủ tồn kho (còn {product.stock_quantity})")

            unit_price = product.selling_price
            # Lưu giá vốn tại thời điểm bán để báo cáo cũ không đổi khi sản phẩm đổi giá.
            cost_snapshot = product.cost_price
            line_total = unit_price * item.quantity

            subtotal += line_total
            sale_items_data.append(
                {
                    "product_id": product.id,
                    "quantity": item.quantity,
                    "unit_price": unit_price,
                    "cost_price_snapshot": cost_snapshot,
                    "line_total": line_total,
                }
            )
            stock_updates.append((product.id, item.quantity))

        if discount_amount > subtotal:
            raise BusinessError("Giảm giá không được lớn hơn tổng tiền hàng")

        total_amount = subtotal - discount_amount
        invoice_code = generate_invoice_code(db)

        sale = Sale(
            invoice_code=invoice_code,
            staff_id=staff_id,
            customer_name=customer_name,
            subtotal=subtotal,
            discount_amount=discount_amount,
            total_amount=total_amount,
            payment_method=payment_method_value,
            status="COMPLETED",
            sold_at=datetime.now(timezone.utc).replace(tzinfo=None),
        )
        db.add(sale)
        db.flush()  # Cần sale.id để tạo chi tiết hóa đơn và lịch sử kho.

        for item_data in sale_items_data:
            db.add(SaleItem(sale_id=sale.id, **item_data))

        for product_id, qty in stock_updates:
            apply_inventory_change(
                db,
                product_id=product_id,
                quantity_change=-qty,
                txn_type="SALE",
                created_by=staff_id,
                reference_type="SALE",
                reference_id=sale.id,
            )

        db.commit()
        db.refresh(sale)
        return sale

    except Exception:
        db.rollback()
        raise


def cancel_sale(db: Session, sale_id: int, actor_id: int) -> Sale:
    """Hủy hóa đơn và hoàn tồn kho trong cùng transaction."""
    try:
        sale = db.query(Sale).options(joinedload(Sale.items)).filter(Sale.id == sale_id).first()
        if sale is None:
            raise BusinessError("Không tìm thấy hóa đơn")
        claim = db.execute(
            update(Sale)
            .where(Sale.id == sale_id, Sale.status == "COMPLETED")
            .values(status="CANCELLED")
            .execution_options(synchronize_session="fetch")
        )
        if claim.rowcount != 1:
            raise BusinessError("Chỉ hủy được hóa đơn đang ở trạng thái COMPLETED")

        for item in sale.items:
            apply_inventory_change(
                db,
                product_id=item.product_id,
                quantity_change=item.quantity,
                txn_type="RETURN",
                created_by=actor_id,
                reference_type="SALE_CANCEL",
                reference_id=sale.id,
            )
        db.commit()
        db.refresh(sale)
        return sale

    except Exception:
        db.rollback()
        raise


def get_sale_by_id(db: Session, sale_id: int) -> Sale | None:
    return db.query(Sale).options(joinedload(Sale.items)).filter(Sale.id == sale_id).first()


def list_sales(
    db: Session,
    invoice_code: str | None = None,
    date_from: datetime | None = None,
    date_to: datetime | None = None,
    staff_id: int | None = None,
    status: str | None = None,
    offset: int = 0,
    limit: int | None = None,
) -> list[Sale]:
    query = db.query(Sale).options(joinedload(Sale.items))
    if invoice_code:
        query = query.filter(Sale.invoice_code.ilike(f"%{invoice_code}%"))
    if date_from is not None:
        query = query.filter(Sale.sold_at >= date_from)
    if date_to is not None:
        query = query.filter(Sale.sold_at <= date_to)
    if staff_id is not None:
        query = query.filter(Sale.staff_id == staff_id)
    if status:
        query = query.filter(Sale.status == status)
    query = query.order_by(Sale.sold_at.desc(), Sale.id.desc())
    if offset:
        query = query.offset(offset)
    if limit is not None:
        query = query.limit(limit)
    return query.all()
