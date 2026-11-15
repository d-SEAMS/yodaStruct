Lua
===

Tables carry the neighbour rows, the ring histogram, and the named
CHILL+ counts.

.. literalinclude:: ../../examples/lang_tasks.lua
   :language: lua

``meson test lua_docs_examples`` runs this file on Lua 5.4 and LuaJIT
with ``DSEAMS_ROOT`` at the repository root. On ice Ih it prints

.. code-block:: text

   pairs 512 rings 0 0 0 0 0 0 256 chill 0 128 0 0 0 0 0 0 0

the same line as the other language fronts of seams-core.
