# Contributing to yodaStruct

This file is the working contract for anyone changing this repository. The
README is for users of `require("dseams")`; this file is for people editing it.

## What lives here and what does not

This repository holds the Lua and Fennel library on top of the d-SEAMS C API:
the C module `dseams_core` (`src/dseams.c`), the Lua table `dseams`
(`lua/dseams.lua`), the Fennel modules, the LuaRocks rockspec, and their tests.
The engine, the C API (`libseams`, header `include/seams.h`) and the C++ code
the oracle test calls live in
[d-SEAMS/seams-core](https://github.com/d-SEAMS/seams-core).

- A new analysis, a changed result, a C API function or enumerator, a reader
  for a new file format, or a bug inside libseams: change seams-core first.
  Bind it here once a seams-core commit carries it, and move the pin.
- A Lua or Fennel wrapper, an option table, an error message on the Lua side,
  the build, the rockspec, docs or examples: change it here.
- Do not copy engine sources into this tree. meson fetches seams-core through
  the wrap; `subprojects/seams-core/` is ignored by git.

## Layout

| Path | Contents |
|---|---|
| `meson.build`, `meson.options` | Top-level build; pulls seams-core as a subproject |
| `subprojects/seams-core.wrap` | The seams-core commit this tree builds against |
| `src/dseams.c` | The C module `dseams_core`, one call per `seams.h` function |
| `src/gen_ffi.py` | Writes `dseams_ffi.lua`, the LuaJIT FFI cdef of `seams.h` |
| `src/lua54/`, `src/luajit/` | One `dseams_core.so` per interpreter |
| `lua/` | `dseams.lua`, `yoda.lua`, `seams.fnl`, `dseams_fnl.fnl` |
| `dseams-2.14.0-1.rockspec` | The LuaRocks package; `tests/test_rock.lua` is its test |
| `tests/` | `lua_examples.py` and `lua_oracle.cpp` (Lua against the C++ path), `lua_*.lua`, `lua_docs_examples.py` |
| `spec/` | busted specs |
| `examples/lua/`, `examples/fennel/` | Scripts the tests run; `docs/orgmode/howto/lua.org` names each one |
| `docs/examples/` | Scripts the docs include; `lua_docs_examples` checks their output |
| `docs/orgmode/` | Org sources; `docs/export.el` writes the RST under `docs/source/` |
| `docs/source/` | Sphinx book; `api/` and `tutorials/` are MyST pages |
| `input/` | Trajectory frames the tests and examples read |
| `nix/`, `flake.nix` | Nix package; the flake input is the same seams-core commit |
| `pixi.toml` | Development environment |
| `changelog.d/` | Unreleased changelog fragments |

## Build and test

Builds and tests run from the repository root. The tests compile Fennel, so a
test build names the compiler:

```bash
fennel=$(sh scripts/fetch_fennel.sh .cache/fennel)
meson setup bbdir -Dwith_lua=enabled -Dfennel_lua="$fennel"
meson compile -C bbdir
meson test -C bbdir --print-errorlogs
```

`pixi run test` does the same inside the pixi environment. `lua_examples` runs
every example and `tests/lua_*.lua` on Lua 5.4 and LuaJIT and compares each
number with `tests/lua_oracle.cpp`. `lua_docs_examples` checks the docs
scripts. `lua_busted_spec` runs when `busted` is on `PATH` at configure time.
The seams-core tests registered by the subproject run in the same suite and
must pass too.

The rock, against an installed libseams (`meson install` of this tree):

```bash
luarocks make dseams-2.14.0-1.rockspec SEAMS_DIR="$prefix" SEAMS_LIBDIR="$prefix/lib"
luarocks test dseams-2.14.0-1.rockspec
```

Docs: `ldoc --fatalwarnings .` and `sphinx-build -b html docs/source docs/build`.
Edit the org file under `docs/orgmode/`, then regenerate its RST with
`emacs --batch --load export.el` from `docs/`.

## Tests

A change to a wrapper comes with a check of its output against the C++ path,
in `tests/lua_fixtures.lua` and `tests/lua_oracle.cpp`, or an asserted value in
an example. Do not weaken an assertion, widen a tolerance, or drop an
interpreter from a test to make it pass; fix the code under test.

## The seams-core pin

`subprojects/seams-core.wrap` and the `seams-core` input of `flake.nix` name
the same commit. Move both together, run `nix flake lock --update-input
seams-core`, run the full suite, and add a `changed` fragment that names the
new commit. A release pins a seams-core tag, not a branch.

## Commits and changelog

Commits follow [Conventional Commits](https://www.conventionalcommits.org/):
`feat:`, `fix:`, `docs:`, `test:`, `build:`, `ci:`, `refactor:`, `chore:`, with
`!` for a breaking change. One logical change per commit.

Every user-visible change adds a fragment to `changelog.d/` in the same commit,
named `+slug.<type>.md` or `<issue>.<type>.md`, where type is `added`,
`changed`, `deprecated`, `removed`, `fixed` or `security`. A release runs
`towncrier build --version X.Y.Z`, which writes `CHANGELOG.md`.

## Versions

`meson.build`, the rockspec file name and its `version`, `CITATION.cff`,
`nix/package.nix` and `pixi.toml` carry the same version, and it matches the
seams-core release this tree binds. The `versions` CI job checks them.
