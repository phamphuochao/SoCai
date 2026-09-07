from decimal import Decimal

from pydantic import BaseModel, Field, field_validator


class ProductCreate(BaseModel):
    sku: str = Field(min_length=1, max_length=50)
    name: str = Field(min_length=1, max_length=150)
    category_id: int | None = None
    cost_price: Decimal = Field(default=Decimal("0"))
    selling_price: Decimal = Field(default=Decimal("0"))
    stock_quantity: int = Field(default=0, ge=0)
    min_stock_level: int = Field(default=0, ge=0)

    @field_validator("cost_price", "selling_price")
    @classmethod
    def gia_khong_am(cls, v: Decimal) -> Decimal:
        if v < 0:
            raise ValueError("Giá không được âm")
        return v


class ProductUpdate(BaseModel):
    name: str | None = None
    category_id: int | None = None
    cost_price: Decimal | None = None
    selling_price: Decimal | None = None
    min_stock_level: int | None = None
    is_active: bool | None = None

    @field_validator("cost_price", "selling_price")
    @classmethod
    def gia_khong_am(cls, v: Decimal | None) -> Decimal | None:
        if v is not None and v < 0:
            raise ValueError("Giá không được âm")
        return v


class ProductOut(BaseModel):
    id: int
    sku: str
    name: str
    category_id: int | None
    cost_price: Decimal
    selling_price: Decimal
    stock_quantity: int
    min_stock_level: int
    is_active: bool

    class Config:
        from_attributes = True
