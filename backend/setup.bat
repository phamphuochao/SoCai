@echo off
REM Chạy file này bằng cách double-click, hoặc gõ: setup.bat
REM Phải chạy từ trong thư mục backend/ (nơi có file requirements.txt)

echo === Buoc 1: Tao virtual environment (.venv) ===
python -m venv .venv
if errorlevel 1 (
    echo LOI: khong tim thay python. Hay cai Python 3.11+ va them vao PATH truoc.
    pause
    exit /b 1
)

echo === Buoc 2: Kich hoat .venv va cai thu vien ===
call .venv\Scripts\activate.bat
python -m pip install --upgrade pip
pip install -r requirements.txt

echo === Buoc 3: Tao file .env tu mau (neu chua co) ===
if not exist .env (
    copy .env.example .env
    echo Da tao file .env.
) else (
    echo File .env da ton tai, bo qua.
)

echo === Buoc 4: Tao du lieu mau (admin/staff, san pham...) ===
python -m app.seed

echo.
echo ================================================
echo   XONG! Moi truong da san sang.
echo   Lan sau muon chay server, go:
echo     .venv\Scripts\activate
echo     uvicorn app.main:app --reload
echo   Roi mo trinh duyet: http://127.0.0.1:8000/docs
echo ================================================
pause
