from datetime import datetime

from pydantic import BaseModel, Field


class InventoryImportRequest(BaseModel):
    product_id: int
    quantity: int = Field(gt=0, description="Số lượng nhập thêm, phải > 0")
    note: str | None = None


class InventoryAdjustRequest(BaseModel):
    product_id: int
    quantity_change: int = Field(description="Số dương = tăng, số âm = giảm; khác 0")
    note: str | None = None


class InventoryTransactionOut(BaseModel):
    id: int
    product_id: int
    type: str
    quantity_change: int
    reference_type: str | None
    reference_id: int | None
    note: str | None
    created_by: int
    created_at: datetime

    class Config:
        from_attributes = True
