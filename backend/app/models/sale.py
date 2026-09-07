from datetime import datetime, timezone
from decimal import Decimal

from sqlalchemy import String, DateTime, ForeignKey, Numeric
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class Sale(Base):
    __tablename__ = "sales"

    id: Mapped[int] = mapped_column(primary_key=True)
    invoice_code: Mapped[str] = mapped_column(String(30), unique=True, nullable=False, index=True)
    staff_id: Mapped[int] = mapped_column(ForeignKey("users.id"), nullable=False)
    customer_name: Mapped[str] = mapped_column(String(100), nullable=True)

    subtotal: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False, default=0)
    discount_amount: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False, default=0)
    total_amount: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False, default=0)

    payment_method: Mapped[str] = mapped_column(String(20), default="CASH")  # CASH | TRANSFER | CARD
    # COMPLETED | CANCELLED — hóa đơn CANCELLED không tính vào bất kỳ báo cáo doanh thu nào
    status: Mapped[str] = mapped_column(String(20), default="COMPLETED")

    sold_at: Mapped[datetime] = mapped_column(DateTime, default=lambda: datetime.now(timezone.utc))
    created_at: Mapped[datetime] = mapped_column(DateTime, default=lambda: datetime.now(timezone.utc))

    staff: Mapped["User"] = relationship(back_populates="sales")  # noqa: F821
    items: Mapped[list["SaleItem"]] = relationship(back_populates="sale", cascade="all, delete-orphan")  # noqa: F821
