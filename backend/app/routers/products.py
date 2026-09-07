from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.exceptions import BusinessError
from app.core.security import get_current_user, require_admin
from app.schemas.product import ProductCreate, ProductOut, ProductUpdate
from app.services import product_service

router = APIRouter(prefix="/api/v1/products", tags=["Products"])


@router.get("", response_model=list[ProductOut])
def list_products(
    keyword: str | None = None,
    category_id: int | None = None,
    active_only: bool = False,
    low_stock_only: bool = False,
    db: Session = Depends(get_db),
    _=Depends(get_current_user),
):
    return product_service.list_products(
        db, keyword=keyword, category_id=category_id, active_only=active_only, low_stock_only=low_stock_only
    )


@router.get("/{product_id}", response_model=ProductOut)
def get_product(product_id: int, db: Session = Depends(get_db), _=Depends(get_current_user)):
    product = product_service.get_product_by_id(db, product_id)
    if product is None:
        raise HTTPException(status_code=404, detail="Không tìm thấy sản phẩm")
    return product


@router.post("", response_model=ProductOut)
def create_product(payload: ProductCreate, db: Session = Depends(get_db), _=Depends(require_admin)):
    try:
        return product_service.create_product(db, payload)
    except BusinessError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.patch("/{product_id}", response_model=ProductOut)
def update_product(product_id: int, payload: ProductUpdate, db: Session = Depends(get_db), _=Depends(require_admin)):
    try:
        return product_service.update_product(db, product_id, payload)
    except BusinessError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.delete("/{product_id}", response_model=ProductOut)
def deactivate_product(product_id: int, db: Session = Depends(get_db), _=Depends(require_admin)):
    """Không xóa cứng — chỉ chuyển trạng thái ngừng bán (mục 5.2 kế hoạch)."""
    try:
        return product_service.deactivate_product(db, product_id)
    except BusinessError as e:
        raise HTTPException(status_code=400, detail=str(e))
