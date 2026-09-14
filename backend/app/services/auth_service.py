"""Xác thực tài khoản và tạo access token."""
from sqlalchemy.orm import Session

from app.core.exceptions import BusinessError
from app.core.security import verify_password, create_access_token
from app.models.user import User


def authenticate(db: Session, username: str, password: str) -> str:
    user = db.query(User).filter(User.username == username).first()
    if user is None or not verify_password(password, user.hashed_password):
        raise BusinessError("Sai tên đăng nhập hoặc mật khẩu")
    if not user.is_active:
        raise BusinessError("Tài khoản đã bị khóa")

    token = create_access_token(subject=user.username, extra_claims={"role": user.role, "uid": user.id})
    return token
