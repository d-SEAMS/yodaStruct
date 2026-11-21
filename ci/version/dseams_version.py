"""Release version for cog snippets, read from meson.build.

The ``version`` keyword of ``project()`` in meson.build is the only place
the release version is written. ``meson rewrite`` sets it during
``cog bump``. Every copy listed in ci/version/files.txt is regenerated
from it:

    python3 -m cogapp -I ci/version -r @ci/version/files.txt

Call cogapp through `python -m cogapp`, because cocogitto also installs
a `cog` executable.
"""

import json
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

_info = json.loads(
    subprocess.check_output(
        ["meson", "introspect", "--projectinfo", "meson.build"],
        cwd=ROOT,
        text=True,
    )
)
VERSION = _info["version"]
