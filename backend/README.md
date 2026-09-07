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

Có thể mở `.env` để đổi `SECRET_KEY`, tài khoản admin/staff mặc định nếu muốn.

## 2. Tạo dữ liệu mẫu (chạy 1 lần, hoặc mỗi khi muốn reset)

```bash
python -m app.seed
```

Lệnh này tạo:
- Tài khoản `admin/admin123` (quyền admin) và `staff/staff123` (quyền nhân viên)
- 4 danh mục: Đồ uống, Thực phẩm, Gia dụng, Văn phòng phẩm
- 20 sản phẩm mẫu (có sẵn 2 sản phẩm tồn kho thấp để demo cảnh báo)

Chạy lại an toàn — không tạo trùng nếu dữ liệu đã có.

## 3. Chạy server

```bash
uvicorn app.main:app --reload
```

Mở trình duyệt tại **http://127.0.0.1:8000/docs** để xem và thử toàn bộ API bằng Swagger UI
(bấm nút "Authorize", đăng nhập bằng `/api/v1/auth/login` trước để lấy token).

Flutter sẽ gọi API tới `http://<ip-máy-host>:8000/api/v1/...`

## 4. Chạy test

```bash
pytest tests/ -v
```

9 test hiện có kiểm tra đúng các nghiệp vụ quan trọng nhất: không bán vượt tồn kho,
rollback khi 1 sản phẩm trong đơn bị lỗi, tính tiền/giảm giá đúng, hủy hóa đơn hoàn kho,
tồn kho không thể âm, và cảnh báo sản phẩm sắp hết hàng.

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
- [ ] Thêm test cho `routers/` (integration test) nếu còn thời gian — hiện chỉ có test cho `services/`
- [ ] Ghép nối với Flutter (base URL, interceptor gắn token vào header `Authorization: Bearer <token>`)

## Ghi chú quan trọng khi làm tiếp

- **Mọi thay đổi tồn kho phải đi qua `inventory_service.apply_inventory_change()`** — không tự sửa `product.stock_quantity` ở nơi khác.
- **Tiền luôn dùng `Decimal`**, không dùng `float`.
- **Không xóa cứng sản phẩm/hóa đơn** — chỉ đổi trạng thái (`is_active=False`, `status="CANCELLED"`).
- File `.env` không nên commit lên Git (chứa `SECRET_KEY` thật) — đã có `.env.example` làm mẫu, nhớ thêm `.env` vào `.gitignore`.
