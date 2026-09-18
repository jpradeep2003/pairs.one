#!/usr/bin/env python3
"""Incremental Cursor transcript harvest into history/ (dev-chat-history skill)."""

from __future__ import annotations

import argparse
import hashlib
import json
import re
from datetime import datetime, timezone
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_TRANSCRIPTS = Path.home() / ".cursor/projects/Users-jpradeep2003-dev-pairs-one/agent-transcripts"
HISTORY_ROOT = PROJECT_ROOT / "history"
USER_QUERY_RE = re.compile(r"<user_query>\s*(.*?)\s*</user_query>", re.DOTALL)
SKIP_QUERY_RE = re.compile(
    r"Execute the selected diff-tab|"
    r"Briefly inform the user about the task result|"
    r"<dynamic_tools>",
    re.I,
)

TAGS = [
    "requirement-analysis",
    "arch-analysis",
    "docs-spec",
    "dev-feature",
    "dev-routine-tasks",
    "testing-qa",
    "meta-tooling",
]


def slugify(text: str) -> str:
    s = re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")
    return (s[:70] or "discussion")


def extract_text(message: dict) -> str:
    content = message.get("content")
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts = []
        for block in content:
            if isinstance(block, dict) and block.get("type") == "text":
                parts.append(block.get("text") or "")
        return "\n".join(parts)
    return ""


def infer_tag(text: str) -> str:
    lower = text.lower()
    stripped = text.strip()
    if stripped.startswith("/dev-chat-history") or stripped.startswith("/standardize-docs"):
        return "meta-tooling" if "dev-chat-history" in stripped else "docs-spec"
    if "graphify" in lower or "standardize-docs" in lower:
        return "docs-spec"
    if "host" in lower or "cloudflare" in lower or "tunnel" in lower:
        return "dev-routine-tasks"
    if "architecture" in lower:
        return "arch-analysis"
    if "/user" in lower or ("history" in lower and "game" in lower):
        return "dev-feature"
    return "dev-feature"


def parse_session(path: Path) -> dict:
    lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
    queries = []
    for line in lines:
        try:
            obj = json.loads(line)
        except json.JSONDecodeError:
            continue
        role = obj.get("role")
        msg = obj.get("message") or obj
        if role != "user" and msg.get("role") != "user":
            continue
        text = extract_text(msg)
        match = USER_QUERY_RE.search(text)
        candidate = match.group(1).strip() if match else ""
        if not candidate:
            if "<dynamic_tools>" in text or "Briefly inform" in text:
                continue
            if len(text.strip()) > 40:
                candidate = text.strip()[:2000]
        if not candidate or SKIP_QUERY_RE.search(candidate):
            continue
        if queries and slugify(queries[-1].split("\n", 1)[0]) == slugify(candidate.split("\n", 1)[0]):
            queries[-1] = candidate
            continue
        if queries and len(candidate) < 100 and not candidate.startswith("/"):
            queries[-1] = queries[-1] + "\n\n" + candidate
            continue
        queries.append(candidate)
    digest = hashlib.sha256("\n".join(lines).encode()).hexdigest()
    return {"queries": queries, "line_count": len(lines), "hash": digest, "path": path}


def write_discussion(session_id: str, query: str, idx: int) -> Path:
    slug = slugify(query.split("\n", 1)[0])
    tag = infer_tag(query)
    ddir = HISTORY_ROOT / "sessions" / session_id / "discussions"
    ddir.mkdir(parents=True, exist_ok=True)
    path = ddir / f"{slug}.md"
    started = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    path.write_text(
        "\n".join(
            [
                "---",
                f"session_id: {session_id}",
                f"discussion_slug: {slug}",
                "source_agent: cursor",
                f"primary_tag: {tag}",
                "secondary_tags: []",
                f"started_at: {started}",
                f"title: {query.splitlines()[0][:80]}",
                "status: completed",
                "outcomes: []",
                "files_touched: []",
                "---",
                "",
                "## Key user requests",
                "",
                query,
                "",
                "## Agent actions",
                "",
                "See session transcript.",
                "",
                "## Outcomes",
                "",
                "Captured by incremental history builder.",
                "",
            ]
        ),
        encoding="utf-8",
    )
    tag_dir = HISTORY_ROOT / "by-tag" / tag
    tag_dir.mkdir(parents=True, exist_ok=True)
    return path


