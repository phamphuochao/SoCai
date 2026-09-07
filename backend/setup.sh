#!/bin/bash
# Chạy: bash setup.sh  (hoặc: chmod +x setup.sh && ./setup.sh)
# Phải chạy từ trong thư mục backend/ (nơi có file requirements.txt)
set -e

echo "=== Bước 1: Tạo virtual environment (.venv) ==="
python3 -m venv .venv

echo "=== Bước 2: Kích hoạt .venv và cài thư viện ==="
source .venv/bin/activate
python -m pip install --upgrade pip
pip install -r requirements.txt

echo "=== Bước 3: Tạo file .env từ mẫu (nếu chưa có) ==="
if [ ! -f .env ]; then
    cp .env.example .env
    echo "Đã tạo file .env - có thể mở và chỉnh sửa nếu cần."
else
    echo "File .env đã tồn tại, bỏ qua."
fi

echo "=== Bước 4: Tạo dữ liệu mẫu (admin/staff, sản phẩm...) ==="
python -m app.seed

echo ""
echo "================================================"
echo "  XONG! Môi trường đã sẵn sàng."
echo "  Lần sau muốn chạy server, gõ:"
echo "    source .venv/bin/activate"
echo "    uvicorn app.main:app --reload"
echo "  Rồi mở trình duyệt: http://127.0.0.1:8000/docs"
echo "================================================"
