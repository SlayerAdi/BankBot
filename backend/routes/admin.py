from fastapi import APIRouter, Depends, HTTPException, Query
from typing import Optional
from pydantic import BaseModel
from fastapi.responses import StreamingResponse
import io
import csv
import uuid

from auth import get_current_user, require_dashboard
from database import fetch_all, fetch_one, execute_query

router = APIRouter(prefix="/api", tags=["admin"])


# ─────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────
def require_admin(user):
    if user.get("role") != "admin":
        raise HTTPException(status_code=403, detail="Admin access required")


# ─────────────────────────────────────────────
# REQUEST SCHEMAS
# ─────────────────────────────────────────────
class AccessUpdateRequest(BaseModel):
    access_level: str  # none | view | edit


class RoleUpdateRequest(BaseModel):
    role: str  # admin | customer | staff


# ─────────────────────────────────────────────
# DASHBOARD
# ─────────────────────────────────────────────
@router.get("/admin/dashboard")
async def get_dashboard(current_user=Depends(require_dashboard("view"))):
    total_users = await fetch_one(
        "SELECT COUNT(*) AS cnt FROM users WHERE role <> 'admin'"
    )
    total_messages = await fetch_one("SELECT COUNT(*) AS cnt FROM messages")
    total_sessions = await fetch_one("SELECT COUNT(*) AS cnt FROM chat_sessions")

    positive_fb = await fetch_one(
        "SELECT COUNT(*) AS cnt FROM messages WHERE feedback = 'positive'"
    )
    negative_fb = await fetch_one(
        "SELECT COUNT(*) AS cnt FROM messages WHERE feedback = 'negative'"
    )

    top_intents = await fetch_all("""
        SELECT intent, COUNT(*) AS cnt
        FROM messages
        WHERE intent IS NOT NULL AND intent != ''
        GROUP BY intent
        ORDER BY cnt DESC
        LIMIT 8
    """)

    daily = await fetch_all("""
        SELECT DATE(created_at) AS dt, COUNT(*) AS cnt
        FROM messages
        WHERE created_at >= NOW() - INTERVAL 30 DAY
        GROUP BY DATE(created_at)
        ORDER BY dt
    """)

    hourly = await fetch_all("""
        SELECT HOUR(created_at) AS hr, COUNT(*) AS cnt
        FROM messages
        WHERE DATE(created_at) = CURDATE()
        GROUP BY HOUR(created_at)
        ORDER BY hr
    """)

    user_growth = await fetch_all("""
        SELECT DATE(created_at) AS dt, COUNT(*) AS cnt
        FROM users
        WHERE role <> 'admin' AND created_at >= NOW() - INTERVAL 14 DAY
        GROUP BY DATE(created_at)
        ORDER BY dt
    """)

    avg_resp = await fetch_one("""
        SELECT ROUND(AVG(response_time), 0) AS avg_resp_ms
        FROM messages
        WHERE response_time IS NOT NULL
    """)

    users_with_access = await fetch_one("""
        SELECT COUNT(*) AS cnt
        FROM users
        WHERE dashboard_access IN ('view', 'edit')
          AND role <> 'admin'
    """)

    new_today = await fetch_one("""
        SELECT COUNT(*) AS cnt
        FROM users
        WHERE role <> 'admin' AND DATE(created_at) = CURDATE()
    """)

    msg_today = await fetch_one("""
        SELECT COUNT(*) AS cnt
        FROM messages
        WHERE DATE(created_at) = CURDATE()
    """)

    return {
        "kpi": {
            "total_users": total_users["cnt"] if total_users else 0,
            "total_messages": total_messages["cnt"] if total_messages else 0,
            "total_sessions": total_sessions["cnt"] if total_sessions else 0,
            "positive_fb": positive_fb["cnt"] if positive_fb else 0,
            "negative_fb": negative_fb["cnt"] if negative_fb else 0,
            "avg_resp_ms": avg_resp["avg_resp_ms"] if avg_resp else 0,
            "users_with_access": users_with_access["cnt"] if users_with_access else 0,
            "new_today": new_today["cnt"] if new_today else 0,
            "msg_today": msg_today["cnt"] if msg_today else 0,
        },
        "top_intents": top_intents or [],
        "daily": daily or [],
        "hourly": hourly or [],
        "user_growth": user_growth or [],
    }


