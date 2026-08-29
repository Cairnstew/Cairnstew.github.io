#!/usr/bin/env python3
"""Thin CRUD MCP server for CV content.

Mirrors the hand-rolled JSON-RPC 2.0 stdio transport of the goals MCP server:
  - protocol loop (initialize / tools/list / tools/call dispatch):
      modules/home/goals/mcp_server.py:1518-1567
  - stdio line loop:                     modules/home/goals/mcp_server.py:1599-1609
  - init_db applying schema.sql:         modules/home/goals/mcp_server.py:23-34
  - send helper:                         modules/home/goals/mcp_server.py:1512-1516
  - argparse main:                       modules/home/goals/mcp_server.py:1570-1583

Deliberately NO learning_* gating machinery (Tier 1 locked decision): only
cv_list / cv_add / cv_update / cv_delete, one schema, one `published` boolean.

Requires only python3 + sqlite3 (stdlib), like the goals server
(modules/home/goals/mcp_server.py:5-16).

Usage: mcp_server.py --db <cv.db> --schema schema.sql
"""

import argparse
import json
import os
import sqlite3
import sys

SCHEMA_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "schema.sql")

# content_type -> (table, editable columns). Editable columns are whitelisted
# so tool args can never inject SQL.
TABLES = {
    "skills": {
        "table": "skills",
        "columns": ["name", "category", "proficiency", "sort_order", "published"],
    },
    "experience": {
        "table": "experience",
        "columns": [
            "role",
            "organization",
            "start_year",
            "end_year",
            "description",
            "url",
            "sort_order",
            "published",
        ],
    },
    "hobbies": {
        "table": "hobbies",
        "columns": ["name", "description", "sort_order", "published"],
    },
}

conn: sqlite3.Connection | None = None


def init_db(db_path: str, schema_path: str | None = None) -> sqlite3.Connection:
    """Open (creating if needed) the DB and apply schema.sql. Mirrors the goals
    server's init_db (modules/home/goals/mcp_server.py:23-34)."""
    c = sqlite3.connect(db_path)
    c.row_factory = sqlite3.Row
    schema = schema_path or SCHEMA_PATH
    if os.path.exists(schema):
        with open(schema) as f:
            c.executescript(f.read())
    return c


# ── Tool implementations (thin CRUD, no gates) ────────────────────────────────

def cv_list(content_type: str, published_only: bool = False) -> list[dict]:
    """List rows for one content type. published_only=True hides drafts."""
    spec = TABLES.get(content_type)
    if spec is None:
        raise ValueError(f"unknown content_type '{content_type}' (expected skills|experience|hobbies)")
    table = spec["table"]
    where = "WHERE published = 1" if published_only else ""
    rows = conn.execute(
        f"SELECT * FROM {table} {where} ORDER BY sort_order ASC, id ASC"
    ).fetchall()
    return [dict(r) for r in rows]


def _coerce(spec: dict, data: dict) -> dict:
    """Validate field names against the whitelist and coerce ints/bool."""
    allowed = set(spec["columns"])
    unknown = set(data) - allowed
    if unknown:
        raise ValueError(f"unknown field(s) {sorted(unknown)} for {spec['table']}")
    out = dict(data)
    for key in ("sort_order", "start_year", "end_year"):
        if key in out and out[key] is not None:
            try:
                out[key] = int(out[key])
            except (TypeError, ValueError):
                raise ValueError(f"field '{key}' must be an integer")
    if "published" in out and out["published"] is not None:
        out["published"] = 1 if out["published"] in (True, 1, "1", "true") else 0
    return out


def cv_add(content_type: str, data: dict) -> dict:
    """Insert a row. data must contain at least one editable column."""
    spec = TABLES.get(content_type)
    if spec is None:
        raise ValueError(f"unknown content_type '{content_type}'")
    table = spec["table"]
    vals = _coerce(spec, data or {})
    if not vals:
        raise ValueError("cv_add requires at least one field in data")
    cols = ", ".join(vals)
    marks = ", ".join("?" for _ in vals)
    cur = conn.execute(
        f"INSERT INTO {table} ({cols}) VALUES ({marks})", tuple(vals.values())
    )
    conn.commit()
    row = conn.execute(f"SELECT * FROM {table} WHERE id = ?", (cur.lastrowid,)).fetchone()
    return dict(row)


def cv_update(content_type: str, id: int, data: dict) -> dict:
    """Update an existing row by id. Missing fields are left unchanged."""
    spec = TABLES.get(content_type)
    if spec is None:
        raise ValueError(f"unknown content_type '{content_type}'")
    table = spec["table"]
    vals = _coerce(spec, data or {})
    if not vals:
        raise ValueError("cv_update requires at least one field in data")
    assignments = ", ".join(f"{col} = ?" for col in vals)
    cur = conn.execute(
        f"UPDATE {table} SET {assignments}, updated_at = datetime('now') WHERE id = ?",
        (*vals.values(), int(id)),
    )
    conn.commit()
    if cur.rowcount == 0:
        raise ValueError(f"no row with id {id} in '{content_type}'")
    row = conn.execute(f"SELECT * FROM {table} WHERE id = ?", (int(id),)).fetchone()
    return dict(row)


