from datetime import date

from sqlalchemy.orm import Session

from app.models.expense import Expense
from app.schemas.expense import ExpenseCreate


def create_expense(db: Session, data: ExpenseCreate, created_by: int) -> Expense:
    expense = Expense(**data.model_dump(), created_by=created_by)
    db.add(expense)
    db.commit()
    db.refresh(expense)
    return expense


def list_expenses(
    db: Session,
    date_from: date | None = None,
    date_to: date | None = None,
    offset: int = 0,
    limit: int | None = None,
) -> list[Expense]:
    query = db.query(Expense)
    if date_from is not None:
        query = query.filter(Expense.expense_date >= date_from)
    if date_to is not None:
        query = query.filter(Expense.expense_date <= date_to)
    query = query.order_by(Expense.expense_date.desc(), Expense.id.desc())
    if offset:
        query = query.offset(offset)
    if limit is not None:
        query = query.limit(limit)
    return query.all()
