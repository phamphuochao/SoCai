from datetime import date, datetime
from decimal import Decimal

from pydantic import BaseModel, ConfigDict, Field


class ExpenseCreate(BaseModel):
    expense_type: str = Field(min_length=1, max_length=50)
    amount: Decimal = Field(gt=0)
    expense_date: date
    note: str | None = None


class ExpenseOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    expense_type: str
    amount: Decimal
    expense_date: date
    note: str | None
    created_by: int
    created_at: datetime
