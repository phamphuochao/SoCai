from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.exceptions import BusinessError
from app.core.security import get_current_user, require_admin
from app.models.user import User
from app.schemas.inventory import InventoryAdjustRequest, InventoryImportRequest, InventoryTransactionOut
from app.schemas.product import ProductOut
from app.services import inventory_service

router = APIRouter(prefix="/api/v1/inventory", tags=["Inventory"])


@router.post("/import", response_model=ProductOut)
def import_stock(payload: InventoryImportRequest, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    try:
        return inventory_service.import_stock(db, payload.product_id, payload.quantity, current_user.id, payload.note)
    except BusinessError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/adjust", response_model=ProductOut)
def adjust_stock(payload: InventoryAdjustRequest, db: Session = Depends(get_db), _=Depends(require_admin), current_user: User = Depends(get_current_user)):
    try:
        return inventory_service.adjust_stock(db, payload.product_id, payload.quantity_change, current_user.id, payload.note)
    except BusinessError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.get("/low-stock", response_model=list[ProductOut])
def low_stock_products(db: Session = Depends(get_db), _=Depends(get_current_user)):
    return inventory_service.list_low_stock_products(db)


@router.get("/transactions", response_model=list[InventoryTransactionOut])
def list_transactions(
    product_id: int | None = None,
    offset: int = Query(0, ge=0),
    limit: int | None = Query(None, ge=1, le=200),
    db: Session = Depends(get_db),
    _=Depends(get_current_user),
):
    return inventory_service.list_transactions(
        db,
        product_id=product_id,
        offset=offset,
        limit=limit,
    )
