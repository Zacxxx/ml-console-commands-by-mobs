package.path='src/mobs_console/Scripts/?.lua;' .. package.path
local function obj(id,t)
    t=t or {}; t.IsValid=function() return true end; t.GetAddress=function() return id end; return t
end
local pawn=obj(1,{masterPtr=obj(2)})
local region=obj(3,{ownerPawn=pawn})
local settings={resourceDepositRadius=2000,resourceRichDepositRadius=2500}
local at={X=12345,Y=34567,Z=90}
local queue,left,right,requests,views,removed={},nil,nil,{}, {},0
local blocked,now=false,0
local api={
    settings=function() return settings end,
    now=function() return now end,
    defer=function(fn) queue[#queue+1]=fn end,
    bind=function(l,r) left=l; right=r end,
    available=function() return true end,
    sense=function() return at,region,false end,
    ghost=function(_,definition)
        assert(definition.kind==2 and definition.amount==1500 and definition.rich==1 and definition.radius==2500)
        assert(#definition.customBorder==48)
        return {destroy=function() removed=removed+1 end,hide=function() end,
            show=function(pos,ok) views[#views+1]={at=pos,ok=ok} end}
    end,
    run=function(_,request)
        requests[#requests+1]=request
        assert(request.mode==4 and request.kind==2 and request.amount==1500 and request.rich==1)
        assert(request.at.X==at.X and request.at.Y==at.Y)
        assert(not blocked,'Native blocker')
        return request.preview and 'Native deposit plan' or 'Created native deposit'
    end,
}
local tool=require('deposit_preview').new(function() return pawn end,function() end,api)
local function step() assert(#queue>0); table.remove(queue,1)() end
local function drain() while #queue>0 do step() end end
local request={mode=4,kind=2,amount=1500,rich=1,preview=false}
tool.start(pawn,request); step(); assert(requests[1].preview and views[#views].ok)
blocked=true; left(); step(); step(); assert(tool.active() and not views[#views].ok)
for _,r in ipairs(requests) do assert(r.preview) end
blocked=false; at={X=8765,Y=4321,Z=12}; left(); step(); step()
assert(not tool.active() and removed==1 and not requests[#requests].preview)
assert(requests[#requests].at.X==8765 and requests[#requests].at.Y==4321)
drain(); local mutations=0; for _,r in ipairs(requests) do if not r.preview then mutations=mutations+1 end end
assert(mutations==1)
request.preview=true; tool.start(pawn,request); step(); left(); step(); step()
assert(tool.active() and requests[#requests].preview)
right(); step(); step(); assert(not tool.active()); drain()
local normal=require('deposit_preview').definition(settings,{kind=3,amount=100,rich=0})
assert(normal.radius==2000 and normal.material_property=='depositMaterial_Clay')
assert(normal.customBorder[1].X==2000 and math.abs(normal.customBorder[1].Y)<0.001)
assert(not pcall(require('deposit_preview').definition,{resourceDepositRadius=0},{kind=2,amount=100,rich=0}))
assert(not pcall(require('deposit_preview').definition,settings,{kind=6,amount=100,rich=0}))
print('Deposit preview: native radius, exact click coordinates, blocked retries, read-only mode and cancellation pass')
