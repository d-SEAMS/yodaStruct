import os
import re
import subprocess

_conf_dir = os.path.dirname(os.path.abspath(__file__))
subprocess.check_call(["doxygen", "Doxyfile"], cwd=_conf_dir)

project = "dseams"
# the release string is the meson project version, so the book cannot drift
# from the build
with open(os.path.join(_conf_dir, "..", "..", "meson.build"), encoding="utf-8") as _fh:
    release = re.search(r"version:\s*'([^']+)'", _fh.read()).group(1)
copyright = "2019--present, d-SEAMS core team"
author = (
    "d-SEAMS core team: "
    "Rohit Goswami (https://orcid.org/0000-0002-2393-8056), "
    "Amrita Goswami (https://orcid.org/0000-0001-8706-2383), "
    "Ruhila Goswami (https://orcid.org/0000-0002-5443-9356)"
)

extensions = [
    "breathe",
    "sphinx.ext.intersphinx",
    "sphinx_sitemap",
    "sphinx_design",
    "sphinxcontrib.mermaid",
]

breathe_projects = {"dseams": "xml"}
breathe_default_project = "dseams"

templates_path = ["_templates"]
exclude_patterns = []
source_suffix = [".rst"]
master_doc = "index"

html_theme = "shibuya"
html_static_path = ["_static"]
html_favicon = "_static/dseams/favicon.ico"
html_css_files = [
    "dseams/dseams-tokens.css",
    "dseams/dseams-family.css",
    "dseams/dseams-shibuya.css",
]
html_js_files = []
html_title = "dseams Lua API | Molecular Simulation Structure Analysis"
html_baseurl = "https://lua.dseams.info/"
sitemap_url_scheme = "{link}"

html_context = {
    "source_type": "github",
    "source_user": "d-SEAMS",
    "source_repo": "yodaStruct",
    "source_version": "main",
    "source_docs_path": "/docs/source/",
}

# Mermaid: vendored library; diagrams authorable via ``.. mermaid::`` (from Org RST export).
mermaid_version = "11.4.0"
mermaid_use_local = "dseams/mermaid.mjs"
mermaid_init_config = {
    "startOnLoad": False,
    "themeVariables": {"fontFamily": "ui-sans-serif, system-ui, sans-serif"},
}

html_theme_options = {
    "github_url": "https://github.com/d-SEAMS/yodaStruct",
    "accent_color": "blue",
    "dark_code": True,
    "show_ai_links": False,
    "globaltoc_expand_depth": 1,
    "toctree_collapse": True,
    "toctree_maxdepth": 3,
    "toctree_titles_only": True,
}

html_sidebars = {
    "**": [
        "sidebars/localtoc.html",
        "sidebars/edit-this-page.html",
    ],
}

intersphinx_mapping = {
    "python": ("https://docs.python.org/3", None),
    "dseams": ("https://docs.dseams.info", None),
    "pydseams": ("https://d-seams.github.io/PydSEAMSlib/", None),
}


def _org_file_links_to_html(app, doctree, docname):
    """Point the ``page.rst`` links that ox-rst writes for Org file links at
    the built ``page.html``; Sphinx treats them as external URIs."""
    from docutils import nodes

    for ref in doctree.findall(nodes.reference):
        uri = ref.get("refuri", "")
        if uri.endswith(".rst") and "://" not in uri and not uri.startswith("/"):
            ref["refuri"] = uri[: -len(".rst")] + ".html"


def setup(app):
    app.connect("doctree-resolved", _org_file_links_to_html)
