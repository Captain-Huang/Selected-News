"""RSS ingestion service."""

from datetime import datetime, timezone
from time import struct_time

import feedparser
from dateutil import parser as date_parser
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import settings
from app.models.category import Category
from app.models.news_item import NewsItem
from app.models.source import Source, SourceType
from app.services.dedup import build_dedup_hash
from app.services.filtering import parse_keywords, should_keep_item


def _pick_cover_image(entry: feedparser.FeedParserDict) -> str:
    media_content = entry.get("media_content") or []
    if media_content and isinstance(media_content, list):
        first = media_content[0]
        if isinstance(first, dict) and first.get("url"):
            return str(first["url"])

    media_thumbnail = entry.get("media_thumbnail") or []
    if media_thumbnail and isinstance(media_thumbnail, list):
        first = media_thumbnail[0]
        if isinstance(first, dict) and first.get("url"):
            return str(first["url"])

    image = entry.get("image")
    if isinstance(image, dict) and image.get("href"):
        return str(image["href"])

    return ""


def _parse_published(entry: feedparser.FeedParserDict) -> datetime:
    parsed = entry.get("published_parsed") or entry.get("updated_parsed")
    if isinstance(parsed, struct_time):
        return datetime.fromtimestamp(
            datetime(*parsed[:6], tzinfo=timezone.utc).timestamp(),
            tz=timezone.utc,
        ).replace(tzinfo=None)

    published_raw = entry.get("published") or entry.get("updated")
    if isinstance(published_raw, str) and published_raw.strip():
        try:
            dt = date_parser.parse(published_raw)
            if dt.tzinfo:
                dt = dt.astimezone(timezone.utc).replace(tzinfo=None)
            return dt
        except (ValueError, TypeError):
            pass

    return datetime.utcnow()


def _entry_text(entry: feedparser.FeedParserDict, key: str) -> str:
    value = entry.get(key)
    if isinstance(value, str):
        return value.strip()
    return ""


def fetch_rss_for_category(db: Session, category: Category) -> dict[str, int]:
    sources = db.scalars(
        select(Source).where(
            Source.category_id == category.id,
            Source.enabled.is_(True),
            Source.type == SourceType.RSS.value,
        )
    ).all()

    include_keywords = parse_keywords(category.include_keywords)
    exclude_keywords = parse_keywords(category.exclude_keywords)

    inserted = 0
    updated = 0
    skipped = 0

    for source in sources:
        parsed = feedparser.parse(source.base_url)
        for entry in parsed.entries[: settings.rss_fetch_limit_per_source]:
            title = _entry_text(entry, "title")
            summary = _entry_text(entry, "summary") or _entry_text(entry, "description")
            url = _entry_text(entry, "link")
            published_at = _parse_published(entry)
            cover_image = _pick_cover_image(entry)

            if not title:
                skipped += 1
                continue

            if not should_keep_item(
                title=title,
                summary=summary,
                include_keywords=include_keywords,
                exclude_keywords=exclude_keywords,
            ):
                skipped += 1
                continue

            dedup_hash = build_dedup_hash(url=url, title=title, source_name=source.name)
            existing = db.scalar(select(NewsItem).where(NewsItem.dedup_hash == dedup_hash))

            if existing:
                if published_at > existing.published_at:
                    existing.title = title
                    existing.summary = summary
                    existing.url = url or existing.url
                    existing.cover_image = cover_image
                    existing.published_at = published_at
                    existing.fetched_at = datetime.utcnow()
                    updated += 1
                else:
                    skipped += 1
                continue

            db.add(
                NewsItem(
                    category_id=category.id,
                    source_id=source.id,
                    title=title,
                    summary=summary,
                    url=url,
                    cover_image=cover_image,
                    published_at=published_at,
                    fetched_at=datetime.utcnow(),
                    tags="[]",
                    score=0,
                    dedup_hash=dedup_hash,
                )
            )
            inserted += 1

    db.commit()
    return {"inserted": inserted, "updated": updated, "skipped": skipped, "sources": len(sources)}

