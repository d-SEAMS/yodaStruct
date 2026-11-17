
======
dseams
======

.. raw:: html

   <p class="dseams-hero">
     <img class="dseams-hero-logo dseams-hero-logo--light"
          src="_static/logo/dseams-logo-light.png"
          alt="dseams"
          width="320"
          height="320"
          loading="eager" />
     <img class="dseams-hero-logo dseams-hero-logo--dark"
          src="_static/logo/dseams-logo-dark.png"
          alt="dseams"
          width="320"
          height="320"
          loading="eager" />
   </p>

Lua and Fennel library for the d-SEAMS C++ engine.

.. grid:: 1 2 3 3
   :gutter: 2
   :padding: 1 1 0 0
   :class-container: sd-text-center

   .. grid-item-card:: Read
      :link: quickstart
      :link-type: doc
      :class-card: sd-shadow-sm

      Load a dump with ``require("dseams")``.

   .. grid-item-card:: Classify
      :link: tutorials/lua
      :link-type: doc
      :class-card: sd-shadow-sm

      CHILL+, Steinhardt, rings and cages on Lua 5.4 and LuaJIT.

   .. grid-item-card:: Upgrade
      :link: howto/upgrade-2.14
      :link-type: doc
      :class-card: sd-shadow-sm

      Move a 2.10 script off the retired sol2 module.

About
-----

This repository is a **library**. There is no ``yodaStruct`` executable.
Call ``require("dseams")`` from Lua 5.4 or LuaJIT, or ``(require :dseams)``
from Fennel. Every call goes through the d-SEAMS C API, ``seams.h`` in
`seams-core <https://github.com/d-SEAMS/seams-core>`_.
Python is `pydseams <https://github.com/d-SEAMS/PydSEAMSlib>`_.

.. code:: lua

    local dseams = require("dseams")
    local cloud = dseams.read("input/traj/genice_sI.lammpstrj", {type = 1})
    local labels = dseams.chill_plus(cloud, {cutoff = 3.5, rule = dseams.PUBLISHED})
    print(labels.counts.clathrate)  -- 46
    cloud:close()

``dseams.core`` is the compiled C module (``dseams_core.so``).
``require("yoda")`` still resolves to ``dseams``. Version 2.14.0 replaced
the sol2 module of 2.10; see `Upgrade to 2.14 <howto/upgrade-2.14.rst>`_.

Book and video
--------------

The d-SEAMS book chapter on the Lua and Fennel front end:
`Lua and Fennel <https://docs.dseams.info/stable/lua.html>`_. The
walkthrough video is on
`Odysee <https://odysee.com/dseams-lua:9a7ffc26dff9590174a707db848f5f5d6d7a737f>`_.

.. raw:: html

   <iframe class="dseams-video"
           src="https://odysee.com/$/embed/dseams-lua:9a7ffc26dff9590174a707db848f5f5d6d7a737f"
           title="dseams Lua and Fennel walkthrough"
           width="100%" style="aspect-ratio: 16 / 9; border: 0;"
           loading="lazy" allowfullscreen></iframe>

Suite stack
-----------

How the Lua library, the compiled module, and the rest of d-SEAMS
relate:

.. mermaid::

   flowchart TB
     subgraph hosts["Hosts"]
       LUA[lua]
       FNL[Fennel]
       EMB["C / C++ embed"]
     end
     subgraph lib["this repository"]
       HELPERS["lua/dseams.lua"]
       CORE["dseams_core.so"]
     end
     subgraph engine["seams-core"]
       API["libseams (seams.h)"]
       YDS[libyodaLib]
       SEAMS[seams CLI]
     end
     subgraph py["PydSEAMSlib"]
       PY[pydseams]
     end
     LUA --> HELPERS
     FNL --> HELPERS
     EMB --> CORE
     HELPERS --> CORE
     CORE --> API
     API --> YDS
     LC[linkcell]
     LC --> YDS
     SEAMS --> YDS
     PY --> YDS

.. tip::

   ``require("dseams")`` loads the helpers. Those helpers call
   ``require("dseams_core")``. Set ``LUA_PATH`` to the Lua files and
   ``LUA_CPATH`` to the directory that holds ``dseams_core.so``.

Documentation structure
-----------------------

This documentation follows the `Diataxis <https://diataxis.fr/>`_ framework.

.. toctree::
   :maxdepth: 2
   :caption: Getting Started

   quickstart

.. toctree::
   :maxdepth: 2
   :caption: Tutorials

   tutorials/index
   tutorials/lua

.. toctree::
   :maxdepth: 2
   :caption: How-to

   howto/index
   howto/install
   howto/lua
   howto/upgrade-2.14

.. toctree::
   :maxdepth: 2
   :caption: Explanation

   explanation/index
   explanation/frontends
   explanation/citation

.. toctree::
   :maxdepth: 2
   :caption: Reference

   reference/index
   api/lua
   lang/task-lua

Related projects
----------------

`seams-core <https://github.com/d-SEAMS/seams-core>`_
    C++ engine and ``seams`` CLI

`pydseams <https://github.com/d-SEAMS/PydSEAMSlib>`_
    Python Frame API on the same engine

`linkcell <https://github.com/d-SEAMS/linkcell>`_
    periodic linked-cell k-nearest neighbours

`dseams.info <https://dseams.info>`_
    Project site

License
-------

MIT. Cite the `2020 JCIM paper <https://doi.org/10.1021/acs.jcim.0c00031>`_
and the ``CITATION.cff`` in this tree. See
`How to cite <explanation/citation.rst>`_.

#+begin\_export rst
Indices and tables
``================``

:ref:\`genindex\`
-----------------

:ref:\`search\`
---------------

#+end\_export
