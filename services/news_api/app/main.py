"""FastAPI entrypoint."""

from fastapi import FastAPI

from app.api.v1.router import api_router
from app.core.config import settings
from app.db.base import Base
from app.db.session import SessionLocal, engine
from app.services.bootstrap import bootstrap_categories

# Import models so metadata includes all tables.
from app.models.category import Category  # noqa: F401
from app.models.news_item import NewsItem  # noqa: F401
from app.models.source import Source  # noqa: F401


app = FastAPI(title=settings.app_name)
app.include_router(api_router, prefix=settings.api_v1_prefix)


@app.get("/")
def health_check() -> dict:
    return {"status": "ok", "service": settings.app_name}


@app.on_event("startup")
def startup() -> None:
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        bootstrap_categories(db)
    finally:
        db.close()

