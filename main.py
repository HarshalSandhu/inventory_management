import uvicorn
from contextlib import asynccontextmanager
from pathlib import Path
from fastapi import FastAPI
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles

from db.database import init_db


@asynccontextmanager
async def lifespan(app: FastAPI):
    init_db()
    print("[STARTUP] Database initialised")
    yield


app = FastAPI(
    title="Inventory & B2B Order Management", version="1.0.0", lifespan=lifespan
)

from api.routes import router
from auth import auth_router

app.include_router(auth_router, prefix="/api")
app.include_router(router, prefix="/api")

dashboard_dir = Path(__file__).parent / "dashboard"
receipts_dir = Path(__file__).parent / "receipts"
receipts_dir.mkdir(exist_ok=True)

app.mount("/receipts", StaticFiles(directory=str(receipts_dir)), name="receipts")


@app.get("/")
def serve_dashboard():
    return FileResponse(str(dashboard_dir / "index.html"))


if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=False)
