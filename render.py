#!/usr/bin/env python3
"""Render the CV SQLite store into Zola content files.

NEW PIECE — no in-repo precedent (Tier 1 A5; the only analog anywhere is the
goals MCP's sqlite store, and it never renders content files). Approach:

  - Source of truth: SQLite (written by the cv MCP server, schema.sql).
  - Output: content/<type>/<slug>.md, one file per row, OVERWRITTEN on every
    run — the output is a pure function of the store, so rendering is
    idempotent and the committed files are just the rendered snapshot.
  - Front matter: TOML, keys mirror the DB columns, matching the shape of the
    hand-written seed files in content/ (title, weight, [extra], draft) so
    either path — hand-authored .md or store-then-render — yields the same
    site.
  - draft flag = NOT published. Zola excludes draft pages from builds, so a
    row stays invisible until the MCP flips published=1 and render.py runs.
  - Slug: lowercase title, spaces→dashes, non-alphanumerics stripped; on
    collision the numeric id is appended so output is deterministic and
    never clobbers a different row.
  - Freeform prose maps to the `description` column → page body.

Usage:  python3 render.py --db cv.db [--content-dir content]
"""

import argparse
import os
import re
import sqlite3
import unicodedata

SCHEMA_DEFAULT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "schema.sql")

# content_type -> (table, title_column, extra_fields, body_column)
TYPES = {
    "skills": {
        "table": "skills",
        "title": "name",
        "extra": ["category", "proficiency"],
        "body": "description",
    },
    "experience": {
        "table": "experience",
        "title": "role",
        "extra": ["organization", "start_year", "end_year", "url"],
        "body": "description",
    },
    "hobbies": {
        "table": "hobbies",
        "title": "name",
        "extra": [],
        "body": "description",
    },
}


def slugify(text: str) -> str:
    """Best-effort URL slug from a title. Kept conservative and deterministic."""
    text = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode()
    text = re.sub(r"[^a-zA-Z0-9]+", "-", text.lower())
    return text.strip("-") or "untitled"


def render_row(section: str, row: dict, used: dict) -> tuple[str, str]:
    """Build (filename, content) for one row. `used` tracks slug occurrences."""
    spec = TYPES[section]
    title = row[spec["title"]]
    base = slugify(title)
    n = used.get(section + "/" + base, 0)
    used[section + "/" + base] = n + 1
    slug = base if n == 0 else f"{base}-{n}"
    filename = f"{section}/{slug}.md"

    extra = "\n".join(f"{k} = {json_quote(v)}" for k, v in
                      ((k, row[k]) for k in spec["extra"]) if v not in (None, ""))
    body = (row[spec["body"]] or "").strip()

    front = ["+++", f"title = {json_quote(title)}", f"weight = {int(row['sort_order'] or 0)}"]
    if "start_year" in row and row["start_year"]:
        front.append(f"date = {int(row['start_year'])}-01-01")
    front.append(f"draft = {str(not bool(row['published'])).lower()}")
    if extra:
        front += ["", "[extra]", extra]
    front += ["+++", ""]

    markdown = "\n".join(front)
    if body:
        markdown += body + "\n"
    return filename, markdown


def list_row(conn: sqlite3.Connection, table: str) -> list[dict]:
    rows = conn.execute(f"SELECT * FROM {table} ORDER BY sort_order ASC, id ASC").fetchall()
    return [dict(r) for r in rows]


def main() -> None:
    parser = argparse.ArgumentParser(description="Render the CV sqlite store into Zola content")
    parser.add_argument("--db", required=True, help="Path to the SQLite content database")
    parser.add_argument("--schema", default=None, help="Path to schema.sql (defaults to sibling)")
    parser.add_argument("--content-dir", default="content", help="Zola content root (default: content)")
    args = parser.parse_args()

    conn = sqlite3.connect(args.db)
    conn.row_factory = sqlite3.Row

    used: dict[str, int] = {}
    written: list[str] = []
    for section, spec in TYPES.items():
        for row in list_row(conn, spec["table"]):
            filename, content = render_row(section, row, used)
            out = os.path.join(args.content_dir, filename)
            os.makedirs(os.path.dirname(out), exist_ok=True)
            with open(out, "w") as f:
                f.write(content)
            written.append(filename)
            print(f"wrote {filename}")

    print(f"\n{len(written)} content file(s) written to {args.content_dir}/"
          f" ({len(TYPES)} sections)")


def json_quote(v) -> str:
    """TOML-quote a scalar. Bare strings get doubled-quoted; ints stay bare."""
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, int):
        return str(v)
    import json as _json
    return _json.dumps(str(v), ensure_ascii=False)


if __name__ == "__main__":
    main()