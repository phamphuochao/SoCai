"""Import toàn bộ model để SQLAlchemy đăng ký đủ bảng trong metadata."""
from app.core.database import Base  # noqa: F401

from app.models.user import User  # noqa: F401
from app.models.category import Category  # noqa: F401
from app.models.product import Product  # noqa: F401
from app.models.sale import Sale  # noqa: F401
from app.models.sale_item import SaleItem  # noqa: F401
from app.models.inventory_transaction import InventoryTransaction  # noqa: F401
from app.models.expense import Expense  # noqa: F401
