package.path='src/mobs_console/Scripts/?.lua;' .. package.path
local function obj(id,t)
    t=t or {};t.IsValid=function() return true end;t.GetAddress=function() return id end;return t
end
local pawn,hidden=obj(1),{}
local own_region=obj(2,{ownerPawn=pawn})
local foreign=obj(3,{ownerPawn=obj(4)})
local engine=obj(5,{getRegionByPos=function(_,at) return at.X<0 and foreign or own_region end})
pawn.masterPtr=engine
local function actor(id,x,t)
    t=obj(id,t);t.K2_GetActorLocation=function() return {X=x,Y=0,Z=0} end
    t.SetActorHiddenInGame=function(_,value) assert(value);hidden[id]=(hidden[id] or 0)+1 end
    return t
end
local reserve=actor(10,100,{depositedGood={Type=14,amt=1000},Limit=1000,bRichDeposit=true})
local foreign_reserve=actor(11,-100,{depositedGood={Type=14,amt=20}})
local other_reserve=actor(12,100,{depositedGood={Type=5,amt=30}})
local iron=actor(13,100,{Type=14,amt=1000,capacity=1000})
local stone=actor(14,100,{Type=15,amt=100,capacity=100})
local berries=actor(15,100,{Type=1,amt=8,capacity=8})
local node=actor(16,100,{masterPtr=engine,resourceClumps={iron,stone,berries},PaperMapDecal=obj(17)})
local natural=actor(18,100,{masterPtr=engine,resourceClumps={}})
local queue,clock={},0
local api={find=function(class)
    return class=='DepositDecal' and {reserve,foreign_reserve,other_reserve} or {node,natural}
end,version=function() return 'Version 0.8.117' end,
    defer=function(fn) queue[#queue+1]=fn end}
local visuals=require('deposit_visuals').new(function() return pawn end,api)
local count=visuals.refresh(true)
assert(count==2 and next(hidden)==nil)
assert(visuals.refresh(false)==2 and hidden[10]==1 and hidden[13]==1)
assert(not hidden[11] and not hidden[12] and not hidden[14] and not hidden[15] and not hidden[16])
assert(reserve.depositedGood.amt==1000 and reserve.bRichDeposit and iron.amt==1000 and iron.capacity==1000)
assert(#node.resourceClumps==3 and node.PaperMapDecal:IsValid())
-- Reapply after reload/map changes without depending on object addresses remaining stable.
visuals.start();assert(#queue==1);table.remove(queue,1)();assert(hidden[10]==2 and hidden[13]==2)
visuals.stop();table.remove(queue,1)();assert(#queue==0)
api.version=function() return 'Version 9.9' end
assert(not pcall(visuals.refresh,false))
print('Deposit visual repair hides only owned mineral render actors; amounts, nodes, foreign deposits and surface stones remain')
