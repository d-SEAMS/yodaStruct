

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

``example_lua/library/readers.lua`` checks four fixtures:

.. table::

    +---------------------+-----------------------------+--------------+
    | Test                | File                        | Reader       |
    +=====================+=============================+==============+
    | ``dseams_read_con`` | ``input/readers/cuh2.con``  | readcon-core |
    +---------------------+-----------------------------+--------------+
    | ``dseams_read_pdb`` | ``input/readers/water.pdb`` | chemfiles    |
    +---------------------+-----------------------------+--------------+
    | ``dseams_read_gro`` | ``input/readers/water.gro`` | chemfiles    |
    +---------------------+-----------------------------+--------------+
    | ``dseams_read_dcd`` | ``input/readers/water.dcd`` | chemfiles    |
    +---------------------+-----------------------------+--------------+

All four run in every build and none skips. Meson passes ``on`` when
the build has that reader and ``off`` when it does not. With ``on``,
``has_chemfiles`` or ``has_readcon`` must be true in Lua and
``has-chemfiles`` or ``has-readcon`` in ``dseams.fnl``, and the fixture is
read and checked. The DCD read also requires the box lengths 10, 10,

1. A missing file, a wrong atom count, or an empty box fails the

test. With ``off``, both queries must be false, the compiled read must
be absent, and ``read`` from Lua and from Fennel must raise the
missing-reader error. ``input/readers/water.dcd`` is a two-atom
trajectory written by chemfiles.

.. code:: bash

    meson test -C bbdir -v --suite readers --print-errorlogs

Build with both libraries when they should be present. Configuration
with the options enabled fails when seams-core did not set
``SEAMS_HAS_CHEMFILES`` or ``SEAMS_HAS_READCON``. The con, PDB, GRO, and
DCD reads then all run:

.. code:: bash

    meson setup bbdir --wrap-mode=nofallback \
      -Dwith_chemfiles=enabled -Dwith_readcon=enabled
    meson compile -C bbdir
    LUA_PATH="$PWD/lua/?.lua;;" LUA_CPATH="$PWD/bbdir/?.so;;" \
      lua -e 'local d=require("dseams"); assert(d.has_chemfiles()==true); assert(d.has_readcon()==true)'
    meson test -C bbdir -v --suite readers --print-errorlogs

The ``chemfiles and readcon`` CI job installs chemfiles 0.10.4 and
readcon-core v0.14.10, configures with both options enabled, asserts
both queries, runs the full ``meson test``, and requires a real read of
all four fixtures. It then builds with both options disabled and runs
the reader suite, which must report all four readers missing. The
other build jobs have neither library, so their reader tests take the
``off`` path.

Documentation build
~~~~~~~~~~~~~~~~~~~

.. code:: bash

    cd docs && emacs --batch --load export.el
    sphinx-build -b html docs/source docs/build

Doxygen runs from ``docs/source/conf.py`` before Sphinx reads the XML.
