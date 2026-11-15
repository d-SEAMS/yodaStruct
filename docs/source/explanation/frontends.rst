==============
Three products
==============


Three products share one engine. Fennel, ``require("yoda")``, and
``dseams_core`` are spellings of the Lua library, not extra products.

.. table::

    +----------------------+-----------------------+---------------------------------------------------------+
    | want                 | call                  | lives in                                                |
    +======================+=======================+=========================================================+
    | Lua / Fennel library | ``require("dseams")`` | this repository                                         |
    +----------------------+-----------------------+---------------------------------------------------------+
    | Python library       | ``import pydseams``   | `PydSEAMSlib <https://github.com/d-SEAMS/PydSEAMSlib>`_ |
    +----------------------+-----------------------+---------------------------------------------------------+
    | Engine CLI           | ``seams``             | `seams-core <https://github.com/d-SEAMS/seams-core>`_   |
    +----------------------+-----------------------+---------------------------------------------------------+

Aliases of the Lua product: ``(require :dseams)``, ``seams.fnl``,
``dseams_fnl.fnl``, ``require("yoda")``. ``require("dseams_core")`` is the
compiled C module, not a product.

Every front calls the same C API, ``seams.h`` in seams-core. Helpers
stay in the scripting language (``lua/dseams.lua`` here, Python helpers
in pydseams).

The YAML driver of 2020 (``yodaStruct -c conf.yml`` with the
``readFrameOnlyOne``, ``trajectory`` and ``functionScript`` globals) is gone
in 2.14.0. ``seams`` is flags and twelve-factor knobs, not
``conf.yaml``.
