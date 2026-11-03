package.path='src/mobs_console/Scripts/?.lua;'..package.path
local store, applied, fingerprint = {}, {}, 'first'
local pawn={GetAddress=function() return 11 end,IsValid=function() return true end}
pawn.masterPtr={GetAddress=function() return 22 end,IsValid=function() return true end}
local primary={[1]='origins_a',[3]='rural_a'}
local region={ownerPawn=pawn,PerkComponent={GetAddress=function() return 33 end,
 GetActivePerkInSlot=function(_,s) return {ToString=function() return primary[s] or 'None' end} end},
 IsValid=function() return true end,getRegionUniqueID=function() return 7 end}
region.PerkComponent.IsValid=function() return true end
local rows={{key='origins_a',label='First Origins',tier=1},{key='origins_b',label='Second Origins',tier=1},
 {key='rural_a',label='First Rural',tier=2},{key='rural_b',label='Second Rural',tier=2}}
local api={catalog=function() return rows,{} end,
 apply=function(_,_,_,_,cards,preview) if not preview then
 applied={}; for _,c in ipairs(cards) do applied[#applied+1]=c.key end end
 return {effects=5} end,
 files=function() return {pid=123,files={saveGame_1=fingerprint}} end,
 load_slot=function() return 'saveGame_1' end,
 read=function(k) return store[k] end, write=function(k,v) store[k]=v end,
 regions=function() return {region} end}
local function make()
 local s=require('perk_stack').new(function() return pawn end,function() return region end,function() return 'Town' end,api)
 local cmds={}; s.register(function(n,_,f) cmds[n]=f end); return s,cmds
end
local s,c=make()
assert(s.describe({'list'}):find('Second Origins'))
assert(s.describe({'add','2','preview'}):find('Preview'))
assert(c['mobs.perks_add'] and c['mobs.perks_remove'] and c['mobs.perks_clear'])
assert(c['mobs.perk_add']({'2','preview'}):find('Preview')); assert(#applied==0)
c['mobs.perk_add']({'2'}); assert(#applied==1 and applied[1]=='origins_b')
assert(c['mobs.perk_add']({'Second','Origins'}):find('already'))
assert(#applied==1)
c['mobs.perk_add']({'4'}); assert(#applied==2)
assert(not pcall(c['mobs.perk_add'],{'First'})) -- ambiguous
assert(not pcall(c['mobs.perk_remove'],{'1'})) -- primary kept
fingerprint='second'; s.tick() -- actual save file changed, capture sidecar
local serialized=store['save_saveGame_1_second']; assert(serialized and serialized:find('origins_b'))
c['mobs.perk_remove']({'2'}); assert(#applied==1 and applied[1]=='rural_b')
local hot=make(); hot.tick(); assert(#applied==1) -- journal survives mod reload
-- A new process loads the saved snapshot, not the later unsaved removal.
api.files=function() return {pid=124,files={saveGame_1='second'}} end
local loaded=make(); loaded.tick(); assert(#applied==2)
loaded.clear_tiers(4); assert(#applied==1 and applied[1]=='origins_b')
loaded.clear_tiers(5); assert(#applied==0)
local before=0; for _ in pairs(store) do before=before+1 end
region.ownerPawn={GetAddress=function() return 99 end,IsValid=function() return true end}
assert(not pcall(c['mobs.perk_add'],{'2'}))
local after=0; for _ in pairs(store) do after=after+1 end; assert(before==after)
print('Stacked perks: multiple cards, duplicate and primary protection, previews, name matching, saved snapshots, hot reload and ownership passed')
local module=require('perk_stack')
assert(not pcall(module.decode,'bad header'))
assert(not pcall(module.decode,'MOBS_PERK_STACK_1\n7\torigins_b\n7\torigins_b\n'))
assert(not pcall(module.decode,'MOBS_PERK_STACK_1\n../bad\tcard\n'))
assert(next(module.decode(module.encode({})))==nil)
-- Refuse persistence failures before changing gameplay effects.
region.ownerPawn=pawn
api.files=function() return {pid=125,files={saveGame_1='no-sidecar'}} end
api.write=function() error('disk full') end
local fail,fail_commands=make()
local previous=table.concat(applied,'|')
assert(not pcall(fail_commands['mobs.perk_add'],{'2'}))
assert(table.concat(applied,'|')==previous)
print('Malformed state and failed disk writes leave gameplay untouched')
