# database.py
"""Async MySQL connection pool using aiomysql."""

import aiomysql
from config import settings

_pool = None


# ─────────────────────────────────────────────
# CONNECTION POOL
# ─────────────────────────────────────────────
async def get_pool() -> aiomysql.Pool:
    global _pool

    if _pool is None:
        _pool = await aiomysql.create_pool(
            host=settings.DB_HOST,
            port=settings.DB_PORT,
            user=settings.DB_USER,
            password=settings.DB_PASSWORD,
            db=settings.DB_NAME,
            charset="utf8mb4",
            autocommit=True,
            minsize=3,
            maxsize=20,
            cursorclass=aiomysql.DictCursor,  # return rows as dict
        )
        print("✅ MySQL pool created")

    return _pool


async def close_pool():
    global _pool

    if _pool:
        _pool.close()
        await _pool.wait_closed()
        _pool = None
        print("🛑 MySQL pool closed")


# ─────────────────────────────────────────────
# CORE HELPERS
# ─────────────────────────────────────────────
async def execute(query: str, args=None):
    """
    Run INSERT / UPDATE / DELETE query.
    Returns:
    - lastrowid for INSERT
    - still usable for UPDATE/DELETE (if needed)
    """
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor() as cur:
            await cur.execute(query, args or ())
            return cur.lastrowid


async def execute_rowcount(query: str, args=None):
    """
    Run UPDATE / DELETE query and return affected row count.
    Useful when you need to know how many rows changed.
    """
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor() as cur:
            await cur.execute(query, args or ())
            return cur.rowcount


async def fetchone(query: str, args=None) -> dict | None:
    """Fetch single row as dict."""
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor() as cur:
            await cur.execute(query, args or ())
            return await cur.fetchone()


async def fetchall(query: str, args=None) -> list[dict]:
    """Fetch all rows as list of dicts."""
    pool = await get_pool()
    async with pool.acquire() as conn:
        async with conn.cursor() as cur:
            await cur.execute(query, args or ())
            return await cur.fetchall()


# ─────────────────────────────────────────────
# ALIASES (compatibility)
# ─────────────────────────────────────────────
async def fetch_one(query: str, params=None):
    return await fetchone(query, params)


async def fetch_all(query: str, params=None):
    return await fetchall(query, params)


async def execute_query(query: str, params=None):
    return await execute(query, params)