# API Inventory

Tài liệu này phản ánh route được đăng ký trong source FastAPI sau khi hoàn thiện. API nghiệp vụ dùng namespace `/api/v1`; health check hiện hữu được giữ tại `/health` để tương thích. Request và response JSON dùng `snake_case` đúng theo Pydantic schema.

## Quy ước chung

- Endpoint có `JWT` yêu cầu header `Authorization: Bearer <access_token>`.
- `Admin` nghĩa là JWT hợp lệ và user có `role=admin`; user thường nhận `403`.
- Endpoint JWT trả `401` khi thiếu token, token sai/hết hạn, user không tồn tại hoặc đã bị khóa.
- Lỗi validate path/query/body trả `422`. Lỗi nghiệp vụ được router bắt và trả `400` với `{ "detail": "..." }`, trừ các route lookup dùng `404` như ghi dưới đây.
- Login nhận JSON. OpenAPI dùng security scheme HTTP Bearer `BearerAuth`, vì vậy Swagger Authorize nhận access token do `/api/v1/auth/login` trả về.
- List API giữ response là JSON array để tương thích. Các danh sách sản phẩm, hóa đơn, lịch sử kho và chi phí nhận thêm `offset>=0`, `limit=1..200`; bỏ hai tham số này vẫn trả toàn bộ như contract cũ. Flutter tải 21 bản ghi, hiển thị 20 và dùng bản ghi thứ 21 để xác định còn trang sau. Các API lookup/tổng hợp nhỏ vẫn trả toàn bộ.

## System và Auth

| Method và path | Router / function | Request | Response | Access | Status và lỗi | Flutter consumer | Test coverage | Thay đổi |
|---|---|---|---|---|---|---|---|---|
| `GET /health` | `app.main.health_check` | Không có | `{status: "ok"}` | Public | `200` | Chẩn đoán thủ công | Chưa có test route | Không |
| `POST /api/v1/auth/login` | `routers/auth.py:login` | `LoginRequest` `{username, password}` | `TokenResponse` `{access_token, token_type}` | Public | `200`, `401` sai thông tin/khóa, `422` | Login | `test_json_login_me_and_openapi_bearer_scheme` | OpenAPI chuyển sang HTTP Bearer; body/path giữ nguyên |
| `GET /api/v1/auth/me` | `routers/auth.py:get_me` | Không có | `UserOut` | JWT | `200`, `401` | Restore session, route guard, role UI | `test_json_login_me_and_openapi_bearer_scheme`; Flutter `auth_provider_test` | Security scheme được chuẩn hóa |

## Categories

| Method và path | Router / function | Request | Response | Access | Status và lỗi | Flutter consumer | Test coverage | Thay đổi |
|---|---|---|---|---|---|---|---|---|
| `GET /api/v1/categories` | `routers/categories.py:list_categories` | Query `active_only: bool=false` | `list[CategoryOut]` | JWT | `200`, `401`, `422` | Product filter/form, POS metadata | `test_admin_guards_product_and_inventory_mutations` | Không |
| `POST /api/v1/categories` | `routers/categories.py:create_category` | `CategoryCreate` `{name, description}` | `CategoryOut` | Admin | `200`, `400` trùng tên, `401`, `403`, `422` | Chưa có screen riêng | `test_admin_guards_product_and_inventory_mutations` | Không |
| `PATCH /api/v1/categories/{category_id}` | `routers/categories.py:update_category` | `CategoryUpdate` fields tùy chọn | `CategoryOut` | Admin | `200`, `400` không tồn tại/trùng tên, `401`, `403`, `422` | Chưa có screen riêng | `test_admin_guards_product_and_inventory_mutations` | Bổ sung kiểm tra trùng tên và validate tên rỗng |

## Products

