from datetime import datetime
from decimal import Decimal
from enum import Enum

from pydantic import BaseModel, ConfigDict, Field


class PaymentMethod(str, Enum):
    CASH = "CASH"
    TRANSFER = "TRANSFER"
    CARD = "CARD"


class SaleItemCreate(BaseModel):
    product_id: int = Field(gt=0)
    quantity: int = Field(gt=0)


class SaleCreate(BaseModel):
    items: list[SaleItemCreate] = Field(min_length=1)
    discount_amount: Decimal = Field(default=Decimal("0"), ge=0)
    payment_method: PaymentMethod = PaymentMethod.CASH
    customer_name: str | None = None


class SaleItemOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    product_id: int
    quantity: int
    unit_price: Decimal
    cost_price_snapshot: Decimal
    line_total: Decimal

class SaleOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: int
    invoice_code: str
    staff_id: int
    customer_name: str | None
    subtotal: Decimal
    discount_amount: Decimal
    total_amount: Decimal
    payment_method: PaymentMethod
    status: str
    sold_at: datetime
    items: list[SaleItemOut] = []
