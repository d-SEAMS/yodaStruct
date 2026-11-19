

Release Process
---------------

One release version, the ``version`` keyword of ``project()`` in
``meson.build``. ``meson rewrite`` writes that keyword during ``cog bump``.
``ci/version/dseams_version.py`` reads it with
``meson introspect --projectinfo meson.build``, and cogapp copies it
into the files listed in ``ci/version/files.txt``: ``nix/package.nix``,
``CITATION.cff``, ``towncrier.toml``, ``rockspec``, and
``docs/source/Doxyfile``. That cogapp run also writes
``date-released`` in ``CITATION.cff`` from ``date +%F``, the ship date.
``docs/source/conf.py`` reads the same ``project()`` line for Sphinx, so
the book follows the build. Regenerate the copies with cogapp (the
Python package). That ``cog`` script is not cocogitto. Cocogitto's
command is ``cog`` and its config is ``cog.toml``, with
``tag_prefix = "v"``.

.. code:: bash

    python3 -m cogapp -I ci/version -r @ci/version/files.txt

The in-repo rockspec is ``rockspec``. LuaRocks loads that basename
without a version in the filename, and cogapp rewrites its ``version``
and ``tag`` fields. ``luarocks new_version`` writes the upload file
``dseams-X.Y.Z-1.rockspec`` from it. Run that command from the
repository root.

Git tags are ``vX.Y.Z``. Towncrier owns ``CHANGELOG.md``. Fragments under
``changelog.d/`` are the only input for the next notes block. Leave a
released ``## [X.Y.Z]`` section above the towncrier marker as towncrier
wrote it, and keep release notes in ``CHANGELOG.md``.

**Canonical changelog**: repository-root ``CHANGELOG.md``.

Tooling:

.. table::

    +----------------------------------------------------+------------------------------------------------------------------------------------------------+
    | Tool                                               | Role                                                                                           |
    +====================================================+================================================================================================+
    | `cocogitto <https://docs.cocogitto.io>`_ (``cog``) | Conventional-commit bump, version commit, tag ``vX.Y.Z``                                       |
    +----------------------------------------------------+------------------------------------------------------------------------------------------------+
    | `towncrier <https://towncrier.readthedocs.io>`_    | ``CHANGELOG.md`` from ``changelog.d/``                                                         |
    +----------------------------------------------------+------------------------------------------------------------------------------------------------+
    | cogapp (``python3 -m cogapp``)                     | Copy ``project()`` version into ``ci/version/files.txt``                                       |
    +----------------------------------------------------+------------------------------------------------------------------------------------------------+
    | Meson                                              | ``meson rewrite`` writes the ``project()`` version; Meson also configures, compiles, and tests |
    +----------------------------------------------------+------------------------------------------------------------------------------------------------+
    | LuaRocks                                           | Name, pack, and upload the rockspec                                                            |
    +----------------------------------------------------+------------------------------------------------------------------------------------------------+

Changelog fragments
~~~~~~~~~~~~~~~~~~~

Add a fragment under ``changelog.d/`` for each user-visible change.
The orphan prefix is ``+`` when there is no issue number.

.. code:: bash

    printf '%s\n' 'Short user-facing note.' > changelog.d/+short-name.added.md
    towncrier build --draft --version unreleased

``--version unreleased`` labels that preview heading ``[unreleased]``.

Types in ``towncrier.toml``: ``added``, ``changed``, ``deprecated``, ``removed``,
``fixed``, ``security``.

Commit check
~~~~~~~~~~~~

Cocogitto checks a revision range. Merge commits are ignored
(``ignore_merge_commits`` in ``cog.toml``).

.. code:: bash

    cog check v2.10.0..HEAD

From a clean clone to a published rock
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

1. Clone and build.

   .. code:: bash

       git clone https://github.com/d-SEAMS/yodaStruct.git
       cd yodaStruct
       meson setup bbdir --wrap-mode=nofallback
       meson compile -C bbdir
       meson test -C bbdir -v --print-errorlogs

2. Preview the notes and the bump on a clean worktree.
   ``cog bump --dry-run --auto`` prints the version and stops before the hooks.

   .. code:: bash

       towncrier build --draft --version unreleased
       cog bump --dry-run --auto
       cog check v2.10.0..HEAD

3. Cut the release. ``cog bump --auto`` runs the ``pre_bump_hooks`` in
   ``cog.toml``, in order:

   - ``meson rewrite kwargs set project / version {{version}}``

   - ``python3 -m cogapp -I ci/version -r @ci/version/files.txt``

   - ``towncrier build --yes --version {{version}}``

   Meson writes ``{{version}}`` into the ``version`` keyword of
   ``project()``. cogapp reads that keyword and writes it into
   ``rockspec``, ``docs/source/Doxyfile``, and the other files in
   ``ci/version/files.txt``. The same run sets ``date-released`` in
   ``CITATION.cff`` from ``date +%F``. Towncrier writes the changelog
   section. Cocogitto commits that tree and puts the tag ``vX.Y.Z`` on
   that commit.

   .. code:: bash

       cog bump --auto

4. Name the upload rockspec from the repository root. ``X.Y.Z`` is the
   version the tag carries, without the ``v``.

   .. code:: bash

       luarocks new_version rockspec X.Y.Z --tag vX.Y.Z
       luarocks lint dseams-X.Y.Z-1.rockspec

   ``luarocks new_version`` writes ``dseams-X.Y.Z-1.rockspec`` beside the
   in-repo ``rockspec``. Its ``source.url`` stays
   ``git+https://github.com/d-SEAMS/yodaStruct.git`` and its ``source.tag``
   is ``vX.Y.Z``. ``luarocks pack`` clones that tag, so run it once the tag
   is on the public remote:

   .. code:: bash

       luarocks pack dseams-X.Y.Z-1.rockspec

   To pack the tag while it exists only in this clone, pass the clone
   as the rock URL. ``luarocks new_version`` warns that a ``git+file://``
   URL has no checksum, writes the rockspec, and ``luarocks pack`` clones
   that URL at the tag:

   .. code:: bash

       luarocks new_version rockspec X.Y.Z --tag vX.Y.Z "git+file://$(pwd)"
       luarocks lint dseams-X.Y.Z-1.rockspec
       luarocks pack dseams-X.Y.Z-1.rockspec

5. Publish. Run these commands when the release is ready to leave
   this clone.

   .. code:: bash

       git push origin HEAD --follow-tags
       luarocks new_version rockspec X.Y.Z --tag vX.Y.Z
       luarocks upload dseams-X.Y.Z-1.rockspec

   ``luarocks upload`` needs an API key from luarocks.org. It is the
   registry publish for this binding. Push the tag before the upload
   so the public rockspec's tag is the commit GitHub has.

After the tag
~~~~~~~~~~~~~

Confirm ``vX.Y.Z`` points at the version commit
(``git rev-parse vX.Y.Z^{commit}`` matches ``git rev-parse HEAD`` on that
commit), that ``CHANGELOG.md`` has that section, and that the LuaRocks
page for ``dseams`` shows the upload.
