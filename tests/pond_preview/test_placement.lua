package.path='src/mobs_console/Scripts/?.lua;' .. package.path
local function obj(id,t)
    t=t or {}; t.IsValid=function() return true end; t.GetAddress=function() return id end; return t
end
local pawn=obj(1,{masterPtr=obj(2)})
local region=obj(3,{ownerPawn=pawn})
local at={X=0,Y=0,Z=0}
local ui,allowed,hidden=false,true,false
local clock,queue,click,cancel,mutations,checks,removed=0,{},nil,nil,0,0,0
local views,notices={},{}
local api={
    now=function() return clock end,
    bind=function(left,right) click=left; cancel=right end,
    defer=function(fn) queue[#queue+1]=fn end,
    sense=function() return at,region,ui end,
    available=function() return not hidden end,
    run=function(_,q)
        assert(q.rich==0)
        if q.preview then checks=checks+1; assert(allowed,'Footprint blocked'); return 'Preview: ready' end
        mutations=mutations+1; return 'Created completed pond'
    end,
    ghost=function()
        return {show=function(pos,ok,message) views[#views+1]={pos=pos,ok=ok,message=message} end,
            hide=function() end, destroy=function() removed=removed+1 end}
    end,
}
local tool=require('pond_preview').new(function() return pawn end,function(s) notices[#notices+1]=s end,api)
local function step() local fn=table.remove(queue,1); assert(fn); fn() end
-- The real placement check drives the moving view; a blocked click stays armed.
tool.start(pawn,{},false); step(); assert(views[#views].ok and mutations==0)
allowed=false; at={X=200,Y=10,Z=0}; step(); assert(not views[#views].ok)
click(); step(); step(); assert(mutations==0 and tool.active())
-- Even a previously green position must be rechecked at the actual click.
allowed=true; step(); assert(views[#views].ok)
allowed=false; click(); step(); step(); assert(mutations==0 and tool.active())
allowed=true; click(); step(); step(); assert(mutations==1 and not tool.active() and removed==1)
-- Outstanding timer/input callbacks cannot apply again.
while #queue>0 do step() end
assert(mutations==1)
-- Preview clicks and UI clicks do not create anything or consume the preview.
tool.start(pawn,{},true); step(); click(); step(); step(); assert(mutations==1 and tool.active())
ui=true; click(); step(); step(); assert(mutations==1 and tool.active())
ui=false; cancel(); step(); step(); assert(not tool.active() and removed==2)
while #queue>0 do step() end
-- Switching world/construction mode or expiry cleans up; no delayed mutation.
tool.start(pawn,{},false); hidden=true; step(); assert(not tool.active() and removed==3)
hidden=false; tool.start(pawn,{},false); clock=301; step(); assert(not tool.active() and removed==4)
-- Native apply may have partially succeeded: disarm before calling it, never retry.
clock=0; api.run=function(_,q) if q.preview then return 'ready' end mutations=mutations+1; error('partial native failure') end
tool.start(pawn,{},false); step(); click(); step(); step(); assert(not tool.active() and mutations==2)
while #queue>0 do step() end
assert(mutations==2 and notices[#notices]:find('partial native failure',1,true))
-- Explicit strict mode must reach both the read-only check and final native allocation.
local strict_checks,strict_applies=0,0
api.run=function(_,q)
    assert(q.rich==1)
    if q.preview then strict_checks=strict_checks+1 else strict_applies=strict_applies+1 end
    return 'strict result'
end
tool.start(pawn,{},false,true); step(); click(); step(); step()
assert(strict_checks>=2 and strict_applies==1 and not tool.active())
print('Pond ghost follows preflight, preserves blocked/dry-run clicks, cleans up and never repeats failed mutations')