def cv_delete(content_type: str, id: int) -> dict:
    """Delete a row. Returns the deleted row so the caller can undo/confirm."""
    spec = TABLES.get(content_type)
    if spec is None:
        raise ValueError(f"unknown content_type '{content_type}'")
    table = spec["table"]
    row = conn.execute(f"SELECT * FROM {table} WHERE id = ?", (int(id),)).fetchone()
    if row is None:
        raise ValueError(f"no row with id {id} in '{content_type}'")
    conn.execute(f"DELETE FROM {table} WHERE id = ?", (int(id),))
    conn.commit()
    return dict(row)


# ── JSON-RPC 2.0 protocol (mirrors goals transport) ───────────────────────────

TOOLS: list[dict] = [
    {
        "name": "cv_list",
        "description": "List CV content rows for a content type (skills|experience|hobbies). Set published_only=true to hide drafts.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "content_type": {"type": "string", "description": "skills, experience, or hobbies"},
                "published_only": {"type": "boolean", "description": "Only show published rows (default false)"},
            },
            "required": ["content_type"],
        },
    },
    {
        "name": "cv_add",
        "description": "Add a CV content row for a content type. Fields depend on content_type; publish by setting published=true.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "content_type": {"type": "string"},
                "data": {
                    "type": "object",
                    "description": "Editable fields for the content type (see schema.sql).",
                },
            },
            "required": ["content_type", "data"],
        },
    },
    {
        "name": "cv_update",
        "description": "Update a CV content row by id. Only the fields in data are changed.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "content_type": {"type": "string"},
                "id": {"type": "integer"},
                "data": {"type": "object"},
            },
            "required": ["content_type", "id", "data"],
        },
    },
    {
        "name": "cv_delete",
        "description": "Delete a CV content row by id. Returns the deleted row.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "content_type": {"type": "string"},
                "id": {"type": "integer"},
            },
            "required": ["content_type", "id"],
        },
    },
]

TOOL_DISPATCH = {
    "cv_list": cv_list,
    "cv_add": cv_add,
    "cv_update": cv_update,
    "cv_delete": cv_delete,
}


def send(msg: dict) -> None:
    """Write one JSON-RPC response to stdout. Mirrors goals send()
    (modules/home/goals/mcp_server.py:1512-1516)."""
    sys.stdout.write(json.dumps(msg) + "\n")
    sys.stdout.flush()


def handle_request(msg: dict) -> dict | None:
    """Dispatch one JSON-RPC request. Mirrors the goals protocol loop
    (modules/home/goals/mcp_server.py:1518-1567)."""
    method: str = msg.get("method", "")
    _id = msg.get("id")
    params: dict = msg.get("params", {})

    if method == "initialize":
        return {
            "jsonrpc": "2.0",
            "id": _id,
            "result": {
                "protocolVersion": "2024-11-05",
                "capabilities": {"tools": {}},
                "serverInfo": {"name": "cv-mcp", "version": "0.1.0"},
            },
        }
    elif method == "notifications/initialized":
        return None
    elif method == "tools/list":
        return {"jsonrpc": "2.0", "id": _id, "result": {"tools": TOOLS}}
    elif method == "tools/call":
        tool_name = params.get("name", "")
        arguments = params.get("arguments", {})
        fn = TOOL_DISPATCH.get(tool_name)
        if fn is None:
            return {
                "jsonrpc": "2.0",
                "id": _id,
                "error": {"code": -32601, "message": f"Unknown tool: {tool_name}"},
            }
        try:
            result = fn(**arguments)
            text = json.dumps(result, indent=2, default=str)
            return {
                "jsonrpc": "2.0",
                "id": _id,
                "result": {"content": [{"type": "text", "text": text}]},
            }
        except Exception as e:
            return {
                "jsonrpc": "2.0",
                "id": _id,
                "error": {"code": -32603, "message": f"{e}"},
            }
    else:
        return {
            "jsonrpc": "2.0",
            "id": _id,
            "error": {"code": -32601, "message": f"Method not found: {method}"},
        }


def main() -> None:
    global conn

    parser = argparse.ArgumentParser(description="CV content MCP server")
    parser.add_argument("--db", required=True, help="Path to SQLite database file")
    parser.add_argument("--schema", default=None, help="Path to schema.sql (defaults to sibling of this script)")
    args = parser.parse_args()

    conn = init_db(args.db, schema_path=args.schema)

    # stdio line loop — mirrors goals main() (modules/home/goals/mcp_server.py:1599-1609)
    for raw in sys.stdin:
        line = raw.strip()
        if not line:
            continue
        try:
            msg = json.loads(line)
        except json.JSONDecodeError:
            continue
        resp = handle_request(msg)
        if resp is not None:
            send(resp)


if __name__ == "__main__":
    main()