from fastapi import HTTPException, Request
from jose import jwt, JWTError

from config import settings
from database import fetch_one


async def get_current_user(request: Request):
    auth_header = request.headers.get("Authorization")

    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing token")

    token = auth_header.split(" ")[1]

    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM]
        )

        # support multiple token payload styles
        user_id = payload.get("user_id")
        sub = payload.get("sub")
        account_number = payload.get("account_number")

        user = None

        if user_id:
            user = await fetch_one(
                "SELECT * FROM users WHERE id = %s",
                [user_id]
            )

        elif sub:
            # try sub as user id first
            user = await fetch_one(
                "SELECT * FROM users WHERE id = %s",
                [sub]
            )

            # if not found, try sub as account number / email
            if not user:
                user = await fetch_one(
                    "SELECT * FROM users WHERE account_number = %s OR email = %s",
                    [sub, sub]
                )

        elif account_number:
            user = await fetch_one(
                "SELECT * FROM users WHERE account_number = %s",
                [account_number]
            )

        if not user:
            raise HTTPException(status_code=401, detail="User not found from token")

        return user

    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")
    

def require_admin():
    async def checker(request: Request):
        user = await get_current_user(request)

        if user.get("role") != "admin":
            raise HTTPException(status_code=403, detail="Admin access required")

        return user

    return checker


def require_dashboard(required_level: str = "view"):
    async def checker(request: Request):
        user = await get_current_user(request)

        if user.get("role") != "admin":
            raise HTTPException(status_code=403, detail="Admin access required")

        user_access = user.get("dashboard_access", "view")

        if required_level == "view":
            return user

        if required_level == "edit" and user_access != "edit":
            raise HTTPException(status_code=403, detail="Edit dashboard access required")

        return user

    return checker