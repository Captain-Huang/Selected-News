"""Category schemas."""

from pydantic import BaseModel


class CategoryRead(BaseModel):
    id: int
    name: str
    sort_order: int
    enabled: bool
    include_keywords: str
    exclude_keywords: str

    model_config = {"from_attributes": True}

