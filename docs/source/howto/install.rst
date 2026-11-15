===================
Install the library
===================


.. contents::


Problem
-------

You need ``require("dseams")`` to resolve in a ``lua`` or ``luajit``
process. That takes the Lua files (``lua/dseams.lua``, ``lua/yoda.lua``),
the compiled module ``dseams_core.so`` built for that interpreter, and
``libseams`` from seams-core.

What meson emits
----------------

The meson project is ``dseams``. seams-core is the wrap subproject in
``subprojects/seams-core.wrap``, pinned to the 2.14.0 release commit,
built as shared libraries with its CLI, Python, Fortran and engine
hooks off. ``libseams.so`` is the C API and ``libyodaLib.so`` the engine.

``src/dseams.c`` compiles twice: against Lua 5.4 into
``src/lua54/dseams_core.so`` and against LuaJIT into
``src/luajit/dseams_core.so``. Lua 5.4 is probed as ``lua5.4``,
``lua-5.4``, then ``lua`` (the conda-forge and Homebrew name); LuaJIT as
``luajit``. ``-Dwith_lua=disabled`` builds neither, ``enabled`` fails when
both are missing. ``src/gen_ffi.py`` writes ``dseams_ffi.lua``, the LuaJIT
FFI cdef of ``seams.h``.

.. table::

    +-----------------------------------------------------------------+-----------------------------------------------------------+
    | artifact                                                        | destination                                               |
    +=================================================================+===========================================================+
    | Lua 5.4 ``dseams_core.so``                                      | ``$prefix/lib/lua/5.4/``                                  |
    +-----------------------------------------------------------------+-----------------------------------------------------------+
    | LuaJIT ``dseams_core.so``                                       | ``$prefix/lib/lua/5.1/``                                  |
    +-----------------------------------------------------------------+-----------------------------------------------------------+
    | ``dseams.lua``, ``yoda.lua``, ``dseams_fnl.fnl``, ``seams.fnl`` | ``$prefix/share/lua/5.4/`` and ``$prefix/share/lua/5.1/`` |
    +-----------------------------------------------------------------+-----------------------------------------------------------+
    | ``libseams.so``, ``libyodaLib.so``                              | ``$prefix/lib/``                                          |
    +-----------------------------------------------------------------+-----------------------------------------------------------+
    | ``seams.h``, ``seams_version.h``                                | ``$prefix/include/``                                      |
    +-----------------------------------------------------------------+-----------------------------------------------------------+

meson install
-------------

.. code:: bash

    fennel=$(sh scripts/fetch_fennel.sh .cache/fennel)
    meson setup bbdir --prefix="$PWD/prefix" --libdir=lib -Dfennel_lua="$fennel"
    meson compile -C bbdir
    meson install -C bbdir
    export LUA_PATH="$PWD/prefix/share/lua/5.4/?.lua;;"
    export LUA_CPATH="$PWD/prefix/lib/lua/5.4/?.so;;"
    export LD_LIBRARY_PATH="$PWD/prefix/lib"
    lua5.4 tests/test_rock.lua .

The last line prints ``dseams rock ok``.

LuaRocks
--------

``dseams-2.14.0-1.rockspec`` builds ``dseams_core`` from ``src/dseams.c``
against an installed libseams. ``SEAMS_DIR`` sets the include and
library directories from one prefix; ``SEAMS_INCDIR`` and
``SEAMS_LIBDIR`` set them one at a time.

.. code:: bash

    luarocks make dseams-2.14.0-1.rockspec SEAMS_DIR="$PWD/prefix" SEAMS_LIBDIR="$PWD/prefix/lib"
    luarocks test dseams-2.14.0-1.rockspec
    luarocks pack dseams 2.14.0-1

The rock works with Lua 5.1 to 5.4 and LuaJIT. ``luarocks test`` runs
``tests/test_rock.lua``; it also checks ``dseams_fnl`` when the ``fennel``
rock is installed.

Nix
---

``nix build`` builds the meson layout against the seams-core flake
input. ``nix develop`` sets ``LUA_PATH`` and ``LUA_CPATH`` to the installed
Lua 5.4 files.

How require finds the module
----------------------------

.. code:: lua

    local dseams = require("dseams")  -- dseams.lua via LUA_PATH
    -- dseams.lua calls require("dseams_core"), found via LUA_CPATH

``dseams_core.so`` needs ``libseams.so`` at load time: an install
prefix on ``LD_LIBRARY_PATH``, or the build tree, whose modules carry
an rpath to the subproject.

Next steps
----------

- `Quickstart <../quickstart.rst>`_

- `Lua and Fennel <lua.rst>`_

- `Upgrade to 2.14 <upgrade-2.14.rst>`_
