from calendar import timegm
from datetime import UTC, datetime, timedelta
from typing import Any

import feedparser
from feedparser.exceptions import CharacterEncodingOverride

from rss_monitor.models import Feed, NewItem
from rss_monitor.time_utils import utc_now

USER_AGENT = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36"


def find_new_items(
    feed: Feed, clock_skew_seconds: int
) -> tuple[list[NewItem], str, datetime, str]:
    parsed = feedparser.parse(feed.feed_url, agent=USER_AGENT)
    check_bozo_exception(parsed)
    feed_name = entry_text(getattr(parsed, "feed", None), "title") or feed.name
    threshold = feed.last_checked - timedelta(seconds=clock_skew_seconds)
    items: list[NewItem] = []
    for entry in getattr(parsed, "entries", []):
        published_at = entry_datetime(entry)
        if published_at is None or published_at <= threshold:
            continue
        guid = (
            entry_text(entry, "id")
            or entry_text(entry, "guid")
            or entry_text(entry, "link")
        )
        if not guid:
            continue
        items.append(
            NewItem(
                feed_url=feed.feed_url,
                feed_name=feed_name,
                title=entry_text(entry, "title") or "(untitled)",
                link=entry_text(entry, "link") or feed.feed_url,
                guid=guid,
                published_at=published_at,
            )
        )

    items.sort(key=lambda item: item.published_at)
    last_item = items[-1].guid if items else (feed.last_item or "")
    return items, last_item, utc_now(), feed_name


def fetch_feed_title(feed_url: str) -> str:
    parsed = feedparser.parse(feed_url, agent=USER_AGENT)
    check_bozo_exception(parsed)
    feed = getattr(parsed, "feed", None)
    title = entry_text(feed, "title")
    if title is None:
        raise ValueError("The RSS feed does not have a title.")
    return title


def entry_datetime(entry: Any) -> datetime | None:
    for key in ("published_parsed", "updated_parsed", "created_parsed"):
        value = getattr(entry, key, None)
        if value is not None:
            return datetime.fromtimestamp(timegm(value), UTC)
    return None


def entry_text(entry: Any, key: str) -> str | None:
    value = getattr(entry, key, None)
    if value is None:
        return None
    text = str(value).strip()
    return text or None


def check_bozo_exception(parsed_feed: Any) -> None:
    bozo_exception = getattr(parsed_feed, "bozo_exception", None)
    if bozo_exception is not None and not isinstance(
        bozo_exception, CharacterEncodingOverride
    ):
        raise ValueError("The RSS feed could not be parsed.") from bozo_exception
