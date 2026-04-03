# main.py
"""InfyBot FastAPI Application — Production Entry Point."""

from contextlib import asynccontextmanager
import platform

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

from config import settings
import database
from routes import auth, chat, admin, rasa_admin


# ─────────────────────────────────────────────
# LIFESPAN (STARTUP / SHUTDOWN)
# ─────────────────────────────────────────────
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    await database.get_pool()
    print(f"\n🚀 InfyBot API  →  http://{settings.APP_HOST}:{settings.APP_PORT}")
    print(f"📖 Docs         →  http://{settings.APP_HOST}:{settings.APP_PORT}/docs\n")
    yield
    # Shutdown
    await database.close_pool()


# ─────────────────────────────────────────────
# RATE LIMITER
# ─────────────────────────────────────────────
limiter = Limiter(
    key_func=get_remote_address,
    default_limits=["200/minute"]
)


# ─────────────────────────────────────────────
# APP
# ─────────────────────────────────────────────
app = FastAPI(
    title="InfyBot API",
    version="2.0.0",
    description="Infosys-level AI Chatbot — Python FastAPI + Rasa + MySQL",
    lifespan=lifespan,
)

app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)


# ─────────────────────────────────────────────
# CORS
# ─────────────────────────────────────────────
allowed_origins = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
]

if getattr(settings, "FRONTEND_URL", None):
    allowed_origins.append(settings.FRONTEND_URL)

app.add_middleware(
    CORSMiddleware,
    allow_origins=list(set(allowed_origins)),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ─────────────────────────────────────────────
# ROUTERS
# ─────────────────────────────────────────────
app.include_router(auth.router)
app.include_router(chat.router)
app.include_router(admin.router)
app.include_router(rasa_admin.router)


# ─────────────────────────────────────────────
# ROOT
# ─────────────────────────────────────────────
@app.get("/", tags=["root"])
async def root():
    return {
        "message": "InfyBot API is running",
        "docs": "/docs",
        "health": "/health"
    }


# ─────────────────────────────────────────────
# HEALTH
# ─────────────────────────────────────────────
@app.get("/health", tags=["health"])
async def health():
    return {
        "status": "OK",
        "service": "InfyBot API",
        "python": platform.python_version(),
    }

# ─────────────────────────────────────────────
# LOCAL DEV ENTRYPOINT
# ─────────────────────────────────────────────
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host=settings.APP_HOST,
        port=settings.APP_PORT,
        reload=True
    )