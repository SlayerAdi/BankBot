from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
import uuid
import time
import random
import httpx

import database as db
from auth import get_current_user
from config import settings

router = APIRouter(prefix="/api/chat", tags=["chat"])


# ─────────────────────────────────────────────
# RASA HELPER
# ─────────────────────────────────────────────
async def rasa_reply(message: str, session_id: str, user: dict) -> dict:
    t0 = time.time()
    try:
        async with httpx.AsyncClient(timeout=12.0) as client:
            payload = {
                "sender": session_id,
                "message": message,
                "metadata": {
                    "user_id": user["id"],
                    "account_number": user.get("account_number")
                }
            }

            print("📤 Sending to Rasa:", payload)

            resp = await client.post(
                f"{settings.RASA_URL}/webhooks/rest/webhook",
                json=payload
            )
            resp.raise_for_status()

            ms = int((time.time() - t0) * 1000)
            msgs = resp.json() or []

            print("📥 Rasa response:", msgs)

            text = "\n".join(
                m.get("text", "") for m in msgs if m.get("text")
            ).strip()

            if not text:
                text = "I'm sorry, I didn't understand that. Could you rephrase?"

            # Optional NLU parse
            intent, confidence = None, None
            try:
                nlu = await client.post(
                    f"{settings.RASA_URL}/model/parse",
                    json={"text": message}
                )
                nlu.raise_for_status()
                nlu_data = nlu.json()
                intent = nlu_data.get("intent", {}).get("name")
                confidence = nlu_data.get("intent", {}).get("confidence")
            except Exception:
                pass

            return {
                "text": text,
                "ms": ms,
                "intent": intent,
                "confidence": confidence
            }

    except Exception as e:
        ms = int((time.time() - t0) * 1000)
        print("❌ Rasa connection error:", str(e))

        fallbacks = [
            "Our AI service is temporarily unavailable. Please try again shortly.",
            "I'm having trouble connecting to the AI engine. Your message has been logged.",
        ]

        return {
            "text": random.choice(fallbacks),
            "ms": ms,
            "intent": "fallback",
            "confidence": 1.0
        }


# ─────────────────────────────────────────────
# REQUEST MODELS
# ─────────────────────────────────────────────
class CreateSessionBody(BaseModel):
    title: str = "New Conversation"


class SendMessageBody(BaseModel):
    message: str


class FeedbackBody(BaseModel):
    rating: str  # 'up' or 'down'


# ─────────────────────────────────────────────
# CREATE NEW CHAT SESSION
# ─────────────────────────────────────────────
@router.post("/sessions")
async def create_session(body: CreateSessionBody, user: dict = Depends(get_current_user)):
    sid = str(uuid.uuid4())

    await db.execute(
        """
        INSERT INTO chat_sessions (id, user_id, title, is_active, created_at, updated_at)
        VALUES (%s, %s, %s, 1, NOW(), NOW())
        """,
        (sid, user["id"], body.title)
    )

    return {
        "success": True,
        "session": {
            "id": sid,
            "title": body.title
        }
    }


# ─────────────────────────────────────────────
# LIST USER SESSIONS
# ─────────────────────────────────────────────
@router.get("/sessions")
async def list_sessions(user: dict = Depends(get_current_user)):
    rows = await db.fetchall(
        """
        SELECT s.id, s.title, s.updated_at, s.created_at,
               COUNT(m.id) AS message_count
        FROM chat_sessions s
        LEFT JOIN messages m ON m.session_id = s.id
        WHERE s.user_id = %s AND s.is_active = 1
        GROUP BY s.id
        ORDER BY s.updated_at DESC
        LIMIT 30
        """,
        (user["id"],)
    )

    for r in rows:
        for k in ["updated_at", "created_at"]:
            if r.get(k):
                r[k] = str(r[k])

    return {"success": True, "sessions": rows}


