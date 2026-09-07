"""
xem_du_lieu.py — Script tiện ích: in nhanh dữ liệu tất cả các bảng ra terminal.
Cách chạy (đứng trong thư mục backend/, đã activate .venv):
    python xem_du_lieu.py
"""
import sqlite3

conn = sqlite3.connect("retail.db")
conn.row_factory = sqlite3.Row

tables = [r[0] for r in conn.execute(
    "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
)]

for table in tables:
    rows = conn.execute(f"SELECT * FROM {table}").fetchall()
    print(f"\n{'='*70}")
    print(f"BẢNG: {table}  ({len(rows)} dòng)")
    print("=" * 70)
    if not rows:
        print("(không có dữ liệu)")
        continue
    columns = rows[0].keys()
    print(" | ".join(columns))
    for row in rows:
        print(" | ".join(str(row[c]) for c in columns))

conn.close()