# ─────────────────────────────────────────────
# LOGS
# ─────────────────────────────────────────────
@router.get("/admin/logs")
async def get_logs(
    page: int = Query(1, ge=1),
    limit: int = Query(30, ge=1, le=100),
    intent: Optional[str] = None,
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    current_user=Depends(require_dashboard("view"))
):
    offset = (page - 1) * limit
    conditions = []
    params = []

    if intent:
        conditions.append("m.intent = %s")
        params.append(intent)

    if start_date:
        conditions.append("DATE(m.created_at) >= %s")
        params.append(start_date)

    if end_date:
        conditions.append("DATE(m.created_at) <= %s")
        params.append(end_date)

    where_clause = "WHERE " + " AND ".join(conditions) if conditions else ""

    query = f"""
        SELECT
            m.id,
            u.full_name,
            u.account_number,
            m.sender,
            m.message_text,
            m.intent,
            m.confidence,
            m.response_time,
            m.created_at,
            m.is_flagged
        FROM messages m
        JOIN users u ON m.user_id = u.id
        {where_clause}
        ORDER BY m.created_at DESC
        LIMIT %s OFFSET %s
    """
    count_query = f"""
        SELECT COUNT(*) AS total
        FROM messages m
        {where_clause}
    """

    rows = await fetch_all(query, params + [limit, offset])
    total_row = await fetch_one(count_query, params)

    return {
        "logs": rows or [],
        "total": total_row["total"] if total_row else 0
    }


# ─────────────────────────────────────────────
# INTENT ANALYTICS
# ─────────────────────────────────────────────
@router.get("/admin/analytics/intents")
async def get_intent_analytics(current_user=Depends(require_dashboard("view"))):
    rows = await fetch_all("""
        SELECT
            intent,
            COUNT(*) AS cnt,
            ROUND(AVG(confidence) * 100, 2) AS avg_conf_pct,
            ROUND(AVG(response_time), 0) AS avg_resp_ms
        FROM messages
        WHERE intent IS NOT NULL AND intent != ''
        GROUP BY intent
        ORDER BY cnt DESC
    """)

    return {"data": rows or []}


# ─────────────────────────────────────────────
# USERS (ADMIN ONLY)
# ─────────────────────────────────────────────
@router.get("/admin/users")
async def get_users(
    search: str = "",
    page: int = Query(1, ge=1),
    limit: int = Query(15, ge=1, le=100),
    current_user=Depends(get_current_user)
):
    require_admin(current_user)

    offset = (page - 1) * limit
    like = f"%{search}%"

    rows = await fetch_all("""
        SELECT
            u.id,
            u.account_number,
            u.full_name,
            u.email,
            u.department,
            u.role,
            u.dashboard_access,
            u.is_active,
            u.created_at,
            (SELECT COUNT(*) FROM chat_sessions cs WHERE cs.user_id = u.id) AS sessions,
            (SELECT COUNT(*) FROM messages m WHERE m.user_id = u.id) AS messages_sent
        FROM users u
        WHERE
            u.full_name LIKE %s
            OR u.email LIKE %s
            OR u.account_number LIKE %s
        ORDER BY u.created_at DESC
        LIMIT %s OFFSET %s
    """, [like, like, like, limit, offset])

    total_row = await fetch_one("""
        SELECT COUNT(*) AS total
        FROM users
        WHERE
            full_name LIKE %s
            OR email LIKE %s
            OR account_number LIKE %s
    """, [like, like, like])

    return {
        "users": rows or [],
        "total": total_row["total"] if total_row else 0
    }


