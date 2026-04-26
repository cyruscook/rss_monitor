from rss_monitor.repository import FeedRepository
from base64 import b64decode
from html import escape
from typing import Any, Protocol
from urllib.parse import parse_qs, urlparse

import feedparser
from aws_lambda_powertools.utilities.data_classes import LambdaFunctionUrlEvent

from rss_monitor.feed_checker import USER_AGENT, fetch_feed_title
from rss_monitor.models import Feed


def handle_url_event(
    event: LambdaFunctionUrlEvent, repository: FeedRepository
) -> dict[str, object]:
    method = event.request_context.http.method.upper()
    if method == "POST":
        return handle_post(event, repository)
    if method == "GET":
        return create_reponse(render_page(repository), 200)
    return create_reponse("Method not allowed", 405)


def handle_post(
    event: LambdaFunctionUrlEvent, repository: FeedRepository
) -> dict[str, object]:
    body = event.body or ""
    if event.is_base64_encoded:
        body = b64decode(body).decode("utf-8")
    form = parse_qs(body, keep_blank_values=False)
    action = form.get("action", ["subscribe"])[0]
    feed_url = form.get("feed_url", [""])[0].strip()
    if not is_valid_feed_url(feed_url):
        return create_reponse(
            render_page(repository, "Enter a valid http or https feed URL."), 400
        )
    if action == "unsubscribe":
        repository.delete_feed(feed_url)
        return create_reponse(render_page(repository, None), 200)
    if action != "subscribe":
        return create_reponse(render_page(repository, "Unsupported form action."), 400)
    try:
        name = fetch_feed_title(feed_url)
    except ValueError as exc:
        return create_reponse(render_page(repository, str(exc)), 400)
    repository.put_feed(feed_url, name)
    return create_reponse(render_page(repository, None), 201)


def render_page(repository: FeedRepository, error: str | None = None) -> str:
    feeds = repository.list_feeds()
    rows = "".join(
        [
            f"""
<tr>
    <td><a href="{escape(feed.feed_url, quote=True)}">{escape(feed.name)}</a></td>
        <td>{escape(feed.last_checked.isoformat())}</td>
        <td>{escape(feed.last_item or "")}</td>
        <td>
        <form method="post" class="inline-form">
        <input type="hidden" name="action" value="unsubscribe">
        <input type="hidden" name="feed_url" value="{escape(feed.feed_url, quote=True)}">
        <button type="submit">Unsubscribe</button>
        </form>
    </td>
</tr>
    """
            for feed in feeds
        ]
    )
    error_html = f'<p class="error">{escape(error)}</p>' if error else ""
    return f"""<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>RSS Monitor</title>
    <style>
        body {{ font-family: sans-serif; max-width: 900px; margin: 2rem auto; padding: 0 1rem; }}
        label {{ margin: 0.75rem 0 0.25rem; }}
        input {{ box-sizing: border-box; padding: 0.5rem; width: min(100%, 36rem); }}
        button {{ margin-top: 1rem; padding: 0.55rem 0.8rem; }}
        .inline-form {{ margin: 0; }}
        .inline-form button {{ margin-top: 0; }}
        table {{ border-collapse: collapse; margin-top: 2rem; width: 100%; }}
        th, td {{ border-bottom: 1px solid #ddd; padding: 0.5rem; text-align: left; vertical-align: top; }}
        td:nth-child(2) {{ overflow-wrap: anywhere; }}
        .error {{ color: #a40000; }}
    </style>
</head>
<body>
    <h1>RSS Monitor</h1>
    {error_html}
    <form method="post">
        <input type="hidden" name="action" value="subscribe">
        <label for="feed_url">Add a new feed:</label>
        <input id="feed_url" name="feed_url" placeholder="Feed URL" type="url" required>
        <button type="submit">Subscribe</button>
    </form>
    <table>
        <thead><tr><th>Name</th><th>Last checked</th><th>Last item</th><th>Actions</th></tr></thead>
        <tbody>{rows}</tbody>
    </table>
</body>
</html>"""


def is_valid_feed_url(feed_url: str) -> bool:
    parsed = urlparse(feed_url)
    return parsed.scheme in {"http", "https"} and bool(parsed.netloc)


def create_reponse(body: str, status_code: int) -> dict[str, object]:
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "text/html; charset=utf-8"},
        "body": body,
    }
