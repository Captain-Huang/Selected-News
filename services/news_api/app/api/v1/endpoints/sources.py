"""Sources endpoints."""

from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.response import ok
from app.db.session import get_db
from app.models.category import Category
from app.models.source import Source
from app.schemas.source import SourceCreate, SourceRead, SourceUpdate


router = APIRouter(tags=["sources"])


@router.get("/sources")
def list_sources(
    category_id: int | None = Query(default=None, ge=1),
    enabled: bool | None = Query(default=None),
    db: Session = Depends(get_db),
) -> dict:
    stmt = select(Source)
    if category_id is not None:
        stmt = stmt.where(Source.category_id == category_id)
    if enabled is not None:
        stmt = stmt.where(Source.enabled.is_(enabled))

    rows = db.scalars(stmt.order_by(Source.id.desc())).all()
    data = [SourceRead.model_validate(item).model_dump() for item in rows]
    return ok(data=data)


@router.post("/sources")
def create_source(payload: SourceCreate, db: Session = Depends(get_db)) -> dict:
    category = db.scalar(select(Category).where(Category.id == payload.category_id))
    if not category:
        raise HTTPException(status_code=404, detail="category not found")

    source = Source(**payload.model_dump())
    db.add(source)
    db.commit()
    db.refresh(source)
    return ok(data=SourceRead.model_validate(source).model_dump(), message="created")


@router.put("/sources/{source_id}")
def update_source(source_id: int, payload: SourceUpdate, db: Session = Depends(get_db)) -> dict:
    source = db.scalar(select(Source).where(Source.id == source_id))
    if not source:
        raise HTTPException(status_code=404, detail="source not found")

    update_data = payload.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(source, field, value)
    source.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(source)
    return ok(data=SourceRead.model_validate(source).model_dump(), message="updated")


@router.delete("/sources/{source_id}")
def delete_source(source_id: int, db: Session = Depends(get_db)) -> dict:
    source = db.scalar(select(Source).where(Source.id == source_id))
    if not source:
        raise HTTPException(status_code=404, detail="source not found")
    db.delete(source)
    db.commit()
    return ok(data={"id": source_id}, message="deleted")
