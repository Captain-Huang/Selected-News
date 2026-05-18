"""Bootstrap seed data."""

from collections.abc import Sequence

from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import settings
from app.models.category import Category
from app.models.source import Source, SourceType


DEFAULT_SOURCE_GROUPS: Sequence[Sequence[tuple[str, str]]] = (
    (
        ("OpenAI Blog", "https://openai.com/blog/rss.xml"),
        ("Hugging Face Blog", "https://huggingface.co/blog/feed.xml"),
        ("DeepMind Blog", "https://deepmind.google/discover/blog/rss.xml"),
    ),
    (
        ("TechCrunch", "https://techcrunch.com/feed/"),
        ("The Verge", "https://www.theverge.com/rss/index.xml"),
        ("Ars Technica", "https://arstechnica.com/feed/"),
    ),
    (
        ("CNBC Top News", "https://www.cnbc.com/id/100003114/device/rss/rss.html"),
        ("MarketWatch Top Stories", "https://feeds.marketwatch.com/marketwatch/topstories/"),
        ("Investing.com News", "https://www.investing.com/rss/news_25.rss"),
    ),
    (
        ("BBC World", "https://feeds.bbci.co.uk/news/world/rss.xml"),
        ("NPR News", "https://www.npr.org/rss/rss.php?id=1001"),
        ("NYTimes World", "https://rss.nytimes.com/services/xml/rss/nyt/World.xml"),
    ),
    (
        ("GitHub Blog", "https://github.blog/feed/"),
        ("InfoQ", "https://www.infoq.com/feed/"),
        ("Stack Overflow Blog", "https://stackoverflow.blog/feed/"),
    ),
)


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

    _bootstrap_sources(db)


def _bootstrap_sources(db: Session) -> None:
    categories = db.scalars(select(Category).order_by(Category.sort_order.asc())).all()
    if not categories:
        return

    existing_pairs = set(db.execute(select(Source.category_id, Source.base_url)).all())
    created = False

    for index, category in enumerate(categories):
        if index >= len(DEFAULT_SOURCE_GROUPS):
            break

        for source_name, source_url in DEFAULT_SOURCE_GROUPS[index]:
            key = (category.id, source_url)
            if key in existing_pairs:
                continue

            db.add(
                Source(
                    category_id=category.id,
                    name=source_name,
                    base_url=source_url,
                    type=SourceType.RSS.value,
                    enabled=True,
                    parser_config="{}",
                )
            )
            existing_pairs.add(key)
            created = True

    if created:
        db.commit()
