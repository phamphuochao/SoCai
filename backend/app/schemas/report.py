from datetime import date
from decimal import Decimal

from pydantic import BaseModel


class RevenueSummaryOut(BaseModel):
    net_revenue: Decimal
    order_count: int
    average_order_value: Decimal
    gross_profit: Decimal
    net_profit: Decimal


class TopProductOut(BaseModel):
    id: int
    name: str
    total_quantity: int
    total_revenue: Decimal


class RevenueByDayOut(BaseModel):
    date: date
    revenue: Decimal
    order_count: int


class BusinessErrorOut(BaseModel):
    detail: str
