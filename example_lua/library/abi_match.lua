-- lua abi_match.lua <linked ABI, e.g. 5.4>
-- dseams_core must be loaded by the Lua version it links. Loading it
-- into another version crashes inside liblua before any error can be
-- raised, so the interpreter version is checked before require.
local linked = assert(arg[1], "usage: abi_match.lua <linked Lua ABI>")
local running = string.match(_VERSION, "5%.%d+")
if running ~= linked then
  error(string.format(
    "interpreter %s is Lua %s but dseams_core links Lua %s",
    arg[-1] or "?", tostring(running), linked), 0)
end
local core = require("dseams_core")
assert(type(core.readXYZ) == "function", "dseams_core has no readXYZ")
-- Where the loader exposes the mapped libraries, every shared liblua in
-- the process must be the interpreter's version.
local maps = io.open("/proc/self/maps", "r")
local mapped = {}
if maps then
  for line in maps:lines() do
    local lib = string.match(line, "(liblua[^/]*%.so[^/]*)$")
    if lib and not mapped[lib] then
      mapped[lib] = true
      local major, minor = string.match(lib, "^liblua%-?(5)%.?(%d)")
      if not major then
        major, minor = string.match(lib, "%.so%.(5)%.(%d)")
      end
      if major then
        local v = major .. "." .. minor
        assert(v == running, string.format(
          "%s is mapped into a Lua %s interpreter", lib, running))
      end
    end
  end
  maps:close()
end
local names = {}
for lib in pairs(mapped) do names[#names + 1] = lib end
table.sort(names)
print(string.format("abi_match interpreter=%s linked=%s mapped=%s",
  running, linked, #names > 0 and table.concat(names, ",") or "none"))
