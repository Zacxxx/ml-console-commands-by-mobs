package.path='src/mobs_console/Scripts/?.lua;' .. package.path
local function object(id,p)
    p=p or {};p.IsValid=function() return true end;p.GetAddress=function() return id end;return p
end
local engine=object(1)
local pawn=object(2,{masterPtr=engine})
local region=object(3,{ownerPawn=pawn})
local moved=0
local unit=object(4,{masterPtr=engine,Home={Region=region},realPos={X=100,Y=100,Z=0},dead=false})
unit.Home.IsValid=function() return true end
unit.Home.GetAddress=function() return 6 end
unit.K2_GetActorRotation=function() return {Pitch=0,Yaw=0,Roll=0} end
unit.K2_TeleportTo=function(_,at) moved=moved+1; return at.X==500 end
unit.updateCurrentRegion=function() end
pawn.hoverUnit=unit
engine.getRegionByPos=function() return region end
local commands,callback={},nil
require('teleport_tools').register(function(n,_,fn) commands[n]=fn end,function() return pawn end,
    function(_,fn) callback=fn;return 'armed' end)
commands['mobs.teleport']({'unit','preview'})
assert(callback(pawn,engine,region,{X=500,Y=500,Z=0}):find('Preview'))
assert(moved==0 and unit.realPos.X==100)
commands['mobs.teleport']({'unit'})
callback(pawn,engine,region,{X=500,Y=500,Z=0})
assert(moved==1 and unit.realPos.X==500 and unit.lastInstacePosition.X==500)
commands['mobs.teleport']({'unit'})
region.ownerPawn=object(7)
assert(not pcall(callback,pawn,engine,region,{X=500,Y=500,Z=0}))
assert(moved==1)
print('teleport preview, simulated position sync and ownership recheck passed')
