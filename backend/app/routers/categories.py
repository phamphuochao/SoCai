from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.exceptions import BusinessError
from app.core.security import get_current_user, require_admin
from app.schemas.category import CategoryCreate, CategoryOut, CategoryUpdate
from app.services import category_service

router = APIRouter(prefix="/api/v1/categories", tags=["Categories"])


@router.get("", response_model=list[CategoryOut])
def list_categories(active_only: bool = False, db: Session = Depends(get_db), _=Depends(get_current_user)):
    return category_service.list_categories(db, active_only=active_only)


@router.post("", response_model=CategoryOut)
def create_category(payload: CategoryCreate, db: Session = Depends(get_db), _=Depends(require_admin)):
    try:
        return category_service.create_category(db, payload)
    except BusinessError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.patch("/{category_id}", response_model=CategoryOut)
def update_category(category_id: int, payload: CategoryUpdate, db: Session = Depends(get_db), _=Depends(require_admin)):
    try:
        return category_service.update_category(db, category_id, payload)
    except BusinessError as e:
        raise HTTPException(status_code=400, detail=str(e))
