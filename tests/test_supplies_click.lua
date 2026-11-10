package.path = "src/mobs_console/Scripts/?.lua;" .. package.path
local function object(id, fields)
    fields = fields or {}
    fields.IsValid = function() return true end
    fields.GetAddress = function() return id end
    return fields
end
local function wrapped(value)
    return setmetatable({ToString=function() return value end},
        {__tostring=function() return "Unreal string wrapper" end})
end
local pawn = object(1)
local region = object(2, {ownerPawn=pawn, regionName=wrapped("Test region")})
local buildings, deferred, messages = {}, {}, {}
local click
Key = {LEFT_MOUSE_BUTTON=1}
RegisterKeyBind = function(key, callback) assert(key == 1); click=callback end
ExecuteWithDelay = function(_, callback) deferred[#deferred+1]=callback end
ExecuteInGameThread = function(callback) callback() end
FindAllOf = function() return buildings end
local stats = object(3, {FindRow=function() return {DisplayName=wrapped("supply_dump")} end})
StaticFindObject = function() return stats end
package.preload.UEHelpers = function()
    return {GetGameInstance=function() return {GetAppVersion=function() return wrapped("Version 0.8.117") end} end}
end
pawn.masterPtr = object(4, {itemStats=object(5, {
    GetRowNames=function() return {wrapped("172"), wrapped("16")} end,
    FindRow=function(_, name)
        return {Name=wrapped(name == "172" and "Bread" or "Wood"), ItemCategory=1, storageType=0}
    end,
})})
pawn.isInAnyConstructionMode = function(self) return self.placing or false end
pawn.activateBuildingMode = function(self, id) assert(id == 88); self.placing=true end
pawn.resetBuildingMode = function(self) self.placing=false end
pawn.regionUnderCursor = region
pawn.getMouse3d = function() return {X=0,Y=0,Z=0} end
local function drain()
    while #deferred > 0 do table.remove(deferred, 1)() end
end
local function building(id, kind, built, goods)
    local b = object(id, {Region=region, Inventory={}, constructionGoods=goods or {}})
    b.GetType = function() return kind end
    b.IsConstructed = function() return built end
    b.K2_GetActorLocation = function() return {X=0,Y=0,Z=0} end
    b.addToInventory = function(self, good) self.Inventory[#self.Inventory+1]=good end
    b.GetStockThatPeopleAreBringing = function() return 1 end
    return b
end
local supplies = require("supplies").new(function() return pawn end,
    function(message) messages[#messages+1]=message end)
supplies.arm_pile("bread", "5")
local pile = building(10, 88, false)
buildings = {pile}
click(); drain()
assert(#pile.Inventory == 1 and pile.Inventory[1].amt == 5)
assert(not pawn.placing and supplies.status():find("New pile supplied",1,true))
click(); drain()
assert(#pile.Inventory == 1, "Delivery must disarm after one click")
local site = building(11, 3, false, {{Type=16,amt=10}})
site.Inventory = {{Type=16,amt=3}}
pawn.hitBuilding=site
supplies.arm("16", "100")
click(); drain()
assert(#site.Inventory == 2 and site.Inventory[2].amt == 6,
    "Construction delivery must subtract stored and incoming materials")
supplies.arm_pile("172", "5")
supplies.cancel()
click(); drain()
assert(#pile.Inventory == 1 and not pawn.placing)
supplies.arm("16", "1")
click()
supplies.cancel()
supplies.arm("16", "2")
drain()
assert(#site.Inventory == 2, "An old queued click must not consume a newly armed request")
supplies.cancel()
print("Pile click, wrapped names, unfinished pile, one-shot delivery, construction deficit and cancellation passed")

-- Explicit inventory_add supports completed non-storage buildings, deduplicates,
-- preflights foreign targets, and leaves ordinary give's storage rules intact.
pawn.getSelectedBuildings=function() return buildings end
setmetatable(pawn,{__index=function(_,key) if key=='selectedBld' then return buildings end end})
local workshop=building(30,5,true)
workshop.isStorageTypeBuilding=function() return false end
buildings={workshop,workshop}
assert(not pcall(supplies.give,'bread','10',false))
assert(supplies.give('bread','10',true,true):find('10 Bread'))
assert(#workshop.Inventory==0)
supplies.give('bread','10',false,true)
assert(#workshop.Inventory==1 and workshop.Inventory[1].amt==10)
local foreign=building(31,5,true)
foreign.Region=object(32,{ownerPawn=object(33)})
buildings={workshop,foreign}
assert(not pcall(supplies.give,'bread','10',false,true))
assert(#workshop.Inventory==1, 'Foreign target must stop the whole batch before the first write')
print('Production-building inventory add, preview, deduplication and ownership preflight passed')
