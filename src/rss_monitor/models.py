from dataclasses import dataclass
from datetime import datetime


@dataclass(frozen=True)
class Feed:
    feed_url: str
    name: str
    last_checked: datetime
    last_item: str | None


@dataclass(frozen=True)
class NewItem:
    feed_url: str
    feed_name: str
    title: str
    link: str
    guid: str
    published_at: datetime
