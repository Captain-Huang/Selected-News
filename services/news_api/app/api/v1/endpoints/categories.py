"""Categories endpoints."""

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.response import ok
from app.db.session import get_db
from app.models.category import Category
from app.schemas.category import CategoryRead


router = APIRouter(tags=["categories"])


@router.get("/categories")
def list_categories(db: Session = Depends(get_db)) -> dict:
    categories = db.scalars(
        select(Category)
        .where(Category.enabled.is_(True))
        .order_by(Category.sort_order.asc(), Category.id.asc())
    ).all()
    data = [CategoryRead.model_validate(item).model_dump() for item in categories]
    return ok(data=data)