def rebuild_index(manifest: dict) -> None:
    rows = []
    for sid, meta in manifest.get("sessions", {}).items():
        for item in meta.get("discussions", []):
            rows.append((item.get("started_at", ""), item, sid))
    rows.sort(reverse=True)
    lines = [
        "# Development discussions",
        "",
        "## Discussions (chronological)",
        "",
        "| Date | Title | Tag | Session |",
        "|------|-------|-----|---------|",
    ]
    by_tag: dict[str, list[str]] = {}
    for started, item, sid in rows:
        date = (started or "")[:10]
        title = item["title"].replace("|", "/")
        slug = item["slug"]
        tag = item["tag"]
        rel = f"sessions/{sid}/discussions/{slug}.md"
        lines.append(f"| {date} | [{title}]({rel}) | `{tag}` | [{sid[:8]}](sessions/{sid}/session.md) |")
        by_tag.setdefault(tag, []).append(
            f"| {date} | {title} | [{title}](../../sessions/{sid}/discussions/{slug}.md) | [{sid[:8]}](../../sessions/{sid}/session.md) |"
        )
    lines += ["", "## Excluded sessions", "", "_None._", ""]
    HISTORY_ROOT.mkdir(parents=True, exist_ok=True)
    (HISTORY_ROOT / "index.md").write_text("\n".join(lines), encoding="utf-8")
    (HISTORY_ROOT / "README.md").write_text(
        "Development chat history. Primary index: [index.md](index.md).\n", encoding="utf-8"
    )
    tags_md = ["# Tags", ""] + [f"- `{t}`" for t in TAGS] + [""]
    (HISTORY_ROOT / "tags.md").write_text("\n".join(tags_md), encoding="utf-8")
    for tag, tag_rows in by_tag.items():
        tdir = HISTORY_ROOT / "by-tag" / tag
        tdir.mkdir(parents=True, exist_ok=True)
        body = [
            f"# Tag: {tag}",
            "",
            "| Date | Title | Discussion | Session |",
            "|------|-------|------------|---------|",
            *tag_rows,
            "",
        ]
        (tdir / "index.md").write_text("\n".join(body), encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--full", action="store_true")
    parser.add_argument("--transcripts", type=Path, default=DEFAULT_TRANSCRIPTS)
    args = parser.parse_args()
    manifest_path = HISTORY_ROOT / "manifest.json"
    manifest = {"sessions": {}}
    if manifest_path.exists() and not args.full:
        manifest = json.loads(manifest_path.read_text())
    if not args.transcripts.exists():
        print(f"No transcripts at {args.transcripts}")
        HISTORY_ROOT.mkdir(parents=True, exist_ok=True)
        rebuild_index(manifest)
        return
    for jsonl in sorted(args.transcripts.glob("*/*.jsonl")):
        if "subagents" in jsonl.parts:
            continue
        session_id = jsonl.parent.name
        parsed = parse_session(jsonl)
        prev = manifest["sessions"].get(session_id)
        if prev and prev.get("hash") == parsed["hash"] and not args.full:
            continue
        session_dir = HISTORY_ROOT / "sessions" / session_id
        session_dir.mkdir(parents=True, exist_ok=True)
        (session_dir / "session.md").write_text(
            f"# Session `{session_id}`\n\nSource: `{jsonl}`\n", encoding="utf-8"
        )
        discussions = []
        for idx, query in enumerate(parsed["queries"] or ["(no user_query)"]):
            path = write_discussion(session_id, query, idx)
            discussions.append(
                {
                    "slug": path.stem,
                    "title": query.splitlines()[0][:80],
                    "tag": infer_tag(query),
                    "started_at": datetime.now(timezone.utc).isoformat(),
                }
            )
        manifest["sessions"][session_id] = {
            "hash": parsed["hash"],
            "line_count": parsed["line_count"],
            "discussions": discussions,
        }
        print(f"processed {session_id} ({len(discussions)} discussions)", flush=True)
    rebuild_index(manifest)
    manifest_path.write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    print(f"Wrote {HISTORY_ROOT / 'index.md'}")


if __name__ == "__main__":
    main()
