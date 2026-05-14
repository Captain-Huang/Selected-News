"""Unified response payload helper."""

from typing import Any


def ok(data: Any, message: str = "ok", code: int = 0) -> dict[str, Any]:
    return {"code": code, "message": message, "data": data}