# ─────────────────────────────────────────────
# GET MESSAGES OF A SESSION
# ─────────────────────────────────────────────
@router.get("/sessions/{session_id}/messages")
async def get_messages(session_id: str, user: dict = Depends(get_current_user)):
    session = await db.fetchone(
        "SELECT * FROM chat_sessions WHERE id = %s AND user_id = %s",
        (session_id, user["id"])
    )

    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    rows = await db.fetchall(
        """
        SELECT id, sender, message_text, created_at, intent, confidence, feedback
        FROM messages
        WHERE session_id = %s
        ORDER BY created_at ASC
        """,
        (session_id,)
    )

    for r in rows:
        if r.get("created_at"):
            r["created_at"] = str(r["created_at"])

    return {"success": True, "messages": rows}


# ─────────────────────────────────────────────
# SEND MESSAGE TO BOT
# ─────────────────────────────────────────────
@router.post("/sessions/{session_id}/messages")
async def send_message(
    session_id: str,
    body: SendMessageBody,
    user: dict = Depends(get_current_user)
):
    # Validate session belongs to user
    session = await db.fetchone(
        "SELECT * FROM chat_sessions WHERE id = %s AND user_id = %s",
        (session_id, user["id"])
    )

    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    msg = body.message.strip()
    if not msg:
        raise HTTPException(status_code=400, detail="Message cannot be empty")

    # Save user message
    user_msg_id = str(uuid.uuid4())
    await db.execute(
        """
        INSERT INTO messages (id, session_id, user_id, sender, message_text, created_at)
        VALUES (%s, %s, %s, 'user', %s, NOW())
        """,
        (user_msg_id, session_id, user["id"], msg)
    )

    # Get bot response  ✅ FIXED HERE
    bot = await rasa_reply(msg, session_id, user)

    # Save bot message
    bot_msg_id = str(uuid.uuid4())
    await db.execute(
        """
        INSERT INTO messages (
            id, session_id, user_id, sender, message_text,
            intent, confidence, response_time, created_at
        )
        VALUES (%s, %s, %s, 'bot', %s, %s, %s, %s, NOW())
        """,
        (
            bot_msg_id,
            session_id,
            user["id"],
            bot["text"],
            bot.get("intent"),
            bot.get("confidence"),
            bot.get("ms")
        )
    )

    # Update session timestamp
    await db.execute(
        "UPDATE chat_sessions SET updated_at = NOW() WHERE id = %s",
        (session_id,)
    )

    return {
        "success": True,
        "user_message": {
            "id": user_msg_id,
            "sender": "user",
            "message_text": msg,
            "created_at": str(time.strftime("%Y-%m-%d %H:%M:%S"))
        },
        "bot_message": {
            "id": bot_msg_id,
            "sender": "bot",
            "message_text": bot["text"],
            "intent": bot.get("intent"),
            "confidence": bot.get("confidence"),
            "created_at": str(time.strftime("%Y-%m-%d %H:%M:%S"))
        }
    }


# ─────────────────────────────────────────────
# FEEDBACK ON BOT MESSAGE
# ─────────────────────────────────────────────
@router.post("/messages/{message_id}/feedback")
async def give_feedback(
    message_id: str,
    body: FeedbackBody,
    user: dict = Depends(get_current_user)
):
    if body.rating not in ["up", "down"]:
        raise HTTPException(status_code=400, detail="Invalid feedback rating")

    feedback_value = "positive" if body.rating == "up" else "negative"

    msg = await db.fetchone(
        """
        SELECT m.id
        FROM messages m
        JOIN chat_sessions s ON m.session_id = s.id
        WHERE m.id = %s AND s.user_id = %s
        """,
        (message_id, user["id"])
    )

    if not msg:
        raise HTTPException(status_code=404, detail="Message not found")

    await db.execute(
        "UPDATE messages SET feedback = %s WHERE id = %s",
        (feedback_value, message_id)
    )

    return {"success": True, "message": "Feedback saved"}