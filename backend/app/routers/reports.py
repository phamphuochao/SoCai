from datetime import datetime, timedelta, time

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user
from app.schemas.report import RevenueByDayOut, RevenueSummaryOut, TopProductOut
from app.services import report_service

router = APIRouter(prefix="/api/v1/reports", tags=["Reports"])


def _default_range(date_from: datetime | None, date_to: datetime | None) -> tuple[datetime, datetime]:
    """Mặc định là hôm nay nếu không truyền khoảng thời gian."""
    if date_from is None:
        date_from = datetime.combine(datetime.utcnow().date(), time.min)
    if date_to is None:
        date_to = datetime.combine(datetime.utcnow().date(), time.max)
    return date_from, date_to


@router.get("/summary", response_model=RevenueSummaryOut)
def revenue_summary(date_from: datetime | None = None, date_to: datetime | None = None, db: Session = Depends(get_db), _=Depends(get_current_user)):
    date_from, date_to = _default_range(date_from, date_to)
    return report_service.get_revenue_summary(db, date_from, date_to)


@router.get("/top-products", response_model=list[TopProductOut])
def top_products(
    date_from: datetime | None = None,
    date_to: datetime | None = None,
    limit: int = 5,
    order_by: str = "quantity",
    db: Session = Depends(get_db),
    _=Depends(get_current_user),
):
    date_from, date_to = _default_range(date_from, date_to)
    return report_service.get_top_products(db, date_from, date_to, limit=limit, order_by=order_by)


@router.get("/revenue-by-day", response_model=list[RevenueByDayOut])
def revenue_by_day(date_from: datetime | None = None, date_to: datetime | None = None, db: Session = Depends(get_db), _=Depends(get_current_user)):
    if date_from is None:
        date_from = datetime.combine(datetime.utcnow().date() - timedelta(days=29), time.min)
    if date_to is None:
        date_to = datetime.combine(datetime.utcnow().date(), time.max)
    return report_service.get_revenue_by_day(db, date_from, date_to)
