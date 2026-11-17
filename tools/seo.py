#!/usr/bin/env python3
"""Add SEO metadata to every generated Sphinx HTML page."""

from __future__ import annotations

import html
import json
from pathlib import Path
import re
import sys

from validate_seo import DOI_URL, canonical_url

SITE_TITLE = "dseams Lua API | Molecular Simulation Structure Analysis"
SITE_DESCRIPTION = (
    "Lua and Fennel library for water, ice, cage, ring, and bond-order "
    "analysis with the d-SEAMS molecular simulation engine."
)
REPOSITORY = "https://github.com/d-SEAMS/yodaStruct"


def attributes(tag: str) -> dict[str, str]:
    return {
        name.lower(): html.unescape(value)
        for name, _, value in re.findall(
            r"""([:\w-]+)\s*=\s*(["'])(.*?)\2""", tag, flags=re.DOTALL
        )
    }


def strip_existing_metadata(document: str) -> str:
    def keep_meta(match: re.Match[str]) -> str:
        attrs = attributes(match.group(0))
        name = attrs.get("name", "").lower()
        prop = attrs.get("property", "").lower()
        if name in {
            "description",
            "twitter:card",
            "twitter:title",
            "twitter:description",
        }:
            return ""
        if prop.startswith("og:"):
            return ""
        return match.group(0)

    def keep_link(match: re.Match[str]) -> str:
        rel = attributes(match.group(0)).get("rel", "").lower().split()
        return "" if "canonical" in rel else match.group(0)

    document = re.sub(r"<meta\b[^>]*>", keep_meta, document, flags=re.IGNORECASE)
    return re.sub(r"<link\b[^>]*>", keep_link, document, flags=re.IGNORECASE)


def document_title(document: str, page: Path, root: Path) -> str:
    match = re.search(r"<title\b[^>]*>(.*?)</title>", document, re.IGNORECASE | re.DOTALL)
    if not match:
        raise ValueError(f"{page.relative_to(root)} has no title element")
    return re.sub(r"<[^>]+>", "", html.unescape(match.group(1))).strip()


def structured_data(canonical: str, title: str, description: str) -> dict[str, object]:
    citation = {"@type": "ScholarlyArticle", "@id": DOI_URL}
    common = {
        "name": title,
        "description": description,
        "url": canonical,
        "codeRepository": REPOSITORY,
        "license": "https://spdx.org/licenses/MIT.html",
        "citation": citation,
    }
    return {
        "@context": "https://schema.org",
        "@graph": [
            {
                "@type": "SoftwareApplication",
                **common,
                "applicationCategory": "ScientificApplication",
                "operatingSystem": "Linux, macOS",
            },
            {
                "@type": "SoftwareSourceCode",
                **common,
                "programmingLanguage": ["Lua", "Fennel", "C++"],
                "runtimePlatform": "Lua",
            },
        ],
    }


def enhance(root: Path) -> None:
    pages = sorted(root.rglob("*.html"))
    if not pages:
        raise ValueError(f"no HTML pages found under {root}")

    for page in pages:
        document = page.read_text(encoding="utf-8")
        title = document_title(document, page, root)
        canonical = canonical_url(root, page)
        page_name = title.removesuffix(f" - {SITE_TITLE}")
        description = (
            SITE_DESCRIPTION
            if page == root / "index.html"
            else f"{page_name}. {SITE_DESCRIPTION}"
        )
        document = strip_existing_metadata(document)
        escaped_title = html.escape(title, quote=True)
        escaped_description = html.escape(description, quote=True)
        escaped_url = html.escape(canonical, quote=True)
        metadata = f"""
<meta name="description" content="{escaped_description}">
<link rel="canonical" href="{escaped_url}">
<meta property="og:type" content="website">
<meta property="og:site_name" content="{html.escape(SITE_TITLE, quote=True)}">
<meta property="og:title" content="{escaped_title}">
<meta property="og:description" content="{escaped_description}">
<meta property="og:url" content="{escaped_url}">
<meta name="twitter:card" content="summary">
<meta name="twitter:title" content="{escaped_title}">
<meta name="twitter:description" content="{escaped_description}">
<script type="application/ld+json">{json.dumps(structured_data(canonical, title, description), separators=(",", ":"))}</script>
"""
        document, count = re.subn(
            r"(</title>)",
            lambda match: f"{match.group(1)}{metadata}",
            document,
            count=1,
            flags=re.IGNORECASE,
        )
        if count != 1:
            raise ValueError(f"could not add metadata to {page.relative_to(root)}")
        page.write_text(document, encoding="utf-8")


def main() -> int:
    if len(sys.argv) != 2:
        print(f"usage: {Path(sys.argv[0]).name} SITE", file=sys.stderr)
        return 2
    try:
        enhance(Path(sys.argv[1]))
    except ValueError as error:
        print(error, file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
