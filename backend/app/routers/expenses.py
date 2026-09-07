from datetime import date

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.user import User
from app.schemas.expense import ExpenseCreate, ExpenseOut
from app.services import expense_service

router = APIRouter(prefix="/api/v1/expenses", tags=["Expenses"])


@router.post("", response_model=ExpenseOut)
def create_expense(payload: ExpenseCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return expense_service.create_expense(db, payload, created_by=current_user.id)


@router.get("", response_model=list[ExpenseOut])
def list_expenses(date_from: date | None = None, date_to: date | None = None, db: Session = Depends(get_db), _=Depends(get_current_user)):
    return expense_service.list_expenses(db, date_from=date_from, date_to=date_to)
