"""Bootstrap seed data."""

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import settings
from app.models.category import Category


def bootstrap_categories(db: Session) -> None:
    existing_names = set(db.scalars(select(Category.name)).all())
    created = False
    for index, name in enumerate(settings.bootstrap_categories):
        if name in existing_names:
            continue
        db.add(
            Category(
                name=name,
                sort_order=index,
                enabled=True,
                include_keywords="",
                exclude_keywords="",
            )
        )
        created = True

    if created:
        db.commit()

