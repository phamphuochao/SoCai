from datetime import date, datetime, timedelta
from decimal import Decimal

from sqlalchemy import func, desc
from sqlalchemy.orm import Session

from app.models.expense import Expense
from app.models.product import Product
from app.models.sale import Sale
from app.models.sale_item import SaleItem


def get_revenue_summary(db: Session, date_from: datetime, date_to: datetime) -> dict:
    completed_sales = db.query(Sale).filter(
        Sale.status == "COMPLETED", Sale.sold_at.between(date_from, date_to)
    ).all()

    net_revenue = sum((s.total_amount for s in completed_sales), Decimal("0"))
    order_count = len(completed_sales)
    average_order_value = (net_revenue / order_count) if order_count > 0 else Decimal("0")

    total_cogs = (
        db.query(func.sum(SaleItem.quantity * SaleItem.cost_price_snapshot))
        .join(Sale, Sale.id == SaleItem.sale_id)
        .filter(Sale.status == "COMPLETED", Sale.sold_at.between(date_from, date_to))
        .scalar()
        or Decimal("0")
    )
    gross_profit = net_revenue - total_cogs

    total_expenses = (
        db.query(func.sum(Expense.amount))
        .filter(Expense.expense_date.between(date_from.date(), date_to.date()))
        .scalar()
        or Decimal("0")
    )
    net_profit = gross_profit - total_expenses

    return {
        "net_revenue": net_revenue,
        "order_count": order_count,
        "average_order_value": average_order_value,
        "gross_profit": gross_profit,
        "net_profit": net_profit,
    }


def get_top_products(db: Session, date_from: datetime, date_to: datetime, limit: int = 5, order_by: str = "quantity"):
    query = (
        db.query(
            Product.id,
            Product.name,
            func.sum(SaleItem.quantity).label("total_quantity"),
            func.sum(SaleItem.line_total).label("total_revenue"),
        )
        .join(SaleItem, SaleItem.product_id == Product.id)
        .join(Sale, Sale.id == SaleItem.sale_id)
        .filter(Sale.status == "COMPLETED", Sale.sold_at.between(date_from, date_to))
        .group_by(Product.id)
    )
    order_column = "total_quantity" if order_by == "quantity" else "total_revenue"
    rows = query.order_by(desc(order_column)).limit(limit).all()
    return [
        {"id": r.id, "name": r.name, "total_quantity": r.total_quantity, "total_revenue": r.total_revenue}
        for r in rows
    ]


def get_revenue_by_day(db: Session, date_from: datetime, date_to: datetime):
    rows = (
        db.query(
            func.date(Sale.sold_at).label("day"),
            func.sum(Sale.total_amount).label("revenue"),
            func.count(Sale.id).label("order_count"),
        )
        .filter(Sale.status == "COMPLETED", Sale.sold_at.between(date_from, date_to))
        .group_by(func.date(Sale.sold_at))
        .order_by("day")
        .all()
    )
    result_map = {str(r.day): r for r in rows}

    all_days = []
    d = date_from.date()
    end = date_to.date()
    while d <= end:
        all_days.append(d)
        d += timedelta(days=1)

    return [
        {
            "date": d,
            "revenue": result_map[str(d)].revenue if str(d) in result_map else Decimal("0"),
            "order_count": result_map[str(d)].order_count if str(d) in result_map else 0,
        }
        for d in all_days
    ]
