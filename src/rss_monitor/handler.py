from rss_monitor.time_utils import format_iso_datetime
from typing import Any
import boto3
import os

from aws_lambda_powertools import Logger
from aws_lambda_powertools.utilities.data_classes import (
    EventBridgeEvent,
    LambdaFunctionUrlEvent,
    SQSEvent,
)
from aws_lambda_powertools.utilities.typing import LambdaContext

from rss_monitor.feed_checker import find_new_items
from rss_monitor.html import handle_url_event
from rss_monitor.notifications import Notifier
from rss_monitor.queue import FeedQueue
from rss_monitor.repository import FeedRepository

TABLE_NAME = os.getenv("FEEDS_TABLE_NAME", "")
QUEUE_URL = os.getenv("FEED_QUEUE_URL", "")
TOPIC_ARN = os.getenv("NOTIFICATION_TOPIC_ARN", "")
CLOCK_SKEW_SECONDS = int(os.getenv("CLOCK_SKEW_SECONDS", "300"))

if any(x == "" for x in [TABLE_NAME, QUEUE_URL, TOPIC_ARN]):
    raise RuntimeError("Missing required environment variables")

logger = Logger()

ddb_resource = boto3.resource("dynamodb")
sqs_client = boto3.client("sqs")
sns_client = boto3.client("sns")


@logger.inject_lambda_context
def lambda_handler(event: dict[str, Any], context: LambdaContext) -> dict[str, Any]:
    table = ddb_resource.Table(TABLE_NAME)
    repository = FeedRepository(table)
    queue = FeedQueue(sqs_client, QUEUE_URL)
    notifier = Notifier(sns_client, TOPIC_ARN)

    if is_sqs_event(event):
        return handle_sqs(SQSEvent(event), repository, notifier, CLOCK_SKEW_SECONDS)
    if is_lambda_url_event(event):
        return handle_lambda_url(LambdaFunctionUrlEvent(event), repository)
    if is_eventbridge_event(event):
        return handle_eventbridge(EventBridgeEvent(event), repository, queue)

    logger.warning("Unsupported event type")
    return {"statusCode": 400, "body": "Unsupported event"}


def handle_eventbridge(
    event: EventBridgeEvent,
    repository: FeedRepository,
    queue: FeedQueue,
) -> dict[str, int]:
    del event
    feed_urls = repository.list_feed_urls()
    for feed_url in feed_urls:
        queue.enqueue_feed(feed_url)
    logger.info("Queued feeds for checking", extra={"queued_num": len(feed_urls)})
    return {"queued_num": len(feed_urls)}


def handle_sqs(
    event: SQSEvent,
    repository: FeedRepository,
    notifier: Notifier,
    clock_skew_seconds: int,
) -> dict[str, list[dict[str, str]]]:
    failures: list[dict[str, str]] = []
    for record in event.records:
        feed_url = record.body.strip()
        try:
            process_feed(feed_url, repository, notifier, clock_skew_seconds)
        except Exception as exc:
            logger.exception("Failed to process feed", extra={"feed_url": feed_url})
            failures.append({"itemIdentifier": record.message_id})
    return {"batchItemFailures": failures}


def handle_lambda_url(
    event: LambdaFunctionUrlEvent,
    repository: FeedRepository,
) -> dict[str, object]:
    return handle_url_event(event, repository)


def process_feed(
    feed_url: str,
    repository: FeedRepository,
    notifier: Notifier,
    clock_skew_seconds: int,
) -> None:
    feed = repository.get_feed(feed_url)
    if feed is None:
        raise ValueError(f"Feed is not subscribed: {feed_url}")
    new_items, last_item, checked_at, current_name = find_new_items(
        feed, clock_skew_seconds
    )
    for item in new_items:
        notifier.publish_new_item(item)
    repository.update_after_check(
        feed_url,
        format_iso_datetime(checked_at),
        last_item,
        current_name if current_name != feed.name else None,
    )
    logger.info(
        "Processed feed",
        extra={"feed_url": feed_url, "new_items": str(new_items)},
    )


def is_sqs_event(event: dict[str, Any]) -> bool:
    records = event.get("Records")
    return isinstance(records, list) and any(
        record.get("eventSource") == "aws:sqs" for record in records
    )


def is_lambda_url_event(event: dict[str, Any]) -> bool:
    request_context = event.get("requestContext")
    return isinstance(request_context, dict) and isinstance(
        request_context.get("http"), dict
    )


def is_eventbridge_event(event: dict[str, Any]) -> bool:
    source = event.get("source")
    return (
        source in {"aws.events", "aws.scheduler"}
        or event.get("detail-type") == "Scheduled Event"
    )
