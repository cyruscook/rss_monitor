from datetime import UTC, datetime


def utc_now() -> datetime:
    return datetime.now(UTC)


def parse_iso_datetime(value: str | None) -> datetime:
    if not value:
        return datetime.fromtimestamp(0, UTC)
    parsed = datetime.fromisoformat(value)
    if parsed.tzinfo is None:
        return parsed.replace(tzinfo=UTC)
    return parsed.astimezone(UTC)


def format_iso_datetime(value: datetime) -> str:
    return value.astimezone(UTC).isoformat()
