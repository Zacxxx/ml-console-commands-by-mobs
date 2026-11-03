package.path = 'src/mobs_console/Scripts/?.lua;' .. package.path
local registry, calls = {}, {}
local pawn = {GetAddress=function() return 1 end, IsValid=function() return true end}
local component = {IsValid=function() return true end,
 GetActivePerkInSlot=function(_, slot) return {ToString=function() return slot==1 and 'OldOrigins' or 'OldRural' end} end}
local region={ownerPawn=pawn, PerkComponent=component, IsValid=function() return true end}
local tools=require('perk_tools').new(function() return pawn end,function(owned) assert(owned); return region end,
 function() return 'Test Town' end,{run=function(r,p,c,mask,preview)
 assert(r==region and p==pawn and c==component)
 calls[#calls+1]={mask=mask,preview=preview}
 return {removed1=1,removed2=1,available1=1,available2=0}
 end})
tools.register(function(name,_,fn) registry[name]=fn end)
local function run(name,args) return registry[name](args or {}) end
assert(run('mobs.perks'):find('OldOrigins'))
run('mobs.perk_points',{'2'}); assert(calls[#calls].mask==4 and not calls[#calls].preview)
run('mobs.perk_points',{'both','preview'}); assert(calls[#calls].mask==5 and calls[#calls].preview)
run('mobs.respec_perks',{'1'}); assert(calls[#calls].mask==5)
run('mobs.respec_perks'); assert(calls[#calls].mask==5)
for _,args in ipairs({{'3'},{'1','99'},{'both','preview','extra'}}) do
 local before=#calls
 assert(not pcall(run,'mobs.perk_points',args)); assert(#calls==before)
end
local before=#calls
region.ownerPawn={GetAddress=function() return 2 end,IsValid=function() return true end}
assert(not pcall(run,'mobs.respec_perks')); assert(#calls==before)
print('Perk commands: tier routing, preview, prerequisite cascade, argument and ownership checks passed')
