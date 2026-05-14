"""Application configuration."""

from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class Settings:
    app_name: str = "Selected News API"
    api_v1_prefix: str = "/v1"
    db_file: str = "news.db"
    bootstrap_categories: tuple[str, ...] = ("AI", "科技", "财经", "事件", "技术")
    rss_fetch_limit_per_source: int = 30

    @property
    def database_url(self) -> str:
        db_path = Path(self.db_file).resolve()
        return f"sqlite:///{db_path}"


settings = Settings()
