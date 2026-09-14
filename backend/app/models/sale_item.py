from decimal import Decimal

from sqlalchemy import ForeignKey, Numeric, Integer
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base


class SaleItem(Base):
    __tablename__ = "sale_items"

    id: Mapped[int] = mapped_column(primary_key=True)
    sale_id: Mapped[int] = mapped_column(ForeignKey("sales.id"), nullable=False)
    product_id: Mapped[int] = mapped_column(ForeignKey("products.id"), nullable=False)

    quantity: Mapped[int] = mapped_column(Integer, nullable=False)

    # Lưu giá tại thời điểm bán để hóa đơn cũ không đổi khi sản phẩm được cập nhật.
    unit_price: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    cost_price_snapshot: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    line_total: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)

    sale: Mapped["Sale"] = relationship(back_populates="items")  # noqa: F821
    product: Mapped["Product"] = relationship(back_populates="sale_items")  # noqa: F821
