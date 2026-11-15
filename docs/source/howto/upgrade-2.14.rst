===============
Upgrade to 2.14
===============



Problem
-------

A script written for yodaStruct 2.10 loaded the sol2 module, which
seams-core 2.14 no longer builds. 2.14.0 replaces it with
``require("dseams")`` over the C API, ``seams.h``, the module seams-core
shipped as ``bindings/lua``. The name ``dseams`` and the alias ``yoda`` stay.

What went away
--------------

- The sol2 module (``src/lua_api.cpp``, ``src/luaopen.cpp``) and its
  vendored sol, cxxopts, rang and Fennel headers.

- The ``yodaStruct`` executable and its YAML script runner
  (``yodaStruct -c conf.yml``, ``lua_inputs/``, ``example_lua/``).

- The sol2 registrations on ``dseams.core``. ``dseams.core`` is now the
  C module and holds the handle constructors. The camelCase names a
  2.10 script called there (``readLammpsTrjO``, ``getIceTypePlus``,
  ``findBySignature``, ``steinhardtQl`` and the rest) are aliases on
  ``dseams`` itself.

- ``dseams.classify_topology``, ``dseams.topology_library``,
  ``dseams.guest_occupancy``, ``dseams.ion_environment``,
  ``dseams.shell_ring_census`` and ``dseams.neighbors_pair``. ``seams.h`` has
  no call for them; the ``seams`` CLI in seams-core keeps those analyses.

- ``lua/dseams.fnl`` and ``lua/yoda.fnl``. Fennel uses ``(require :dseams)``,
  ``seams.fnl`` or ``dseams_fnl.fnl``.

- ``share/luadseams/``. An install puts the Lua files under
  ``share/lua/5.4`` and ``share/lua/5.1``, and ``dseams_core.so`` under
  ``lib/lua/5.4`` and ``lib/lua/5.1``.

What a script changes
---------------------

.. table::

    +---------------------------------------------------------------------------------------+--------------------------------------------------------------------------------------------------------+
    | 2.10                                                                                  | 2.14                                                                                                   |
    +=======================================================================================+========================================================================================================+
    | ``dseams.read(path)`` tried LAMMPS type 2                                             | ``dseams.read(path)`` guesses the oxygen species; pass ``{type = n}`` or ``{all = true}`` to say which |
    +---------------------------------------------------------------------------------------+--------------------------------------------------------------------------------------------------------+
    | ``.con`` and chemfiles formats went through ``core.readCon`` / ``core.readChemfiles`` | ``dseams.read`` hands every format to ``seams_system_read``                                            |
    +---------------------------------------------------------------------------------------+--------------------------------------------------------------------------------------------------------+
    | ``dseams.chill_plus(cloud, {cutoff = 3.5})``                                          | the same call; ``rule = dseams.PUBLISHED`` names the published CHILL+ rule, ``"ovito"`` the OVITO one  |
    +---------------------------------------------------------------------------------------+--------------------------------------------------------------------------------------------------------+
    | results were the engine's return values                                               | ``labels[i]`` names atom ``i``, ``labels.codes`` holds the codes, ``labels.counts.<name>`` the census  |
    +---------------------------------------------------------------------------------------+--------------------------------------------------------------------------------------------------------+
    | handles freed by the collector                                                        | also ``cloud:close()``, or a Lua 5.4 ``<close>`` variable                                              |
    +---------------------------------------------------------------------------------------+--------------------------------------------------------------------------------------------------------+

Calls that kept their name: ``read``, ``chill``, ``chill_plus``, ``cages``,
``cages_by_signature``, ``cn``, ``running_cn``, ``rdf``, ``density``, ``domain``,
``fingerprint``, ``hbonds``, ``knn``, ``neighbors``, ``pairs``, ``site_table``.
Their option tables are in `Reference <../reference/index.rst>`_.

Build
-----

The engine is no longer linked static. ``dseams_core.so`` loads
``libseams.so``, so an installed module needs that library on the
loader path. LuaJIT is built beside Lua 5.4 when meson finds it. Lua
5.3 is no longer a target. The Lua tests need the Fennel compiler;
see `Install the library <install.rst>`_.
