from typing import Any


class FeedQueue:
    def __init__(self, sqs: Any, queue_url: str) -> None:
        self.sqs = sqs
        self.queue_url = queue_url

    def enqueue_feed(self, feed_url: str) -> None:
        self.sqs.send_message(QueueUrl=self.queue_url, MessageBody=feed_url)
