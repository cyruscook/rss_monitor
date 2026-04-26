import re

from rss_monitor.models import NewItem

BAD_CHARACTERS_RE = re.compile(r"(?:[^\x20-\x7E]|[<>])+")


class Notifier:
    def __init__(self, sns: object, topic_arn: str) -> None:
        self.sns = sns
        self.topic_arn = topic_arn

    def publish_new_item(self, item: NewItem) -> None:
        safe_feed_name = BAD_CHARACTERS_RE.sub("", item.feed_name)
        safe_title = BAD_CHARACTERS_RE.sub("", item.title)
        safe_link = BAD_CHARACTERS_RE.sub("", item.link)
        safe_feed_url = BAD_CHARACTERS_RE.sub("", item.feed_url)
        message = (
            f"New RSS item in {safe_feed_name}\n\n"
            f"Title: {safe_title}\n"
            f"Published: {item.published_at.isoformat()}\n"
            f"URL: {safe_link}\n"
            f"Feed: {safe_feed_url}"
        )
        publish = getattr(self.sns, "publish")
        publish(
            TopicArn=self.topic_arn,
            Subject=f"New RSS item: {safe_feed_name}",
            Message=message,
        )
