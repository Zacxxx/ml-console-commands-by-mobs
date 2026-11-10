package.path='src/mobs_console/Scripts/?.lua;' .. package.path
local function object(id,fields)
    fields=fields or {};fields.IsValid=function() return true end;fields.GetAddress=function() return id end;return fields
end
local engine=object(2)
local pawn=object(1,{masterPtr=engine})
local region=object(3,{ownerPawn=pawn})
local calls,armed,commands={},nil,{}
local pond=object(4,{Region=region,GetType=function() return 39 end,IsConstructed=function() return true end,
    K2_GetActorLocation=function() return {X=1,Y=2,Z=3} end})
local api={find=function() return {pond} end,run=function(_,request)
    calls[#calls+1]=request
    return 'Native operation complete.'
end}
local tools=require('world_tools').new(function() return pawn end,function(label,callback,owned)
    armed={label=label,callback=callback,owned=owned}; return 'armed'
end,api)
tools.register(function(name,_,handler) commands[name]=handler end)
local function rejects(name,args)
    assert(not pcall(commands[name],args));assert(#calls==0)
end
rejects('mobs.spawn_resource',{'typo'})
rejects('mobs.spawn_resource',{'berries','0'})
rejects('mobs.spawn_resource',{'berries','100','65'})
rejects('mobs.resource',{'remove','typo'})
rejects('mobs.resource',{'refresh','berries','oops'})
rejects('mobs.spawn_deposit',{'berries','100'})
rejects('mobs.spawn_deposit',{'iron','100','oops'})
rejects('mobs.remove_deposit',{'iron','oops'})
rejects('mobs.pond_fish',{'-1'})
rejects('mobs.refresh_resource_icons',{'berries'})
commands['mobs.refresh_resource_icons']({'preview'})
assert(calls[1].mode==11 and calls[1].preview and armed==nil)
calls={}
commands['mobs.refresh_resource_icons']({})
assert(calls[1].mode==11 and not calls[1].preview and armed==nil)
calls={}
commands['mobs.spawn_resource']({'berries','100','3','rich','preview'})
assert(#calls==0 and armed.owned~=false)
armed.callback(pawn,engine,region,{X=1,Y=2,Z=3})
assert(calls[1].mode==1 and calls[1].kind==6 and calls[1].amount==100 and calls[1].count==3 and calls[1].rich==1 and calls[1].preview)
calls={}
commands['mobs.resource']({'refresh','berries','preview'})
armed.callback(pawn,engine,region,{X=1,Y=2,Z=3})
assert(calls[1].mode==10 and calls[1].kind==6 and calls[1].preview)
calls={}
commands['mobs.resource']({'remove_clump','stone'})
armed.callback(pawn,engine,region,{X=1,Y=2,Z=3})
assert(calls[1].mode==3 and calls[1].kind==7)
calls={}
commands['mobs.spawn_deposit']({'clay','5000','rich'})
armed.callback(pawn,engine,region,{X=1,Y=2,Z=3})
assert(calls[1].mode==4 and calls[1].kind==3 and calls[1].amount==5000 and calls[1].rich==1)
calls={}
commands['mobs.pond_fish']({'500','preview'})
armed.callback(pawn,engine,region,{X=1,Y=2,Z=3})
assert(calls[1].mode==6 and calls[1].amount==500 and calls[1].preview)
calls={}
commands['mobs.instant_build']({'status'})
assert(calls[1].mode==7 and calls[1].rich==2 and calls[1].preview)
print('world_tools command preflight passed')

calls={}
commands['mobs.resource']({'add','iron','500','preview'})
armed.callback(pawn,engine,region,{X=1,Y=2,Z=3})
assert(calls[1].mode==9 and calls[1].amount==500 and calls[1].preview)
calls={}
local invalid_pond=pond
pond=object(5,{Region=object(6),GetType=function() return 39 end,IsConstructed=function() return true end})
commands['mobs.pond_fish']({'500'})
assert(not pcall(armed.callback,pawn,engine,region,{X=1,Y=2,Z=3}))
assert(#calls==0)
pond=invalid_pond
local other_region=object(7)
engine.DT_Units=object(8,{FindRow=function(_,name) return name=='brigands' end})
engine.pointCollidesWithBuildingBorder=function() return false end
commands['mobs.bandit_camp']({'preview'})
assert(armed.owned==false)
assert(not pcall(armed.callback,pawn,engine,region,{X=1,Y=2,Z=3}))
armed.callback(pawn,engine,other_region,{X=1,Y=2,Z=3})
assert(calls[1].mode==8 and calls[1].preview)
