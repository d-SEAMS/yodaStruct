local fennel = dofile("src/include/external/fennel/fennel.lua")
local dseams = fennel.dofile("lua/dseams.fnl")

assert(type(dseams.rdf) == "function")
assert(type(dseams["running-cn"]) == "function")
assert(type(dseams.hbonds) == "function")
assert(type(dseams.density) == "function")
assert(type(dseams.pairs) == "function")
assert(type(dseams.domain) == "function")

local lua_dseams = require("dseams")
local has_chemfiles = dseams["has-chemfiles"]()
local has_readcon = dseams["has-readcon"]()
assert(has_chemfiles == lua_dseams.has_chemfiles())
assert(has_readcon == lua_dseams.has_readcon())

local function check_reader(present, path, nop, missing)
  if present then
    assert(dseams.read(path, {frame = 1}).nop == nop)
  else
    local ok, err = pcall(dseams.read, path, {frame = 1})
    assert(not ok and tostring(err):find(missing, 1, true) ~= nil)
  end
end
check_reader(has_chemfiles, "input/readers/water.pdb", 2, "chemfiles missing")
check_reader(has_readcon, "input/readers/cuh2.con", 4, "readcon-core missing")

local cloud = dseams.read("input/traj/tiny-ions.lammpstrj", {all = true})
local profile = dseams.density(cloud, {type = 1, bins = 2, axis = "z"})
assert(#profile.centres == 2 and #profile.rho == 2)

local table = dseams["site-table"]("1=cationHead,2=anion")
assert(dseams.pairs(cloud, {table = table}).count == 2)
assert(dseams.domain(
  cloud,
  {table = table, kind = dseams.core.Kind.polar, cutoff = 1.5}
).largest == 2)

print(string.format(
  "dseams_fennel_workflows density=2 pairs=2 domain=2 has-chemfiles=%s has-readcon=%s",
  tostring(has_chemfiles), tostring(has_readcon)))
