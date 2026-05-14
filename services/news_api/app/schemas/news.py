"""News schemas."""

from datetime import datetime

from pydantic import BaseModel


class NewsRead(BaseModel):
    id: int
    category_id: int
    source_id: int
    title: str
    summary: str
    url: str
    cover_image: str
    published_at: datetime
    fetched_at: datetime
    tags: str
    score: int

    model_config = {"from_attributes": True}

