"""Source schemas."""

from datetime import datetime

from pydantic import BaseModel, Field


class SourceCreate(BaseModel):
    category_id: int
    name: str = Field(min_length=1, max_length=100)
    base_url: str = Field(min_length=1, max_length=500)
    type: str = "rss"
    enabled: bool = True
    parser_config: str = "{}"


class SourceUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=100)
    base_url: str | None = Field(default=None, min_length=1, max_length=500)
    type: str | None = None
    enabled: bool | None = None
    parser_config: str | None = None


class SourceRead(BaseModel):
    id: int
    category_id: int
    name: str
    base_url: str
    type: str
    enabled: bool
    parser_config: str
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}

