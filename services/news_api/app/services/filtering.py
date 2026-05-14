"""Filtering rules for news entries."""

from collections.abc import Iterable


def parse_keywords(raw: str) -> list[str]:
    if not raw:
        return []
    return [part.strip().lower() for part in raw.split(",") if part.strip()]


def should_keep_item(
    *,
    title: str,
    summary: str,
    include_keywords: Iterable[str],
    exclude_keywords: Iterable[str],
) -> bool:
    haystack = f"{title} {summary}".lower()

    include_list = list(include_keywords)
    if include_list and not any(word in haystack for word in include_list):
        return False

    exclude_list = list(exclude_keywords)
    if exclude_list and any(word in haystack for word in exclude_list):
        return False

    return True

