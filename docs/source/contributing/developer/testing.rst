

Testing
-------

Library tests
~~~~~~~~~~~~~

From a clean clone, with Lua 5.3 or 5.4, Eigen, and BLAS/LAPACK:

.. code:: bash

    meson setup bbdir --wrap-mode=nofallback
    meson compile -C bbdir
    meson test -C bbdir -v --print-errorlogs

The suite loads ``lua/dseams.lua`` and ``bbdir/dseams_core.so`` and runs
the scripts under ``example_lua/library/``. That covers a LAMMPS read,
RDF, running coordination number, coordination number, the workflow
helpers, the legacy chain, topology, and the Fennel wrappers.

Reader tests
~~~~~~~~~~~~

``example_lua/library/readers.lua`` reads three fixtures:

.. table::

    +---------------------+-----------------------------+----------------------------+
    | Test                | File                        | Query                      |
    +=====================+=============================+============================+
    | ``dseams_read_con`` | ``input/readers/cuh2.con``  | ``dseams.has_readcon()``   |
    +---------------------+-----------------------------+----------------------------+
    | ``dseams_read_pdb`` | ``input/readers/water.pdb`` | ``dseams.has_chemfiles()`` |
    +---------------------+-----------------------------+----------------------------+
    | ``dseams_read_gro`` | ``input/readers/water.gro`` | ``dseams.has_chemfiles()`` |
    +---------------------+-----------------------------+----------------------------+

Each test skips only when its query returns false, and it skips by
exiting 77, which Meson records as skipped. A missing file, a wrong
atom count, or an empty box fails the test. The queries are the
compiled ``has_chemfiles`` and ``has_readcon`` bindings.

.. code:: bash

    meson test -C bbdir -v --suite readers --print-errorlogs

Build with both libraries when they should be present. Configuration
with the options enabled fails when seams-core did not set
``SEAMS_HAS_CHEMFILES`` or ``SEAMS_HAS_READCON``, so the suite cannot
skip those three tests:

.. code:: bash

    meson setup bbdir --wrap-mode=nofallback \
      -Dwith_chemfiles=enabled -Dwith_readcon=enabled
    meson compile -C bbdir
    LUA_PATH="$PWD/lua/?.lua;;" LUA_CPATH="$PWD/bbdir/?.so;;" \
      lua -e 'local d=require("dseams"); assert(d.has_chemfiles()==true); assert(d.has_readcon()==true)'
    meson test -C bbdir -v --suite readers --print-errorlogs

The ``chemfiles and readcon`` CI job installs chemfiles 0.10.4 and
readcon-core v0.14.10, configures with both options enabled, asserts
both queries, and runs the full ``meson test``.

Documentation build
~~~~~~~~~~~~~~~~~~~

.. code:: bash

    cd docs && emacs --batch --load export.el
    sphinx-build -b html docs/source docs/build

Doxygen runs from ``docs/source/conf.py`` before Sphinx reads the XML.
