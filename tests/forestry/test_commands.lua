package.path='src/mobs_console/Scripts/?.lua;'..package.path
local pawn={IsValid=function() return true end,GetAddress=function() return 1 end}
local region={ownerPawn=pawn,IsValid=function() return true end,GetAddress=function() return 2 end}
local calls,queued,notifications,registry={},{},{},{}
local api={bind=function() end,defer=function(fn) queued[#queued+1]=fn end,
 run=function(r,p,mode,preview,_,_,cursor)
 assert(r==region and p==pawn)
 calls[#calls+1]={mode=mode,preview=preview,cursor=cursor}
 if preview then return {eligible=1,before=1,enrolled=mode==0 and 2 or 0,remaining=1,steps=0,planted=0,completed=0,blocked=0,cursor=0} end
 if cursor then return {before=2,enrolled=0,remaining=0,steps=4,planted=0,completed=2,blocked=0,cursor=0} end
 return {before=1,enrolled=2,remaining=2,steps=500,planted=0,completed=1,blocked=0,cursor=0}
 end}
local tools=require('forestry').new(function() return pawn end,function(owned) assert(owned); return region end,
 function() return 'Forest' end,function(msg) notifications[#notifications+1]=msg end,api)
tools.register(function(name,_,fn) registry[name]=fn end)
assert(registry['mobs.grow_saplings'],'New sapling command is registered')
assert(registry['mobs.grow_trees']({'preview'}):find('2 untracked'))
assert(calls[#calls].mode==0 and #queued==0)
registry['mobs.grow_saplings']({'preview'}); assert(calls[#calls].mode==3)
registry['mobs.grow_trees']({}); assert(#queued==1)
queued[1](); assert(calls[#calls].mode==3 and calls[#calls].cursor==0)
assert(notifications[#notifications]:find('0 remain'))
registry['mobs.grow_saplings']({}); local before=#calls
assert(tools.cancel()); queued[#queued](); assert(#calls==before)
assert(not pcall(registry['mobs.grow_saplings'],{'bad'}))
print('Forestry modes, sapling command, read-only preview, continuation and cancellation passed')

local field={Region=region,IsValid=function() return true end,GetAddress=function() return 3 end,
    workAreaLimited=true,workAreaRange=1000,workAreaCenter={X=10,Y=20}}
pawn.getSelectedBuildings=function() return {field} end
registry['mobs.grow_stage']({'area','preview'})
assert(calls[#calls].mode==5)
registry['mobs.grow_saplings']({'area','preview'})
assert(calls[#calls].mode==6)
assert(#queued==2) -- Preview adds no jobs; these are the two earlier test jobs.
field.workAreaLimited=false
assert(not pcall(registry['mobs.grow_stage'],{'area'}))
print('Forestry stage and limited-work-area routing passed')
