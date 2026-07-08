import os
import secrets
from pathlib import Path

try:
    from dotenv import load_dotenv

    env_path = Path(__file__).parent / ".env"
    if env_path.exists():
        load_dotenv(env_path)
except ImportError:
    pass

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "mysql+pymysql://root@localhost/inventory_management?charset=utf8mb4",
)

UPLOAD_DIR = os.getenv("UPLOAD_DIR", "receipts")

# ─── Admin auth ───────────────────────────────────────────────────────────────
# Override both via environment variables in production. SESSION_SECRET defaults
# to a random value generated at process start, which means existing sessions
# are invalidated on every restart unless it's pinned via env var.
ADMIN_PASSWORD = os.getenv("ADMIN_PASSWORD", "ASRAdmin@2026")
SESSION_SECRET = os.getenv("SESSION_SECRET", secrets.token_hex(32))
SESSION_MAX_AGE_SECONDS = int(os.getenv("SESSION_MAX_AGE_SECONDS", 7 * 24 * 3600))