# ─────────────────────────────────────────────
# ACCESS LOG
# ─────────────────────────────────────────────
@router.get("/admin/access-log")
async def get_access_log(current_user=Depends(require_dashboard("view"))):
    rows = await fetch_all("""
        SELECT
            al.id,
            a.full_name AS admin_name,
            a.account_number AS admin_acc,
            u.full_name AS user_name,
            u.account_number AS user_acc,
            al.access_level,
            al.granted_at
        FROM access_logs al
        JOIN users a ON al.admin_id = a.id
        JOIN users u ON al.user_id = u.id
        ORDER BY al.granted_at DESC
        LIMIT 100
    """)

    return {"log": rows or []}


# ─────────────────────────────────────────────
# UPDATE USER DASHBOARD ACCESS (ADMIN ONLY)
# ─────────────────────────────────────────────
@router.patch("/admin/users/{user_id}/access")
async def update_user_access(
    user_id: str,
    body: AccessUpdateRequest,
    current_user=Depends(get_current_user)
):
    require_admin(current_user)

    allowed = {"none", "view", "edit"}
    access_level = body.access_level.strip().lower()

    if access_level not in allowed:
        raise HTTPException(status_code=400, detail="Invalid access level")

    if str(user_id) == str(current_user["id"]):
        raise HTTPException(status_code=400, detail="You cannot modify your own dashboard access")

    target = await fetch_one(
        "SELECT id, role FROM users WHERE id = %s",
        (user_id,)
    )
    if not target:
        raise HTTPException(status_code=404, detail="User not found")

    if target["role"] == "admin":
        raise HTTPException(status_code=400, detail="Admin users always have full dashboard access")

    await execute_query(
        "UPDATE users SET dashboard_access = %s, updated_at = NOW() WHERE id = %s",
        (access_level, user_id)
    )

    await execute_query(
        """
        INSERT INTO access_logs (id, admin_id, user_id, access_level)
        VALUES (%s, %s, %s, %s)
        """,
        (str(uuid.uuid4()), current_user["id"], user_id, access_level)
    )

    return {
        "success": True,
        "message": f"Dashboard access updated to '{access_level}'"
    }


# ─────────────────────────────────────────────
# UPDATE USER ROLE (ADMIN ONLY)
# ─────────────────────────────────────────────
@router.patch("/admin/users/{user_id}/role")
async def update_user_role(
    user_id: str,
    body: RoleUpdateRequest,
    current_user=Depends(get_current_user)
):
    require_admin(current_user)

    allowed = {"admin", "customer", "staff"}
    role = body.role.strip().lower()

    if role not in allowed:
        raise HTTPException(
            status_code=400,
            detail="Invalid role. Allowed roles: admin, customer, staff"
        )

    if str(user_id) == str(current_user["id"]):
        raise HTTPException(status_code=400, detail="You cannot modify your own role")

    target = await fetch_one(
        "SELECT id, role FROM users WHERE id = %s",
        (user_id,)
    )
    if not target:
        raise HTTPException(status_code=404, detail="User not found")

    await execute_query(
        "UPDATE users SET role = %s, updated_at = NOW() WHERE id = %s",
        (role, user_id)
    )

    return {
        "success": True,
        "message": f"Role updated to '{role}'",
        "role": role
    }


# ─────────────────────────────────────────────
# TOGGLE USER ACTIVE / INACTIVE (ADMIN ONLY)
# ─────────────────────────────────────────────
@router.patch("/admin/users/{user_id}/toggle")
async def toggle_user_status(
    user_id: str,
    current_user=Depends(get_current_user)
):
    require_admin(current_user)

    if str(user_id) == str(current_user["id"]):
        raise HTTPException(status_code=400, detail="You cannot deactivate your own account")

    user = await fetch_one(
        "SELECT id, is_active, role FROM users WHERE id = %s",
        (user_id,)
    )
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    if user["role"] == "admin":
        raise HTTPException(status_code=400, detail="Cannot deactivate another admin")

    new_status = 0 if user["is_active"] else 1

    await execute_query(
        "UPDATE users SET is_active = %s, updated_at = NOW() WHERE id = %s",
        (new_status, user_id)
    )

    return {
        "success": True,
        "message": "User status updated",
        "is_active": bool(new_status)
    }


