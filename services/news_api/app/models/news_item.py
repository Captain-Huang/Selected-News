"""News item model."""

from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class NewsItem(Base):
    __tablename__ = "news_items"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    category_id: Mapped[int] = mapped_column(Integer, ForeignKey("categories.id"), index=True)
    source_id: Mapped[int] = mapped_column(Integer, ForeignKey("sources.id"), index=True)
    title: Mapped[str] = mapped_column(String(500))
    summary: Mapped[str] = mapped_column(Text, default="")
    url: Mapped[str] = mapped_column(String(1200), index=True)
    cover_image: Mapped[str] = mapped_column(String(1200), default="")
    published_at: Mapped[datetime] = mapped_column(DateTime, index=True)
    fetched_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow, index=True)
    tags: Mapped[str] = mapped_column(String(500), default="[]")
    score: Mapped[int] = mapped_column(Integer, default=0)
    dedup_hash: Mapped[str] = mapped_column(String(64), unique=True, index=True)

