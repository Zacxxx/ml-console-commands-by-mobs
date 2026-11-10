package.path='src/mobs_console/Scripts/?.lua;' .. package.path
local function object(id,fields)
    fields=fields or {};fields.IsValid=function() return true end;fields.GetAddress=function() return id end
    return fields
end
local pawn=object(1)
local region=object(2,{ownerPawn=pawn,isSettled=true,Approval=10,workerFamilies={}})
local people,spawned=0,0
region.getNumHumanResidents=function() return people end
region.GetMonthlyPopChange=function() return 0 end
region.getNumHomelessFamilies=function() return 0 end
local redistributed=0
region.redistributeMilitiaRecruits=function() redistributed=redistributed+1 end
local home=object(3,{Region=region,buildingFunction=1,sleep=false,mourningPeriod=0})
home.IsConstructed=function() return true end
home.getMaxResidingFamilies=function() return 2 end
home.getNumResidingFamilies=function() return #region.workerFamilies end
local api={find=function() return {home,home} end,spawn=function(_,_,family_id,role,target,preview)
    assert(target==home)
    if preview then return end
    spawned=spawned+1
    if family_id<0 then
        family_id=#region.workerFamilies
        region.workerFamilies[family_id+1]={familyHome=home,familyMembers={}}
    end
    local members=region.workerFamilies[family_id+1].familyMembers
    members[#members+1]=object(10+people,{assignedUnitRole=role,dead=false,Home=home})
    people=people+1
end}
local commands={}
require('population_tools').register(function(name,_,fn) commands[name]=fn end,function() return pawn end,
    function() return region end,function() return 'Test' end,api)
local command=assert(commands['mobs.grow_population'])
assert(command({'status'}):find('approval=10',1,true))
assert(command({'status'}):find('natural monthly growth=0',1,true))
assert(command({'6','preview'}):find('6 people',1,true));assert(people==0 and spawned==0)
assert(not pcall(command,{'7'}));assert(people==0 and spawned==0)
local result=command({'5'})
assert(people==5 and spawned==5 and #region.workerFamilies==2)
assert(redistributed==1)
assert(result:find('added 5/5 people',1,true))
assert(region.Approval==10 and region.GetMonthlyPopChange()==0)
assert(region.workerFamilies[1].familyMembers[1].assignedUnitRole==0)
assert(region.workerFamilies[1].familyMembers[2].assignedUnitRole==1)
assert(region.workerFamilies[1].familyMembers[3].assignedUnitRole==2)
command({});assert(people==6 and #region.workerFamilies==2)
assert(not pcall(command,{'1'}));assert(people==6)
for _,args in ipairs({{'0'},{'11'},{'1.5'},{'status','oops'},{'1','extra'}}) do assert(not pcall(command,args)) end
home.mourningPeriod=2;assert(not pcall(command,{'1'}));home.mourningPeriod=0
home.Region=object(99);assert(not pcall(command,{'1'}));home.Region=region
region.ownerPawn=object(98);assert(not pcall(command,{'1'}));region.ownerPawn=pawn
region.isSettled=false;assert(not pcall(command,{'1'}));region.isSettled=true
-- Check each housing gate with genuinely vacant housing, not an already full plan.
region.workerFamilies={};people=0;spawned=0
home.mourningPeriod=2;assert(not pcall(command,{'1'}));home.mourningPeriod=0
home.sleep=true;assert(not pcall(command,{'1'}));home.sleep=false
home.IsConstructed=function() return false end;assert(not pcall(command,{'1'}))
home.IsConstructed=function() return true end
region.getNumHomelessFamilies=function() return 1 end
assert(not pcall(command,{'1'}));assert(people==0 and spawned==0)
region.getNumHomelessFamilies=function() return 0 end
-- All distinct homes/families are preflighted before the first creation.
local normal_spawn=api.spawn
local checked=0
api.spawn=function(a,b,c,d,e,preview)
    if preview then checked=checked+1;if checked==2 then error('Second entrance blocked') end end
    normal_spawn(a,b,c,d,e,preview)
end
assert(not pcall(command,{'6'}));assert(people==0 and spawned==0)
api.spawn=normal_spawn
-- A refused native arrival stops the batch; it is never retried automatically.
region.workerFamilies={};people=0;spawned=0
api.spawn=function(...)
    if spawned==1 then error('Native entrance blocked') end
    normal_spawn(...)
end
result=command({'3'})
assert(people==1 and spawned==1 and result:find('Stopped:',1,true))
assert(result:find('added 1/3 people',1,true))
-- A call returning without a population increase must not be counted or retried.
region.workerFamilies={};people=0;spawned=0
api.spawn=function(_,_,_,_,_,preview) if not preview then spawned=spawned+1 end end
result=command({'2'})
assert(people==0 and spawned==1 and result:find('Stopped:',1,true))
print('Population: deterministic counts, roles, housing, low approval/off-schedule, preview, ownership and partial failure passed')
