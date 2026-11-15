==========
Quickstart
==========


Call ``require("dseams")`` from Lua 5.4 or LuaJIT, or ``(require :dseams)``
from Fennel. This tree builds no ``yodaStruct`` executable. Call ``seams``
for the engine CLI, in
`seams-core <https://github.com/d-SEAMS/seams-core>`_.

``require("yoda")`` still resolves to ``dseams``.

Prerequisites
-------------

- Lua 5.4 (headers and interpreter), LuaJIT 2.1, or both

- meson >= 1.3, ninja, C and C++20 compilers, pkg-config, Eigen

- Python 3 for the FFI generator and the test drivers

- Work from the repository root so the shipped dump paths resolve

Meson
-----

meson fetches seams-core through ``subprojects/seams-core.wrap`` and
builds ``dseams_core.so`` for each interpreter it finds. The tests
compile Fennel, so name the compiler:

.. code:: bash

    fennel=$(sh scripts/fetch_fennel.sh .cache/fennel)
    meson setup bbdir -Dfennel_lua="$fennel"
    meson compile -C bbdir
    meson test -C bbdir

Run one example against the build tree:

.. code:: bash

    LUA_PATH="$PWD/lua/?.lua;;" LUA_CPATH="$PWD/bbdir/src/lua54/?.so;;" \
      lua5.4 examples/lua/chill_plus.lua .

You should see:

::

    cubic 0 hexagonal 0 water 0 interfacial 0 clathrate 46 interClathrate 0 unclassified 0 reCubic 0 reHex 0

LuaJIT loads ``bbdir/src/luajit/dseams_core.so`` instead. A Lua 5.4
process that loads the LuaJIT module crashes, so point ``LUA_CPATH``
at the directory that matches the interpreter.

LuaRocks
--------

The rock builds ``dseams_core`` against an installed libseams. From
the repository root, with ``$prefix`` holding ``lib/libseams.so`` and
``include/seams.h``:

.. code:: bash

    luarocks make dseams-2.14.0-1.rockspec SEAMS_DIR="$prefix" SEAMS_LIBDIR="$prefix/lib"
    luarocks test dseams-2.14.0-1.rockspec

``meson install`` of this tree puts libseams under its prefix.

Fennel
------

Fennel loads the same module:

.. code:: fennel

    (local dseams (require :dseams))
    (local cloud (dseams.read "input/traj/exampleTraj.lammpstrj" {:type 2}))
    (local rings (dseams.ring-network cloud 8))

``seams.fnl`` is the Fennel module with keyword options. The how-to is
`Lua and Fennel <howto/lua.rst>`_.

Next steps
----------

`Lua and Fennel tutorial <tutorials/lua.rst>`_
    every call on the shipped frames

`Install the library <howto/install.rst>`_
    where an install puts each file

`Upgrade to 2.14 <howto/upgrade-2.14.rst>`_
    scripts written for the sol2 module
