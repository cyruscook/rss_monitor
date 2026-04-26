from typing import Any

from rss_monitor.models import Feed
from rss_monitor.time_utils import format_iso_datetime, parse_iso_datetime, utc_now


class FeedRepository:
    def __init__(self, table: Any) -> None:
        self.table = table

    def list_feeds(self) -> list[Feed]:
        feeds: list[Feed] = []
        kwargs: dict[str, Any] = {}
        while True:
            response = self.table.scan(**kwargs)
            feeds.extend(feed_from_item(item) for item in response.get("Items", []))
            last_key = response.get("LastEvaluatedKey")
            if not last_key:
                return sorted(feeds, key=lambda feed: feed.name.lower())
            kwargs["ExclusiveStartKey"] = last_key

    def list_feed_urls(self) -> list[str]:
        urls: list[str] = []
        kwargs: dict[str, Any] = {"ProjectionExpression": "feed_url"}
        while True:
            response = self.table.scan(**kwargs)
            urls.extend(str(item["feed_url"]) for item in response.get("Items", []))
            last_key = response.get("LastEvaluatedKey")
            if not last_key:
                return urls
            kwargs["ExclusiveStartKey"] = last_key

    def get_feed(self, feed_url: str) -> Feed | None:
        response = self.table.get_item(Key={"feed_url": feed_url})
        item = response.get("Item")
        if item is None:
            return None
        return feed_from_item(item)

    def put_feed(self, feed_url: str, name: str) -> None:
        now = format_iso_datetime(utc_now())
        self.table.put_item(
            Item={
                "feed_url": feed_url,
                "name": name,
                "last_checked": now,
                "last_item": "",
            }
        )

    def delete_feed(self, feed_url: str) -> None:
        self.table.delete_item(Key={"feed_url": feed_url})

    def update_after_check(
        self,
        feed_url: str,
        checked_at: str,
        last_item: str | None,
        name: str | None = None,
    ) -> None:
        update_expression = "SET last_checked = :last_checked, last_item = :last_item"
        expression_attribute_values = {
            ":last_checked": checked_at,
            ":last_item": last_item or "",
        }
        if name is not None:
            update_expression += ", name = :name"
            expression_attribute_values[":name"] = name

        self.table.update_item(
            Key={"feed_url": feed_url},
            UpdateExpression=update_expression,
            ExpressionAttributeValues=expression_attribute_values,
        )


def feed_from_item(item: dict[str, Any]) -> Feed:
    return Feed(
        feed_url=str(item["feed_url"]),
        name=str(item.get("name") or item["feed_url"]),
        last_checked=parse_iso_datetime(item.get("last_checked")),
        last_item=str(item.get("last_item") or "") or None,
    )
