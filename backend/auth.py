"""JWT creation/verification and password hashing utilities."""

from datetime import datetime, timedelta
from jose import jwt, JWTError
from passlib.context import CryptContext
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

from config import settings
import database as db

pwd_ctx = CryptContext(schemes=["bcrypt"], deprecated="auto")
bearer = HTTPBearer()


# ─────────────────────────────────────────────
# PASSWORD HELPERS
# ─────────────────────────────────────────────
def hash_password(plain: str) -> str:
    return pwd_ctx.hash(plain)


def verify_password(plain: str, hashed: str) -> bool:
    return pwd_ctx.verify(plain, hashed)


# ─────────────────────────────────────────────
# JWT HELPERS
# ─────────────────────────────────────────────
def create_token(user: dict) -> str:
    """
    Create JWT token for authenticated user.
    Stores:
    - sub = user id
    - account_number
    - role
    """
    expire = datetime.utcnow() + timedelta(hours=settings.ACCESS_TOKEN_EXPIRE_HOURS)

    payload = {
        "sub": str(user["id"]),
        "user_id": str(user["id"]),
        "account_number": user.get("account_number"),
        "role": user.get("role"),
        "exp": expire,
    }

    return jwt.encode(payload, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


# ─────────────────────────────────────────────
# CURRENT USER DEPENDENCY
# ─────────────────────────────────────────────
async def get_current_user(
    creds: HTTPAuthorizationCredentials = Depends(bearer)
) -> dict:
    """
    Decode JWT and return authenticated active user.
    """
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Invalid or expired token",
        headers={"WWW-Authenticate": "Bearer"},
    )

    try:
        payload = jwt.decode(
            creds.credentials,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM]
        )

        user_id = payload.get("user_id") or payload.get("sub")
        account_number = payload.get("account_number")

        if not user_id and not account_number:
            raise credentials_exception

    except JWTError:
        raise credentials_exception

    user = None

    if user_id:
        user = await db.fetch_one(
            """
            SELECT id, account_number, full_name, email, role,
                   dashboard_access, department, avatar_color, is_active
            FROM users
            WHERE id = %s
            """,
            (user_id,)
        )

    if not user and account_number:
        user = await db.fetch_one(
            """
            SELECT id, account_number, full_name, email, role,
                   dashboard_access, department, avatar_color, is_active
            FROM users
            WHERE account_number = %s
            """,
            (account_number,)
        )

    if not user or not user["is_active"]:
        raise credentials_exception

    return user


# ─────────────────────────────────────────────
# ROLE / ACCESS GUARDS
# ─────────────────────────────────────────────
def require_admin(user: dict = Depends(get_current_user)):
    if user["role"] != "admin":
        raise HTTPException(status_code=403, detail="Admin access required")
    return user


def require_dashboard(level: str = "view"):
    """
    Factory dependency:
    Checks dashboard access level.
    Levels:
    - none
    - view
    - edit
    """
    order = {"none": 0, "view": 1, "edit": 2}

    async def _check(user: dict = Depends(get_current_user)):
        if user["role"] == "admin":
            return user

        if order.get(user.get("dashboard_access", "none"), 0) < order[level]:
            raise HTTPException(
                status_code=403,
                detail=f"Dashboard '{level}' access required. Ask your admin."
            )

        return user

    return _check