| Method và path | Router / function | Request | Response | Access | Status và lỗi | Flutter consumer | Test coverage | Thay đổi |
|---|---|---|---|---|---|---|---|---|
| `GET /api/v1/products` | `routers/products.py:list_products` | Query `keyword`, `category_id`, `active_only`, `low_stock_only`, `is_active?`, `offset=0`, `limit? (1..200)` | `list[ProductOut]` | JWT | `200`, `401`, `422` | Products có paging; POS, Inventory, Invoice detail tải toàn bộ | `test_admin_guards_product_and_inventory_mutations` gồm paging/validation | Thêm paging tương thích ngược và lọc trạng thái chính xác |
| `GET /api/v1/products/{product_id}` | `routers/products.py:get_product` | Path `product_id` | `ProductOut` | JWT | `200`, `401`, `404`, `422` | Product edit | `test_sale_validation_rollback_cancel_and_report` | Không |
| `POST /api/v1/products` | `routers/products.py:create_product` | `ProductCreate` | `ProductOut` | Admin | `200`, `400` SKU trùng/danh mục sai, `401`, `403`, `422` | Product create | `test_admin_guards_product_and_inventory_mutations` | Bổ sung kiểm tra category tồn tại |
| `PATCH /api/v1/products/{product_id}` | `routers/products.py:update_product` | `ProductUpdate` fields tùy chọn | `ProductOut` | Admin | `200`, `400` product/category không tồn tại, `401`, `403`, `422` | Product edit | `test_admin_guards_product_and_inventory_mutations` | Bổ sung kiểm tra category và ngưỡng tồn không âm |
| `DELETE /api/v1/products/{product_id}` | `routers/products.py:deactivate_product` | Path `product_id` | `ProductOut` với `is_active=false` | Admin | `200`, `400` không tồn tại, `401`, `403`, `422` | Product deactivate | `test_admin_guards_product_and_inventory_mutations` | Không; vẫn là soft delete |

## Inventory

| Method và path | Router / function | Request | Response | Access | Status và lỗi | Flutter consumer | Test coverage | Thay đổi |
|---|---|---|---|---|---|---|---|---|
| `POST /api/v1/inventory/import` | `routers/inventory.py:import_stock` | `InventoryImportRequest` `{product_id, quantity>0, note?}` | `ProductOut` | JWT, mọi role | `200`, `400` product/tồn kho, `401`, `422` | Inventory import | API integration + `test_nhap_kho_tang_dung_so_luong` | ID được validate dương; cập nhật kho dùng câu lệnh nguyên tử |
| `POST /api/v1/inventory/adjust` | `routers/inventory.py:adjust_stock` | `InventoryAdjustRequest` `{product_id, quantity_change!=0, note?}` | `ProductOut` | Admin | `200`, `400` product/0/âm tồn, `401`, `403`, `422` | Inventory adjustment | API integration + inventory service tests | ID được validate dương; cập nhật kho dùng câu lệnh nguyên tử |
| `GET /api/v1/inventory/low-stock` | `routers/inventory.py:low_stock_products` | Không có | `list[ProductOut]` | JWT | `200`, `401` | Dashboard, Inventory | API integration + `test_san_pham_duoi_nguong_ton_toi_thieu_hien_thi_canh_bao` | Không |
| `GET /api/v1/inventory/transactions` | `routers/inventory.py:list_transactions` | Query `product_id?`, `offset=0`, `limit? (1..200)` | `list[InventoryTransactionOut]` | JWT | `200`, `401`, `422` | Inventory history có paging | API integration gồm paging + `test_moi_thay_doi_ton_kho_deu_tao_ban_ghi_lich_su` | Thêm paging tương thích ngược |

## Sales và Invoices

| Method và path | Router / function | Request | Response | Access | Status và lỗi | Flutter consumer | Test coverage | Thay đổi |
|---|---|---|---|---|---|---|---|---|
| `POST /api/v1/sales` | `routers/sales.py:create_sale` | `SaleCreate` `{items:[{product_id, quantity>0}], discount_amount>=0, payment_method, customer_name?}` | `SaleOut` gồm `items` | JWT, mọi role | `200`, `400` product/tồn/discount/nghiệp vụ, `401`, `422` | Sales/POS | API integration + toàn bộ `test_sale_service.py` | `payment_method` giới hạn `CASH/TRANSFER/CARD`; stock decrement nguyên tử |
| `GET /api/v1/sales` | `routers/sales.py:list_sales` | Query `invoice_code`, `date_from`, `date_to`, `staff_id`, `status`, `offset=0`, `limit? (1..200)` | `list[SaleOut]` | JWT | `200`, `401`, `422` | Invoice list có paging | `test_sale_validation_rollback_cancel_and_report` gồm paging | Thêm paging tương thích ngược |
| `GET /api/v1/sales/{sale_id}` | `routers/sales.py:get_sale` | Path `sale_id` | `SaleOut` gồm line items | JWT | `200`, `401`, `404`, `422` | Deep link `/invoices/:id` | `test_sale_validation_rollback_cancel_and_report` | Không |
| `POST /api/v1/sales/{sale_id}/cancel` | `routers/sales.py:cancel_sale` | Path `sale_id` | `SaleOut` trạng thái `CANCELLED` | JWT, mọi role | `200`, `400` không tồn tại/đã hủy, `401`, `422` | Invoice detail cancel | API integration + `test_huy_hoa_don_hoan_lai_ton_kho` | Conditional status update ngăn hoàn kho hai lần khi request đồng thời |