# ─────────────────────────────────────────────
# FLAG / UNFLAG MESSAGE
# ─────────────────────────────────────────────
@router.patch("/admin/messages/{message_id}/flag")
async def toggle_flag_message(
    message_id: str,
    current_user=Depends(require_dashboard("edit"))
):
    row = await fetch_one(
        "SELECT id, is_flagged FROM messages WHERE id = %s",
        (message_id,)
    )
    if not row:
        raise HTTPException(status_code=404, detail="Message not found")

    new_flag = 0 if row["is_flagged"] else 1

    await execute_query(
        "UPDATE messages SET is_flagged = %s WHERE id = %s",
        (new_flag, message_id)
    )

    return {
        "success": True,
        "message": "Flag updated",
        "is_flagged": bool(new_flag)
    }


# ─────────────────────────────────────────────
# EXPORT USERS CSV (ADMIN ONLY)
# ─────────────────────────────────────────────
@router.get("/admin/export/users")
async def export_users(current_user=Depends(get_current_user)):
    require_admin(current_user)

    rows = await fetch_all("""
        SELECT
            account_number,
            full_name,
            email,
            department,
            role,
            dashboard_access,
            is_active,
            created_at
        FROM users
        ORDER BY created_at DESC
    """)

    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow([
        "Account Number", "Full Name", "Email", "Department",
        "Role", "Dashboard Access", "Active", "Created At"
    ])

    for r in rows:
        writer.writerow([
            r["account_number"],
            r["full_name"],
            r["email"],
            r["department"],
            r["role"],
            r["dashboard_access"],
            r["is_active"],
            r["created_at"],
        ])

    output.seek(0)
    return StreamingResponse(
        iter([output.getvalue()]),
        media_type="text/csv",
        headers={"Content-Disposition": "attachment; filename=users_export.csv"}
    )


# ─────────────────────────────────────────────
# EXPORT MESSAGES CSV
# ─────────────────────────────────────────────
@router.get("/admin/export/messages")
async def export_messages(
    intent: Optional[str] = None,
    start_date: Optional[str] = None,
    end_date: Optional[str] = None,
    current_user=Depends(require_dashboard("view"))
):
    conditions = []
    params = []

    if intent:
        conditions.append("m.intent = %s")
        params.append(intent)

    if start_date:
        conditions.append("DATE(m.created_at) >= %s")
        params.append(start_date)

    if end_date:
        conditions.append("DATE(m.created_at) <= %s")
        params.append(end_date)

    where_clause = "WHERE " + " AND ".join(conditions) if conditions else ""

    rows = await fetch_all(f"""
        SELECT
            u.full_name,
            u.account_number,
            m.sender,
            m.message_text,
            m.intent,
            m.confidence,
            m.response_time,
            m.feedback,
            m.is_flagged,
            m.created_at
        FROM messages m
        JOIN users u ON m.user_id = u.id
        {where_clause}
        ORDER BY m.created_at DESC
    """, params)

    output = io.StringIO()
    writer = csv.writer(output)
    writer.writerow([
        "User", "Account Number", "Sender", "Message", "Intent",
        "Confidence", "Response Time", "Feedback", "Flagged", "Created At"
    ])

    for r in rows:
        writer.writerow([
            r["full_name"],
            r["account_number"],
            r["sender"],
            r["message_text"],
            r["intent"],
            r["confidence"],
            r["response_time"],
            r["feedback"],
            r["is_flagged"],
            r["created_at"],
        ])

    output.seek(0)
    return StreamingResponse(
        iter([output.getvalue()]),
        media_type="text/csv",
        headers={"Content-Disposition": "attachment; filename=messages_export.csv"}
    )