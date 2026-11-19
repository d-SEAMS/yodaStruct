-- Real reads of one .con, one PDB, one GRO, and one DCD file.
-- con, pdb, and gro skip only when the feature query for that reader is false.
-- dcd is a real read: a build without chemfiles fails it.
-- A missing fixture, a short cloud, a zero box, or a DCD box other
-- than 10 10 10 is a failure.

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
  dcd = {
    path = "input/readers/water.dcd",
    nop = 2,
    query = function()
      return dseams.has_chemfiles()
    end,
    fail = true,
    box = {10, 10, 10},
  },
}

local case = cases[kind]
if case == nil then
  error("readers.lua needs con, pdb, gro, or dcd")
end

if case.query() ~= true then
  if case.fail then
    error(string.format("%s: chemfiles is not in this build", kind))
  end
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
if case.box then
  if box[1] ~= case.box[1] or box[2] ~= case.box[2] or box[3] ~= case.box[3] then
    error(string.format(
      "%s box %s %s %s, want %d %d %d",
      case.path, tostring(box[1]), tostring(box[2]), tostring(box[3]),
      case.box[1], case.box[2], case.box[3]))
  end
elseif not (box[1] > 0 and box[2] > 0 and box[3] > 0) then
  error(string.format("%s box is empty", case.path))
end
print(string.format(
  "read %s nop=%d frame=%d box=%g %g %g",
  case.path, cloud.nop, cloud.currentFrame, box[1], box[2], box[3]))
