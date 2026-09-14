# Backend — Hệ thống quản lý doanh thu bán lẻ

FastAPI + SQLAlchemy + SQLite. Xem kiến trúc chi tiết trong tài liệu kế hoạch đồ án.

## 1. Cài đặt (chạy 1 lần)

```bash
cd backend
python -m venv .venv

# Windows:
.venv\Scripts\activate
# macOS/Linux:
source .venv/bin/activate

pip install -r requirements.txt
copy .env.example .env      # Windows
# cp .env.example .env      # macOS/Linux
```

Mở `.env` để đổi `SECRET_KEY`, CORS hoặc tài khoản seed nếu cần. File này đã
được Git ignore nên không bị đưa lên repository.

## 2. Tạo dữ liệu mẫu (chạy 1 lần, hoặc mỗi khi muốn reset)

```bash
python -m app.seed
```

Lệnh này tạo:
- Tài khoản `admin/admin123` (quyền admin) và `staff/staff123` (quyền nhân viên)
- 4 danh mục: Đồ uống, Thực phẩm, Gia dụng, Văn phòng phẩm
- 30 sản phẩm mẫu (đủ 2 trang với page size 20, có 2 sản phẩm tồn kho thấp)

Chạy lại an toàn — không tạo trùng nếu dữ liệu đã có.

## 3. Chạy server

```bash
uvicorn app.main:app --reload
```

Mở trình duyệt tại **http://127.0.0.1:8000/docs** để xem và thử toàn bộ API bằng Swagger UI.
Đăng nhập JSON bằng `/api/v1/auth/login`, sao chép `access_token`, sau đó bấm **Authorize**
và nhập token vào HTTP Bearer form.

Flutter sẽ gọi API tới `http://<ip-máy-host>:8000/api/v1/...`

## 4. Chạy test

```bash
pytest tests/ -v
```

14 test kiểm tra nghiệp vụ và API quan trọng: auth/role, OpenAPI Bearer, validation,
không bán vượt tồn kho, rollback khi một sản phẩm lỗi, tính tiền/giảm giá, hủy hóa đơn
hoàn kho đúng một lần, tồn kho không âm, lịch sử kho, expense và reports.

## Cấu trúc thư mục

```
app/
├── main.py              # điểm khởi động — chạy: uvicorn app.main:app --reload
├── seed.py               # tạo tài khoản + dữ liệu mẫu
├── core/
│   ├── config.py          # đọc cấu hình từ .env
│   ├── database.py        # kết nối SQLite, session
│   ├── security.py        # hash password, JWT, dependency xác thực
│   └── exceptions.py      # BusinessError dùng chung
├── models/                # SQLAlchemy — cấu trúc bảng dữ liệu
├── schemas/                # Pydantic — validate request/response
├── services/                # TOÀN BỘ THUẬT TOÁN NGHIỆP VỤ nằm ở đây
│   ├── sale_service.py       # quan trọng nhất: tạo/hủy hóa đơn
│   ├── inventory_service.py   # hàm trung tâm apply_inventory_change()
│   ├── report_service.py
│   ├── product_service.py
│   ├── category_service.py
│   ├── expense_service.py
│   └── auth_service.py
└── routers/                 # nhận request, gọi service, trả response
tests/                        # pytest — test thuần Python, không cần chạy server
```

## Việc cần làm tiếp theo (chưa có trong bản scaffold này)

- [ ] `sync/sheets_sync.py` — đồng bộ lên Google Sheets (không phải MVP bắt buộc, làm sau cùng nếu còn thời gian — xem tài liệu ý tưởng mục 5)
- [ ] Export CSV báo cáo (mục 5.7 kế hoạch — tính năng mở rộng)
- [ ] Sao lưu database bằng copy file `retail.db` (mục 3.1 — chỉ cần 1 dòng lệnh copy, chưa cần code)
- [x] Integration test cho các router quan trọng mà Flutter sử dụng
- [x] Ghép nối Flutter Web bằng API client và Bearer interceptor

## Ghi chú quan trọng khi làm tiếp

- **Mọi thay đổi tồn kho phải đi qua `inventory_service.apply_inventory_change()`** — không tự sửa `product.stock_quantity` ở nơi khác.
- **Tiền luôn dùng `Decimal`**, không dùng `float`.
- **Không xóa cứng sản phẩm/hóa đơn** — chỉ đổi trạng thái (`is_active=False`, `status="CANCELLED"`).
- File `.env` không nên commit lên Git (chứa `SECRET_KEY` thật). Khi `ENVIRONMENT=production`,
  ứng dụng từ chối khởi động nếu vẫn dùng secret mẫu.
- SQLite được cấu hình foreign key, WAL và busy timeout 30 giây. Nó vẫn chỉ phù hợp tải ghi nhỏ;
  stock/cancel dùng conditional update để giữ invariant trong phạm vi MVP.
