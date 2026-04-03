"""Auth routes: login with account_number + password, register, /me."""
import uuid
import re
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, EmailStr, field_validator

import database as db
from auth import hash_password, verify_password, create_token, get_current_user

router = APIRouter(prefix="/api/auth", tags=["auth"])


# ── Schemas ───────────────────────────────────────────────
class LoginRequest(BaseModel):
    account_number: str
    password: str

    @field_validator("account_number")
    def validate_account_number(cls, v):
        v = v.strip()
        if not v.isdigit():
            raise ValueError("Account number must contain only digits")
        return v


class RegisterRequest(BaseModel):
    full_name: str
    account_number: str
    email: EmailStr
    password: str
    department: str | None = None

    @field_validator("full_name")
    def name_length(cls, v):
        if len(v.strip()) < 2:
            raise ValueError("Name must be at least 2 characters")
        return v.strip()

    @field_validator("account_number")
    def validate_account_number(cls, v):
        v = v.strip()
        if not v.isdigit():
            raise ValueError("Account number must contain only digits")
        if len(v) < 8 or len(v) > 20:
            raise ValueError("Account number must be between 8 and 20 digits")
        return v

    @field_validator("password")
    def password_strength(cls, v):
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters")
        if not re.search(r"[A-Z]", v):
            raise ValueError("Password must contain an uppercase letter")
        if not re.search(r"[a-z]", v):
            raise ValueError("Password must contain a lowercase letter")
        if not re.search(r"\d", v):
            raise ValueError("Password must contain a digit")
        return v


class ChangePasswordRequest(BaseModel):
    current_password: str
    new_password: str

    @field_validator("new_password")
    def password_strength(cls, v):
        if len(v) < 8:
            raise ValueError("Password must be at least 8 characters")
        if not re.search(r"[A-Z]", v):
            raise ValueError("Password must contain an uppercase letter")
        if not re.search(r"[a-z]", v):
            raise ValueError("Password must contain a lowercase letter")
        if not re.search(r"\d", v):
            raise ValueError("Password must contain a digit")
        return v


# ── Routes ────────────────────────────────────────────────
@router.post("/login")
async def login(body: LoginRequest):
    account_number = body.account_number.strip()

    user = await db.fetch_one(
        """
        SELECT id, account_number, full_name, email, role, dashboard_access,
               department, avatar_color, password_hash, is_active
        FROM users
        WHERE account_number = %s
        """,
        (account_number,)
    )

    if not user:
        raise HTTPException(status_code=401, detail="Invalid account number or password")

    if not verify_password(body.password, user["password_hash"]):
        raise HTTPException(status_code=401, detail="Invalid account number or password")

    if not user["is_active"]:
        raise HTTPException(status_code=403, detail="Account is deactivated. Contact admin.")

    await db.execute(
        "UPDATE users SET last_login = NOW(), updated_at = NOW() WHERE id = %s",
        (user["id"],)
    )

    token = create_token(user)

    return {
        "success": True,
        "token": token,
        "user": {
            "id": user["id"],
            "account_number": user["account_number"],
            "full_name": user["full_name"],
            "email": user["email"],
            "role": user["role"],
            "dashboard_access": user["dashboard_access"],
            "department": user["department"],
            "avatar_color": user["avatar_color"],
        }
    }


@router.post("/register")
async def register(body: RegisterRequest):
    existing_email = await db.fetch_one(
        "SELECT id FROM users WHERE email = %s",
        (body.email,)
    )
    if existing_email:
        raise HTTPException(status_code=409, detail="Email already registered")

    existing_acc = await db.fetch_one(
        "SELECT id FROM users WHERE account_number = %s",
        (body.account_number,)
    )
    if existing_acc:
        raise HTTPException(status_code=409, detail="Account number already exists")

    uid = str(uuid.uuid4())
    hashed = hash_password(body.password)

    await db.execute(
        """
        INSERT INTO users (
            id,
            account_number,
            full_name,
            email,
            password_hash,
            role,
            department,
            dashboard_access,
            avatar_color,
            is_active
        )
        VALUES (%s, %s, %s, %s, %s, 'customer', %s, 'none', '#1a73e8', 1)
        """,
        (
            uid,
            body.account_number.strip(),
            body.full_name,
            body.email,
            hashed,
            body.department
        )
    )

    new_user = {
        "id": uid,
        "account_number": body.account_number.strip(),
        "full_name": body.full_name,
        "email": body.email,
        "role": "customer",
        "dashboard_access": "none",
        "department": body.department,
        "avatar_color": "#1a73e8",
        "is_active": 1,
    }

    token = create_token(new_user)

    return {
        "success": True,
        "token": token,
        "account_number": body.account_number.strip(),
        "user": {
            "id": uid,
            "account_number": body.account_number.strip(),
            "full_name": body.full_name,
            "email": body.email,
            "role": "customer",
            "dashboard_access": "none",
            "department": body.department,
            "avatar_color": "#1a73e8",
        }
    }


@router.get("/me")
async def me(user: dict = Depends(get_current_user)):
    return {"success": True, "user": user}


@router.put("/change-password")
async def change_password(
    body: ChangePasswordRequest,
    user: dict = Depends(get_current_user)
):
    row = await db.fetch_one(
        "SELECT password_hash FROM users WHERE id = %s",
        (user["id"],)
    )

    if not row:
        raise HTTPException(status_code=404, detail="User not found")

    if not verify_password(body.current_password, row["password_hash"]):
        raise HTTPException(status_code=401, detail="Current password is incorrect")

    if body.current_password == body.new_password:
        raise HTTPException(status_code=400, detail="New password must be different from current password")

    new_hash = hash_password(body.new_password)

    await db.execute(
        "UPDATE users SET password_hash = %s, updated_at = NOW() WHERE id = %s",
        (new_hash, user["id"])
    )

    return {"success": True, "message": "Password updated successfully"}