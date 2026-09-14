from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.exceptions import BusinessError
from app.core.security import get_current_user
from app.models.user import User
from app.schemas.sale import SaleCreate, SaleOut
from app.services import sale_service

router = APIRouter(prefix="/api/v1/sales", tags=["Sales"])


@router.post("", response_model=SaleOut)
def create_sale(payload: SaleCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    try:
        return sale_service.create_sale(
            db,
            staff_id=current_user.id,
            items=payload.items,
            discount_amount=payload.discount_amount,
            payment_method=payload.payment_method,
            customer_name=payload.customer_name,
        )
    except BusinessError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("", response_model=list[SaleOut])
def list_sales(
    invoice_code: str | None = None,
    date_from: datetime | None = None,
    date_to: datetime | None = None,
    staff_id: int | None = None,
    status: str | None = None,
    offset: int = Query(0, ge=0),
    limit: int | None = Query(None, ge=1, le=200),
    db: Session = Depends(get_db),
    _=Depends(get_current_user),
):
    return sale_service.list_sales(
        db,
        invoice_code=invoice_code,
        date_from=date_from,
        date_to=date_to,
        staff_id=staff_id,
        status=status,
        offset=offset,
        limit=limit,
    )


@router.get("/{sale_id}", response_model=SaleOut)
def get_sale(sale_id: int, db: Session = Depends(get_db), _=Depends(get_current_user)):
    sale = sale_service.get_sale_by_id(db, sale_id)
    if sale is None:
        raise HTTPException(status_code=404, detail="Không tìm thấy hóa đơn")
    return sale


@router.post("/{sale_id}/cancel", response_model=SaleOut)
def cancel_sale(sale_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    try:
        return sale_service.cancel_sale(db, sale_id, actor_id=current_user.id)
    except BusinessError as e:
        raise HTTPException(status_code=400, detail=str(e))
