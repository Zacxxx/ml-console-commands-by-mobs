package.path='src/mobs_console/Scripts/?.lua;' .. package.path
local function object(id,v)
    v=v or {};v.IsValid=function() return true end;v.GetAddress=function() return id end;return v
end
local engine=object(1)
local pawn=object(2,{masterPtr=engine})
local region=object(3,{ownerPawn=pawn})
engine.getRegionByPos=function() return region end
local deposit=object(4,{depositedGood={Type=14,amt=100},bRichDeposit=false,Limit=1000})
deposit.K2_GetActorLocation=function() return {X=100,Y=100,Z=0} end
local handler,callback={}
local tools=require('deposit_tools').new(function() return pawn end,function(_,fn) callback=fn;return 'armed' end,
    {find=function() return {deposit} end})
tools.register(function(n,_,fn) handler[n]=fn end)
handler['mobs.deposit']({'add','iron','50','preview'})
assert(callback(pawn,engine,region,{X=100,Y=100,Z=0}):find('Preview'))
assert(deposit.depositedGood.amt==100)
handler['mobs.deposit']({'add','iron','50'})
callback(pawn,engine,region,{X=100,Y=100,Z=0})
assert(deposit.depositedGood.amt==150)
handler['mobs.undo_deposit']({});assert(deposit.depositedGood.amt==100)
handler['mobs.deposit']({'rich','iron'})
callback(pawn,engine,region,{X=100,Y=100,Z=0});assert(deposit.bRichDeposit)
deposit.depositedGood.amt=90
assert(not pcall(handler['mobs.undo_deposit'],{}));assert(deposit.bRichDeposit)
handler['mobs.deposit']({'add','iron','1000'})
assert(not pcall(callback,pawn,engine,region,{X=100,Y=100,Z=0}))
assert(deposit.depositedGood.amt==90)
print('underground deposit preview, limits, rich flag and guarded undo passed')
