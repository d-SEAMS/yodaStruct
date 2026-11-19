-- Real reads of one .con, one PDB, and one GRO file.
-- Skip only when the feature query for that reader is false.
-- A missing fixture, a short cloud, or a zero box is a failure.

local dseams = require("dseams")

local kind = arg[1]
local cases = {
  con = {
    path = "input/readers/cuh2.con",
    nop = 4,
    query = function()
      return dseams.has_readcon()
    end,
  },
  pdb = {
    path = "input/readers/water.pdb",
    nop = 2,
    query = function()
      return dseams.has_chemfiles()
    end,
  },
  gro = {
    path = "input/readers/water.gro",
    nop = 2,
    query = function()
      return dseams.has_chemfiles()
    end,
  },
}

local case = cases[kind]
if case == nil then
  error("readers.lua needs con, pdb, or gro")
end

if case.query() ~= true then
  io.stderr:write(string.format("SKIP %s: feature query is false\n", kind))
  os.exit(77)
end

local cloud = dseams.read(case.path, {frame = 1})
if cloud.nop ~= case.nop then
  error(string.format("%s nop %s, want %d", case.path, tostring(cloud.nop), case.nop))
end
if cloud.currentFrame ~= 1 then
  error(string.format("%s frame %s, want 1", case.path, tostring(cloud.currentFrame)))
end
local box = cloud:box()
if not (box[1] > 0 and box[2] > 0 and box[3] > 0) then
  error(string.format("%s box is empty", case.path))
end
print(string.format(
  "read %s nop=%d frame=%d box=%g %g %g",
  case.path, cloud.nop, cloud.currentFrame, box[1], box[2], box[3]))
