# dseams (Lua and Fennel)

<p align="center">
  <img src="docs/source/_static/logo/dseams-icon.png" alt="dseams" width="96">
</p>

[![built with nix](https://builtwithnix.org/badge.svg)](https://builtwithnix.org)

Lua and Fennel library for the [d-SEAMS](https://dseams.info) engine
([`seams-core`](https://github.com/d-SEAMS/seams-core)).

`require("dseams")` works from Lua 5.4 and LuaJIT, `(require :dseams)`
from Fennel. Every call goes through the d-SEAMS C API, `seams.h`. The
LuaRocks package is `dseams`. `require("yoda")` is the same table.
The engine CLI is `seams` in `seams-core`. Python is the
[`pydseamslib`](https://github.com/d-SEAMS/PydSEAMSlib) package.

```lua
local dseams = require("dseams")
local cloud = dseams.read("input/traj/genice_sI.lammpstrj", {type = 1})
local labels = dseams.chill_plus(cloud, {cutoff = 3.5, rule = dseams.PUBLISHED})
print(labels.counts.clathrate)  -- 46
cloud:close()
```

```fennel
(local dseams (require :dseams))
(local cloud (dseams.read "input/traj/exampleTraj.lammpstrj" {:type 2}))
(print (. (dseams.ring-network cloud 8) :fraction))
```

## Build and test

meson builds seams-core from `subprojects/seams-core.wrap` and
`dseams_core.so` for every interpreter it finds. The tests compile
Fennel, so name the compiler:

```bash
fennel=$(sh scripts/fetch_fennel.sh .cache/fennel)
meson setup bbdir -Dfennel_lua="$fennel"
meson compile -C bbdir
meson test -C bbdir --print-errorlogs
```

`lua_examples` runs `examples/lua`, `examples/fennel` and `tests/lua_*.lua`
on Lua 5.4 and LuaJIT and compares each census with the C++ oracle
`tests/lua_oracle.cpp`. `lua_docs_examples` runs `docs/examples`.
`lua_busted_spec` runs `spec/` when `busted` is on `PATH`.

## LuaRocks

`dseams-2.14.0-1.rockspec` builds `src/dseams.c` against an installed
libseams (`meson install` of this tree puts one under its prefix):

```bash
luarocks make dseams-2.14.0-1.rockspec SEAMS_DIR="$prefix" SEAMS_LIBDIR="$prefix/lib"
luarocks test dseams-2.14.0-1.rockspec
```

## Nix

```bash
nix build
nix develop
```

## Development

This repository binds seams-core; it does not contain the engine. A new
analysis, a changed result or a new C API call goes to
[d-SEAMS/seams-core](https://github.com/d-SEAMS/seams-core) first, and this
tree binds it once a seams-core commit carries it.
`subprojects/seams-core.wrap` and the `seams-core` input of `flake.nix` pin
that commit. The contributing guide at the repository root has the layout,
the test rules and the commit and changelog conventions.

To build against a local seams-core checkout, put it where the wrap would:

```bash
ln -s /path/to/seams-core subprojects/seams-core
meson setup bbdir -Dfennel_lua="$fennel"
```

meson uses an existing `subprojects/seams-core` directory instead of
fetching the wrap. Remove the link to go back to the pinned commit.

Release order:

1. seams-core tags `vX.Y.Z`.
2. Here: point the wrap at `https://github.com/d-SEAMS/seams-core.git` with
   `revision = vX.Y.Z`, move the flake input to the same tag and run
   `nix flake lock --update-input seams-core`, set `X.Y.Z` in `meson.build`,
   the rockspec, `CITATION.cff`, `nix/package.nix` and `pixi.toml`, run the
   suite, and run `towncrier build --version X.Y.Z`.
3. Tag `vX.Y.Z` here; the rockspec's `source.tag` names it.
4. Upload the rock: `luarocks upload dseams-X.Y.Z-1.rockspec`.

## Upgrading from 2.10

2.14.0 retires the sol2 module, the `yodaStruct` executable and its YAML
runner. [Upgrade to 2.14](docs/orgmode/howto/upgrade-2.14.org) maps a
2.10 script onto the C API module.

## Changes

Released versions live in [CHANGELOG.md](CHANGELOG.md) (Keep a Changelog).
Unreleased notes are files under `changelog.d/`. The cut is
`towncrier build --version X.Y.Z`.

Docs: `docs/orgmode/` (ox-rst) and `docs/source/` (Shibuya). `ldoc .`
writes the LDoc reference to `docs/ldoc`.

# License

[MIT](LICENSE).
