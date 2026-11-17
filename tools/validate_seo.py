#!/usr/bin/env python3
"""Validate SEO metadata on every generated Sphinx HTML page."""

from __future__ import annotations

import argparse
from html.parser import HTMLParser
import json
from pathlib import Path
import sys
from urllib.parse import urljoin
import xml.etree.ElementTree as ET

BASE_URL = "https://lua.dseams.info/"
DOI_URL = "https://doi.org/10.1021/acs.jcim.0c00031"


def canonical_url(root: Path, page: Path) -> str:
    relative = page.relative_to(root).as_posix()
    if relative == "index.html":
        relative = ""
    elif relative.endswith("/index.html"):
        relative = relative[: -len("index.html")]
    return urljoin(BASE_URL, relative)


class MetadataParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.title = ""
        self._in_title = False
        self.meta: list[dict[str, str]] = []
        self.links: list[dict[str, str]] = []
        self.json_ld: list[object] = []
        self._in_json_ld = False
        self._json_buffer: list[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        values = {key.lower(): value or "" for key, value in attrs}
        if tag == "title":
            self._in_title = True
        elif tag == "meta":
            self.meta.append(values)
        elif tag == "link":
            self.links.append(values)
        elif tag == "script" and values.get("type", "").lower() == "application/ld+json":
            self._in_json_ld = True
            self._json_buffer = []

    def handle_endtag(self, tag: str) -> None:
        if tag == "title":
            self._in_title = False
        elif tag == "script" and self._in_json_ld:
            self._in_json_ld = False
            try:
                self.json_ld.append(json.loads("".join(self._json_buffer)))
            except json.JSONDecodeError:
                self.json_ld.append(None)

    def handle_data(self, data: str) -> None:
        if self._in_title:
            self.title += data
        if self._in_json_ld:
            self._json_buffer.append(data)


def validate(root: Path) -> None:
    pages = sorted(root.rglob("*.html"))
    if not pages:
        raise ValueError(f"no HTML pages found under {root}")
    errors: list[str] = []

    for page in pages:
        relative = page.relative_to(root)
        parser = MetadataParser()
        parser.feed(page.read_text(encoding="utf-8"))
        expected = canonical_url(root, page)
        canonicals = [
            item.get("href", "")
            for item in parser.links
            if "canonical" in item.get("rel", "").lower().split()
        ]

        if not parser.title.strip():
            errors.append(f"{relative}: missing title")
        descriptions = [
            item.get("content", "")
            for item in parser.meta
            if item.get("name", "").lower() == "description"
        ]
        if len(descriptions) != 1 or not descriptions[0]:
            errors.append(f"{relative}: must have exactly one meta description")
        if canonicals != [expected]:
            errors.append(f"{relative}: must have exactly one canonical, {expected}")
        for prop in ("og:type", "og:title", "og:description", "og:url"):
            matching = [
                item.get("content", "")
                for item in parser.meta
                if item.get("property", "").lower() == prop
            ]
            if len(matching) != 1 or not matching[0]:
                errors.append(f"{relative}: must have exactly one {prop}")
        for name in ("twitter:card", "twitter:title", "twitter:description"):
            matching = [
                item.get("content", "")
                for item in parser.meta
                if item.get("name", "").lower() == name
            ]
            if len(matching) != 1 or not matching[0]:
                errors.append(f"{relative}: must have exactly one {name}")

        nodes = []
        for block in parser.json_ld:
            if isinstance(block, dict):
                graph = block.get("@graph", [])
                nodes.extend(graph if isinstance(graph, list) else [])
        for schema_type in ("SoftwareApplication", "SoftwareSourceCode"):
            matching = [
                node
                for node in nodes
                if isinstance(node, dict) and node.get("@type") == schema_type
            ]
            if not matching:
                errors.append(f"{relative}: missing JSON-LD {schema_type}")
            elif DOI_URL not in json.dumps(matching):
                errors.append(f"{relative}: {schema_type} does not cite {DOI_URL}")

    sitemap_path = root / "sitemap.xml"
    if not sitemap_path.exists():
        errors.append("missing sitemap.xml")
    else:
        namespace = {"sm": "http://www.sitemaps.org/schemas/sitemap/0.9"}
        urls = [
            element.text or ""
            for element in ET.parse(sitemap_path).findall(".//sm:loc", namespace)
        ]
        if not urls or any(not url.startswith(BASE_URL) for url in urls):
            errors.append("sitemap.xml has no URLs or URLs outside the canonical site")

    if errors:
        raise ValueError("\n".join(errors))
    print(f"Validated SEO metadata on {len(pages)} HTML pages.")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("site", type=Path)
    args = parser.parse_args()
    try:
        validate(args.site)
    except (ValueError, ET.ParseError) as error:
        print(error, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
