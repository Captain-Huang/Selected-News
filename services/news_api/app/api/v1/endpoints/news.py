"""News endpoints."""

from fastapi import APIRouter, Depends, Query
from sqlalchemy import desc, select
from sqlalchemy.orm import Session

from app.core.response import ok
from app.db.session import get_db
from app.models.category import Category
from app.models.news_item import NewsItem
from app.schemas.news import NewsRead
from app.services.rss_fetcher import fetch_rss_for_category


router = APIRouter(tags=["news"])


@router.get("/news")
def list_news(
    category: str = Query(..., min_length=1),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    refresh: bool = Query(True),
    db: Session = Depends(get_db),
) -> dict:
    category_obj = db.scalar(select(Category).where(Category.name == category, Category.enabled.is_(True)))
    if not category_obj:
        return ok(data={"items": [], "page": page, "page_size": page_size, "total": 0}, message="category not found")

    sync_stats = None
    if refresh:
        sync_stats = fetch_rss_for_category(db, category_obj)

    total = db.query(NewsItem).filter(NewsItem.category_id == category_obj.id).count()
    offset = (page - 1) * page_size
    rows = (
        db.scalars(
            select(NewsItem)
            .where(NewsItem.category_id == category_obj.id)
            .order_by(desc(NewsItem.published_at), desc(NewsItem.id))
            .offset(offset)
            .limit(page_size)
        ).all()
    )

    data = {
        "items": [NewsRead.model_validate(item).model_dump() for item in rows],
        "page": page,
        "page_size": page_size,
        "total": total,
        "sync": sync_stats,
    }
    return ok(data=data)

