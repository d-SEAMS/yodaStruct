rockspec_format = "3.0"
package = "dseams"
-- [[[cog
-- import dseams_version as v
-- cog.outl('version = "%s-1"' % v.VERSION)
-- ]]]
version = "2.10.0-1"
-- [[[end]]]
source = {
   url = "git+https://github.com/d-SEAMS/yodaStruct.git",
   -- [[[cog
   -- import dseams_version as v
   -- cog.outl('   tag = "v%s",' % v.VERSION)
   -- ]]]
   tag = "v2.10.0",
   -- [[[end]]]
}
description = {
   summary = "Lua and Fennel front end for the d-SEAMS structural analysis engine",
   detailed = [[
Lua and Fennel library for the d-SEAMS C++ engine. require("dseams")
is the public table. dseams.core is the compiled module.

Authors: Rohit Goswami (ORCID 0000-0002-2393-8056), Amrita Goswami
(ORCID 0000-0001-8706-2383).

Readers: LAMMPS dumps (every atom, one type, or a slice), XYZ, .con
through readcon-core when dseams.has_readcon() is true, and PDB, GRO,
and DCD through chemfiles when dseams.has_chemfiles() is true.

Analyses: cutoff and pair neighbour lists, periodic k-nearest graphs
and shell separation, hydrogen-bond networks, primitive rings, seeded
hexagonal-cage and double-diamond-cage flags, cages by ring-size
signature, prism counts, CHILL and CHILL+ labels, Steinhardt Ql,
Voronoi-weighted Ql, Voronoi facet weights, average Q6, SOAP spectra, template
RMSD, radial distribution functions, running and site-site
coordination numbers, Cartesian number-density profiles, topology
fingerprints and libraries, per-atom topology classification, ion
environments, guest occupancy, shell ring census, mutual cation-anion
contact pairs, mapped-site domains, clusters, and slice selections.
]],
   homepage = "https://dseams.info",
   license = "MIT",
   maintainer = "Rohit Goswami <rgoswami@ieee.org>",
}
dependencies = {
   "lua >= 5.3, < 5.5",
   -- dseams.fnl and yoda.fnl are loaded with fennel.dofile. 1.5.3 is
   -- the compiler vendored for the CLI. A range rather than a pin, so
   -- LuaRocks keeps an installed fennel 1.6 instead of downgrading it.
   "fennel >= 1.5.3, < 2.0",
}
build = {
   type = "command",
   -- $(LUA) is the interpreter LuaRocks selected. LuaRocks 3.8 does not
   -- define $(LUA_VERSION), so the version is read from that interpreter.
   build_command = "LV=$($(LUA) -e \"print(string.match(_VERSION, '5%.%d+'))\") && meson setup builddir --wrap-mode=nofallback -Dlua_version=\"$LV\" && meson compile -C builddir",
   install_command = "mkdir -p \"$(LUADIR)\" \"$(LIBDIR)\" && cp lua/dseams.lua lua/yoda.lua lua/dseams.fnl lua/yoda.fnl \"$(LUADIR)/\" && cp builddir/dseams_core.so \"$(LIBDIR)/\"",
}
