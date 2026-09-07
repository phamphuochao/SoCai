from datetime import datetime, timezone

from sqlalchemy import String, DateTime, ForeignKey, Integer
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class InventoryTransaction(Base):
    __tablename__ = "inventory_transactions"

    id: Mapped[int] = mapped_column(primary_key=True)
    product_id: Mapped[int] = mapped_column(ForeignKey("products.id"), nullable=False)

    # IMPORT | SALE | ADJUSTMENT | RETURN (mục 5.3 tài liệu kế hoạch)
    type: Mapped[str] = mapped_column(String(20), nullable=False)
    quantity_change: Mapped[int] = mapped_column(Integer, nullable=False)  # dương = nhập/hoàn, âm = bán/giảm

    reference_type: Mapped[str] = mapped_column(String(30), nullable=True)  # VD "SALE", "SALE_CANCEL", "MANUAL"
    reference_id: Mapped[int] = mapped_column(Integer, nullable=True)

    note: Mapped[str] = mapped_column(String(255), nullable=True)
    created_by: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=lambda: datetime.now(timezone.utc))

    product: Mapped["Product"] = relationship(back_populates="inventory_transactions")  # noqa: F821
