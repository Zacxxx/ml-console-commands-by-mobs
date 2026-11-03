package.path = "src/mobs_console/Scripts/?.lua;" .. package.path
local function object(id, fields)
    fields = fields or {}
    fields.alive = true
    fields.IsValid = function(self) return self.alive end
    fields.GetAddress = function() return id end
    fields.IsA = function() return true end
    return fields
end
local pawn = object(1)
local owner_other = object(2)
local region = object(3, {ownerPawn=pawn})
local elsewhere = object(4, {ownerPawn=owner_other})
local function pile(id, where, inventory, kind)
    local b=object(id, {Region=where, Inventory=inventory or {}})
    b.IsActorBeingDestroyed=function(self) return not self.alive end
    b.GetType=function() return kind or 88 end
    b.demolish=function(self, refund) assert(refund == false); self.alive=false end
    return b
end
local empty = pile(10,region)
local full = pile(11,region,{{Type=172,amt=5}})
local foreign = pile(12,elsewhere)
local house = pile(13,region,{},3)
local broken = pile(14,region,{{Type=172}})
local zero = pile(15,region,{{Type=172,amt=0}})
local all={empty,full,foreign,house,broken,zero}
pawn.selectedBld={}

StaticFindObject=function() return {} end
local handlers, notices={}, {}
local tools=require("pile_tools").new(function() return pawn end, function() return region end,
    function() return "Test region" end, {
        defer=function(callback) callback() end,
        notify=function(message) notices[#notices+1]=message end,
        buildings=function() return all end,
        ensure_supported=function() end,
    })
tools.register(function(name,usage,handler) handlers[name]=handler end)
local clear=assert(handlers['mobs.clear_empty_piles'])
local selected=assert(handlers['mobs.remove_selected_piles'])
assert(clear({'preview'}):find('2',1,true))
assert(empty.alive and zero.alive)
assert(not pcall(clear, {'invalid'}))
clear({})
assert(not empty.alive and not zero.alive)
assert(full.alive and foreign.alive and house.alive and broken.alive)
assert(clear({}):find('0',1,true), 'Repeated cleanup must be harmless')
pawn.selectedBld={full,house}
assert(not pcall(selected, {})); assert(full.alive and house.alive)
pawn.selectedBld={full,foreign}
assert(not pcall(selected, {})); assert(full.alive and foreign.alive)
pawn.selectedBld={full,full,broken}
selected({'preview'}); assert(full.alive and broken.alive)
selected({}); assert(not full.alive and not broken.alive)
assert(house.alive and foreign.alive)
pawn.selectedBld={}
assert(not pcall(selected, {}))
local blocked=pile(20,region)
blocked.demolish=function() end
all={blocked}
clear({})
assert(notices[#notices]:find('0 removed; 1 still present',1,true), 'A native refusal must not be reported as success')
print('Pile cleanup scope, preview, ownership, mixed-selection preflight, deduplication, corrupt contents, native refusal and repeat checks passed')
