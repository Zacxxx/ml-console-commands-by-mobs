package.path='src/mobs_console/Scripts/?.lua;' .. package.path
local function object(id,props)
    props=props or {}; props.IsValid=function() return true end; props.GetAddress=function() return id end
    return props
end
local pawn=object(1)
local region=object(2,{ownerPawn=pawn})
local other=object(3,{ownerPawn=object(4)})
local fish=object(5,{Region=region,amt=12,capacity=40})
local foreign=object(6,{Region=other,amt=5,capacity=40})
fish.IsA=function() return true end; foreign.IsA=fish.IsA
StaticFindObject=function() return object(7) end
FindAllOf=function(cls) return cls=='Resource_Fish_C' and {fish,foreign,fish} or {} end
local commands={}
require('resources').new(function() return pawn end,function() return region end,function() return 'Owned' end)
    .register(function(n,_,fn) commands[n]=fn end)
commands['mobs.empty_resources']({'fish','preview'}); assert(fish.amt==12 and foreign.amt==5)
commands['mobs.empty_resources']({'fish'}); assert(fish.amt==0 and foreign.amt==5)
commands['mobs.undo_resources']({}); assert(fish.amt==12)
commands['mobs.refill_resources']({'fish'}); assert(fish.amt==40)
fish.amt=39
assert(not pcall(commands['mobs.undo_resources'],{})); assert(fish.amt==39)
assert(not pcall(commands['mobs.empty_resources'],{'all','unknown'})); assert(fish.amt==39)
print('resource depletion, deduplication, ownership and guarded undo passed')
