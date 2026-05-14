"""Deduplication helpers."""

from hashlib import sha256
from urllib.parse import urlsplit


def normalize_url(url: str) -> str:
    if not url:
        return ""
    parsed = urlsplit(url.strip())
    path = parsed.path.rstrip("/")
    return f"{parsed.scheme.lower()}://{parsed.netloc.lower()}{path}"


def build_dedup_hash(url: str, title: str, source_name: str) -> str:
    normalized_url = normalize_url(url)
    if normalized_url:
        raw = normalized_url
    else:
        raw = f"{title.strip().lower()}::{source_name.strip().lower()}"
    return sha256(raw.encode("utf-8")).hexdigest()

