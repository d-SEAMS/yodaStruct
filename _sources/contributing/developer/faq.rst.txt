

Developer FAQ
-------------

Why are chemfiles and readcon-core optional?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

LAMMPS dumps and XYZ are compiled into seams-core. PDB, GRO, and DCD
need chemfiles. ``.con`` needs readcon-core. Only seams-core probes for
them. A separate ``dependency()`` in this project would be cached as
not found and would skip the readcon-core wrap. When a library is
missing and the wrap is not used, that reader is left out and the
rest of the library still builds. ``dseams.has_chemfiles()`` and
``dseams.has_readcon()`` are the ``SEAMS_HAS_CHEMFILES`` and
``SEAMS_HAS_READCON`` macros from the engine that was linked.

How do I turn the readers on?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Install chemfiles and readcon-core so ``pkg-config --modversion`` sees
``chemfiles`` and ``readcon-core``, then configure with
``-Dwith_chemfiles=enabled -Dwith_readcon=enabled``. Those options do
not search for the libraries. They fail configure when seams-core
left the matching macro unset. ``auto``, the default, accepts whatever
the engine built.

Seams-core 2.14.2 uses readcon-core 0.16.2 or newer. The default wrap
mode can build the engine's pinned readcon-core. The engine requires the
patched Chemfiles 0.10.4 build for its full set of readers. Use
``-Dseams-core:use_vendored_chemfiles=enabled`` to build that copy.

Where is the version written?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Once, in the ``version:`` field of ``meson.build``. ``docs/source/conf.py``
reads that field for the Sphinx release. Every other copy is listed
in ``ci/version/files.txt`` and regenerated with cogapp. Cocogitto's
``tag_prefix`` is ``v``, so the git tag is ``vX.Y.Z``.

Who writes the changelog?
~~~~~~~~~~~~~~~~~~~~~~~~~

Towncrier. Fragments live in ``changelog.d/`` (the existing towncrier
directory). ``towncrier build --version X.Y.Z`` writes ``CHANGELOG.md``
and removes the fragments. Do not hand-edit a released section above
the towncrier marker.

Why are these pages Org?
~~~~~~~~~~~~~~~~~~~~~~~~

``docs/orgmode/`` is the source. ``docs/export.el`` publishes RST for
Sphinx. Hand-edited RST drifts from the Org. Release notes stay in
``CHANGELOG.md``, not in a second Markdown file.

What does LuaRocks publish?
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The in-repo rockspec is ``rockspec``. ``luarocks new_version`` writes
``dseams-X.Y.Z-1.rockspec`` from it, and that file builds the package
with Meson. ``luarocks upload`` sends the named rockspec to the LuaRocks
registry. The upload is the publish step.
