package.path='src/mobs_console/Scripts/?.lua;' .. package.path
local access=require('game_access')
local pawn={}
local function object(id)
    return {IsValid=function() return true end,GetAddress=function() return id end}
end
pawn=object(1)
local region=object(2); region.ownerPawn=pawn
local first=object(3);first.Region=region
local second=object(4);second.Region=region
pawn.selectedBld={first,second,first}
pawn.getSelectedBuildings=function() error('Do not borrow the temporary by-value array') end
local selected=access.selected(pawn)
assert(#selected==2 and selected[1]==first and selected[2]==second)
local foreign=object(5);foreign.Region=object(6);foreign.Region.ownerPawn=object(7)
pawn.selectedBld={first,foreign}
assert(not pcall(access.selected,pawn),'Mixed ownership must fail before mutations')
pawn.selectedBld={}
assert(not pcall(access.selected,pawn),'Empty selection must not fall back to a hovered building')
print('Live owned selection, deduplication and foreign-target rejection passed')
