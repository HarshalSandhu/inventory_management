import hmac
import hashlib
import time

from fastapi import APIRouter, Depends, HTTPException, Request, Response
from pydantic import BaseModel

from config import ADMIN_PASSWORD, SESSION_SECRET, SESSION_MAX_AGE_SECONDS

SESSION_COOKIE = "session"


def _sign(expiry: str) -> str:
    return hmac.new(SESSION_SECRET.encode(), expiry.encode(), hashlib.sha256).hexdigest()


def create_session_token() -> str:
    expiry = str(int(time.time()) + SESSION_MAX_AGE_SECONDS)
    return f"{expiry}.{_sign(expiry)}"


def verify_session_token(token: str) -> bool:
    try:
        expiry, sig = token.split(".", 1)
    except (ValueError, AttributeError):
        return False
    if not hmac.compare_digest(sig, _sign(expiry)):
        return False
    return int(expiry) > time.time()


def require_admin(request: Request) -> None:
    token = request.cookies.get(SESSION_COOKIE)
    if not token or not verify_session_token(token):
        raise HTTPException(401, "Not authenticated")


# ─── Auth endpoints (unprotected — these issue/clear the session itself) ─────

auth_router = APIRouter()


class LoginIn(BaseModel):
    password: str


@auth_router.post("/auth/login", tags=["Auth"])
def login(data: LoginIn, response: Response):
    if not hmac.compare_digest(data.password, ADMIN_PASSWORD):
        raise HTTPException(401, "Incorrect password")

    token = create_session_token()
    response.set_cookie(
        SESSION_COOKIE,
        token,
        max_age=SESSION_MAX_AGE_SECONDS,
        httponly=True,
        samesite="lax",
    )
    return {"message": "Logged in"}


@auth_router.post("/auth/logout", tags=["Auth"])
def logout(response: Response):
    response.delete_cookie(SESSION_COOKIE)
    return {"message": "Logged out"}


@auth_router.get("/auth/status", tags=["Auth"])
def status(request: Request):
    token = request.cookies.get(SESSION_COOKIE)
    return {"authenticated": bool(token and verify_session_token(token))}
