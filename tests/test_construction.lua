package.path = "src/mobs_console/Scripts/?.lua;" .. package.path
local construction = require("construction")
local function object(id, fields)
    fields = fields or {}
    fields.IsValid = function() return true end
    fields.GetAddress = function() return id end
    fields.GetType = fields.GetType or function() return 3 end
    fields.GetFullName = function() return "test_" .. id end
    return fields
end
local function array(items)
    items.GetArrayNum = function(self) return #self end
    return items
end
local region, other = object(1), object(2)
local building = object(3, {Region=region, isBeingUpgraded=false, built=false,
    constructionGoods=array({{Type=4, amt=10}}), Inventory={{Type=4, amt=3}}})
building.IsConstructed = function(self) return self.built end
building.GetType = function() return 3 end
building.addToInventory = function(self, good) self.Inventory[#self.Inventory+1] = good end
building.setConstructionPaused = function(self, paused) self.paused = paused end
local part = object(4, {BuildingMaster=building, MobsConstructionWorkDone=1, MobsConstructionWorkTotal=20})
local foreign = object(5, {Region=other, IsConstructed=function() return false end})
local built = object(6, {Region=region, IsConstructed=function() return true end, isBeingUpgraded=false})
local pile = object(7, {Region=region, GetType=function() return 88 end,
    IsConstructed=function() return false end})
local api = {buildings=function() return {building,foreign,built,pile} end,
    parts=function() return {part} end, ensure_layout=function() end}
local preview = construction.prepare(region, true, api)
assert(preview.pending == 1 and preview.prepared == 0)
assert(part.MobsConstructionWorkDone == 1 and #building.Inventory == 1)
part.MobsConstructionWorkTotal = 0/0
assert(not pcall(construction.prepare, region, false, api))
assert(part.MobsConstructionWorkDone == 1 and #building.Inventory == 1)
part.MobsConstructionWorkTotal = 20
local result = construction.prepare(region, false, api)
assert(result.pending == 1 and result.prepared == 1)
assert(part.MobsConstructionWorkDone == 20 and building.paused == false)
assert(#building.Inventory == 2 and building.Inventory[2].amt == 7)
assert(not building.built, "Only the game may finalize constructed state")
api.ensure_layout = function() error("Unsupported build") end
part.MobsConstructionWorkDone = 1
assert(not pcall(construction.prepare, region, false, api))
assert(part.MobsConstructionWorkDone == 1)
print("Construction preview, targeting, preflight, material deficit and build guard passed")
