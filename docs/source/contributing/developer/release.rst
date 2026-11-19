

Release Process
---------------

One release version, written in the ``version:`` field of ``meson.build``.
``docs/source/conf.py`` reads it for Sphinx, so the book is not a second
copy. Every other copy sits between cogapp markers in a file listed
in ``ci/version/files.txt``: ``nix/package.nix``, ``CITATION.cff``,
``towncrier.toml``, and ``dseams-2.10.0-1.rockspec``.
Regenerate them with cogapp (the Python package), the same command
rgpot runs from ``ci/version/files.txt``. That ``cog`` script is not
cocogitto. Cocogitto's command is ``cog`` and its config is
``cog.toml``, with ``tag_prefix = "v"``.

.. code:: bash

    python3 -m cogapp -I ci/version -r @ci/version/files.txt

Git tags are ``vX.Y.Z``. Towncrier owns ``CHANGELOG.md``. Fragments under
``changelog.d/`` are the only input for the next notes block. Do not
hand-edit a ``## [X.Y.Z]`` section above the towncrier marker, and do
not add a Markdown release manual.

**Canonical changelog**: repository-root ``CHANGELOG.md``.

Tooling:

.. table::

    +----------------------------------------------------+--------------------------------------------------------------------+
    | Tool                                               | Role                                                               |
    +====================================================+====================================================================+
    | `cocogitto <https://docs.cocogitto.io>`_ (``cog``) | Conventional-commit bump, version commit, annotated tag ``vX.Y.Z`` |
    +----------------------------------------------------+--------------------------------------------------------------------+
    | `towncrier <https://towncrier.readthedocs.io>`_    | ``CHANGELOG.md`` from ``changelog.d/``                             |
    +----------------------------------------------------+--------------------------------------------------------------------+
    | cogapp (``python3 -m cogapp``)                     | Rewrite the copies in ``ci/version/files.txt``                     |
    +----------------------------------------------------+--------------------------------------------------------------------+
    | Meson                                              | Configure, compile, and test the library                           |
    +----------------------------------------------------+--------------------------------------------------------------------+
    | LuaRocks                                           | Pack and upload the rockspec to the LuaRocks registry              |
    +----------------------------------------------------+--------------------------------------------------------------------+

Changelog fragments
~~~~~~~~~~~~~~~~~~~

Add a fragment under ``changelog.d/`` for each user-visible change.
The orphan prefix is ``+`` when there is no issue number.

.. code:: bash

    printf '%s\n' 'Short user-facing note.' > changelog.d/+short-name.added.md
    towncrier build --draft

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

2. Preview the notes and the bump. Neither command publishes.

   .. code:: bash

       towncrier build --draft
       cog bump --dry-run
       cog check v2.10.0..HEAD

3. Refresh the version copies and pack a source rock. Packing does
   not upload.

   .. code:: bash

       python3 -m cogapp -I ci/version -r @ci/version/files.txt
       luarocks pack dseams-2.10.0-1.rockspec

   ``luarocks pack`` on that rockspec fetches ``source.tag``. That tag is
   the published release, not unpushed commits. To pack the checkout
   you have, copy the rockspec, set ``source.url`` to ``git+file://`` plus
   the absolute path of this clone and ``source.branch`` to ``HEAD``'s
   branch, and ``luarocks pack`` that copy.

4. Cut the release locally. Write the new version into the
   ``version:`` field of ``meson.build`` first. ``cog bump`` then runs the
   ``pre_bump_hooks`` in ``cog.toml``:

   - ``python3 -m cogapp -I ci/version -r @ci/version/files.txt``

   - ``towncrier build --yes --version {{version}}``

   Then it commits and tags ``vX.Y.Z``.

   .. code:: bash

       cog bump --version X.Y.Z

   Rename ``dseams-2.10.0-1.rockspec`` to ``dseams-X.Y.Z-1.rockspec`` when
   the version changed, put that path in ``ci/version/files.txt``, and
   amend the version commit so the rockspec name matches the
   ``version`` field.

5. Publish. These two commands are the publishing steps. Do not run
   them as a dry-run.

   .. code:: bash

       git push origin HEAD --follow-tags
       luarocks upload dseams-X.Y.Z-1.rockspec

   ``luarocks upload`` needs an API key from luarocks.org. It is the
   registry publish for this binding. A tag alone does not upload
   the rock.

After the tag
~~~~~~~~~~~~~

Confirm the tag ``vX.Y.Z`` points at the version commit, that
``CHANGELOG.md`` has that section, and that the LuaRocks page for
``dseams`` shows the upload.
