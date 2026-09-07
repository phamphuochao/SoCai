from datetime import datetime
from decimal import Decimal

from pydantic import BaseModel, Field


class SaleItemCreate(BaseModel):
    product_id: int
    quantity: int = Field(gt=0)


class SaleCreate(BaseModel):
    items: list[SaleItemCreate] = Field(min_length=1)
    discount_amount: Decimal = Field(default=Decimal("0"), ge=0)
    payment_method: str = Field(default="CASH")
    customer_name: str | None = None


class SaleItemOut(BaseModel):
    id: int
    product_id: int
    quantity: int
    unit_price: Decimal
    cost_price_snapshot: Decimal
    line_total: Decimal

    class Config:
        from_attributes = True


class SaleOut(BaseModel):
    id: int
    invoice_code: str
    staff_id: int
    customer_name: str | None
    subtotal: Decimal
    discount_amount: Decimal
    total_amount: Decimal
    payment_method: str
    status: str
    sold_at: datetime
    items: list[SaleItemOut] = []

    class Config:
        from_attributes = True
