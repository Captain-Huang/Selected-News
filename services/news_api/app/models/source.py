"""Source model."""

from datetime import datetime
from enum import Enum

from sqlalchemy import Boolean, DateTime, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class SourceType(str, Enum):
    RSS = "rss"
    API = "api"
    HTML = "html"


class Source(Base):
    __tablename__ = "sources"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    category_id: Mapped[int] = mapped_column(Integer, ForeignKey("categories.id"), index=True)
    name: Mapped[str] = mapped_column(String(100), index=True)
    base_url: Mapped[str] = mapped_column(String(500))
    type: Mapped[str] = mapped_column(String(20), default=SourceType.RSS.value)
    enabled: Mapped[bool] = mapped_column(Boolean, default=True)
    parser_config: Mapped[str] = mapped_column(String(2000), default="{}")
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime,
        default=datetime.utcnow,
        onupdate=datetime.utcnow,
    )