## Expenses

| Method và path | Router / function | Request | Response | Access | Status và lỗi | Flutter consumer | Test coverage | Thay đổi |
|---|---|---|---|---|---|---|---|---|
| `POST /api/v1/expenses` | `routers/expenses.py:create_expense` | `ExpenseCreate` `{expense_type, amount>0, expense_date, note?}` | `ExpenseOut` | JWT, mọi role | `200`, `401`, `422` | Expense create | `test_expense_endpoint_affects_net_profit` | Không |
| `GET /api/v1/expenses` | `routers/expenses.py:list_expenses` | Query `date_from?`, `date_to?`, `offset=0`, `limit? (1..200)` | `list[ExpenseOut]` | JWT | `200`, `401`, `422` | Expense list có paging | `test_expense_endpoint_affects_net_profit` gồm paging | Thêm paging tương thích ngược |

Backend chưa có edit/delete expense, nên Flutter chỉ hiển thị danh sách và tạo mới.

## Reports

| Method và path | Router / function | Request | Response | Access | Status và lỗi | Flutter consumer | Test coverage | Thay đổi |
|---|---|---|---|---|---|---|---|---|
| `GET /api/v1/reports/summary` | `routers/reports.py:revenue_summary` | Query `date_from?`, `date_to?`; mặc định hôm nay | `RevenueSummaryOut` | JWT | `200`, `401`, `422` | Dashboard, Reports | Sale/expense API integration | Không |
| `GET /api/v1/reports/top-products` | `routers/reports.py:top_products` | Query `date_from?`, `date_to?`, `limit=5`, `order_by=quantity` | `list[TopProductOut]` | JWT | `200`, `401`, `422` | Dashboard, Reports | `test_sale_validation_rollback_cancel_and_report` | Không |
| `GET /api/v1/reports/revenue-by-day` | `routers/reports.py:revenue_by_day` | Query `date_from?`, `date_to?`; mặc định 30 ngày | `list[RevenueByDayOut]` có cả ngày doanh thu 0 | JWT | `200`, `401`, `422` | Dashboard, Reports chart | `test_sale_validation_rollback_cancel_and_report` | Không |

## Permission matrix dùng ở Flutter

| Capability | Admin | Staff |
|---|---:|---:|
| Xem dashboard, reports, invoices, products, inventory, expenses | Có | Có |
| Tạo/cập nhật/ngừng bán product và category | Có | Không |
| Nhập kho | Có | Có |
| Điều chỉnh kiểm kê | Có | Không |
| Tạo và hủy sale | Có | Có |
| Tạo expense | Có | Có |

Flutter ẩn action quản trị theo `/auth/me`, nhưng FastAPI dependency vẫn là nơi quyết định quyền.

## Transaction và SQLite

`create_sale` kiểm tra line item, tạo sale/items, trừ kho và tạo inventory transaction trước một lần commit; mọi exception rollback toàn bộ. Stock decrement dùng conditional SQL update nên request không thể ghi tồn âm ngay cả khi SQLite không hỗ trợ `SELECT FOR UPDATE`. Cancel dùng conditional update `COMPLETED → CANCELLED` trước khi hoàn kho, vì vậy request lặp hoặc cạnh tranh chỉ có một request được hoàn kho.

SQLite được giữ theo đặc tả. Connection bật foreign key, timeout/busy timeout 30 giây và WAL cho database file. SQLite vẫn chỉ có một writer tại một thời điểm; cấu hình này phù hợp demo/MVP nhỏ nhưng không thay thế database server cho tải ghi lớn.
