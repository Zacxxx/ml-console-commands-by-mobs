package.path='src/mobs_console/Scripts/?.lua;' .. package.path
local function obj(t)
    t=t or {}; t.IsValid=function() return true end; return t
end
local actors={}
local world=obj()
local fail_mesh=false
function world:SpawnActor(class,_,rotation)
    local actor=obj({class=class,rotation=rotation})
    local component=obj()
    function actor:SetActorEnableCollision(v) assert(v==false); self.no_collision=true end
    function actor:SetActorHiddenInGame(v) self.hidden=v end
    function actor:SetLifeSpan(v) assert(v>0) end
    function actor:SetMobility(v) assert(v==2) end
    function actor:GetComponentByClass() return component end
    function actor:SetActorScale3D(v) self.scale=v end
    function actor:K2_SetActorLocation(v,sweep,_,teleport) assert(not sweep and teleport); self.at=v end
    function actor:K2_SetActorRotation(v) self.rotation=v end
    function actor:K2_DestroyActor() self.destroyed=true end
    function component:SetDecalMaterial(v) actor.decal_material=v end
    actor.component=component
    function component:SetCollisionEnabled(v) assert(v==0) end
    function component:SetStaticMesh() return not fail_mesh end
    function component:SetMaterial() end
    function component:CreateDynamicMaterialInstance()
        local mid=obj()
        function mid:K2_GetVectorParameterValue() return {R=1,G=1,B=1} end
        function mid:SetVectorParameterValue(_,v) actor.tint=v end
        return mid
    end
    function component:SetMobility(v) assert(v==2) end
    function component:SetHorizontalAlignment() end
    function component:SetWorldSize() end
    function component:SetText(v) actor.text=v end
    function component:SetTextRenderColor(v) actor.color=v end
    actors[#actors+1]=actor
    return actor
end
package.loaded.UEHelpers={GetWorld=function() return world end,GetPlayerController=function()
    return {PlayerCameraManager=obj({GetCameraRotation=function() return {Pitch=-60,Yaw=45} end})}
end}
StaticFindObject=function(path) return obj({path=path}) end
FText=function(s) return s end
FName=function(s) return s end
local module=require('pond_ghost')
local row={customBorder={{X=-100,Y=-200},{X=100,Y=-200},{X=100,Y=200},{X=-100,Y=200}}}
local relaxed_lines,rw,rd=module.outline(row)
assert(#relaxed_lines==4 and rw==2 and rd==4)
local lines,w,d=module.outline(row,true)
assert(#lines==8 and w==4 and d==6)
assert(lines[1].length==200 and lines[1].y==-200 and not lines[1].clearance)
assert(lines[5].length==400 and lines[5].y==-300 and lines[5].clearance)
assert(not pcall(module.outline,{customBorder={{X=0,Y=0}}}))
assert(not pcall(module.outline,{customBorder={{X=0/0,Y=0},{X=1,Y=0},{X=0,Y=1}}}))
local ghost=module.new({},row,true)
assert(#actors==9)
for _,actor in ipairs(actors) do assert(actor.no_collision and actor.hidden and not actor.destroyed) end
ghost.show({X=1000,Y=2000,Z=300},true,'ready',false)
assert(actors[1].at.X==1000 and actors[1].at.Y==1800 and actors[1].at.Z>300)
assert(actors[1].tint.G==1 and actors[9].color.G==255 and actors[9].text:find('READY',1,true))
ghost.show({X=2000,Y=3000,Z=300},false,'ERROR Pond footprint blocked',false)
assert(actors[1].tint.R==1 and actors[9].color.R==255 and actors[9].text:find('BLOCKED',1,true))
assert(actors[9].rotation.Pitch==60 and actors[9].rotation.Yaw==225)
ghost.hide(); for _,actor in ipairs(actors) do assert(actor.hidden) end
ghost.destroy(); for _,actor in ipairs(actors) do assert(actor.destroyed) end
-- A partial renderer initialization failure must destroy every allocated visual.
actors={}; fail_mesh=true
assert(not pcall(module.new,{},row))
assert(#actors==1 and actors[1].destroyed)
print('Pond outline matches polygon/clearance, displays colour status, never collides and cleans partial setup')

-- Deposit preview uses a plain native-material decal, centre mark and mining outline.
actors={}; fail_mesh=false
local native_material=obj()
local deposit_ghost=module.new({},row,false,{title='IRON DEPOSIT',detail='20m mining radius',
    material=native_material,decal_radius=2000,centre_mark=true})
assert(#actors==8) -- 4 outline segments, two crosshair segments, plain decal and label.
local decal=actors[7]
assert(decal.class.path=='/Script/Engine.DecalActor' and decal.rotation.Pitch==-90)
assert(decal.component.DecalSize.X==25000 and decal.component.DecalSize.Y==4000)
assert(decal.decal_material==native_material and decal.no_collision)
deposit_ghost.show({X=9876,Y=5432,Z=50},true,'ready',false)
assert(decal.at.X==9876 and decal.at.Y==5432 and not decal.hidden)
assert(actors[8].text:find('IRON DEPOSIT',1,true) and actors[8].text:find('20m mining radius',1,true))
deposit_ghost.destroy(); for _,actor in ipairs(actors) do assert(actor.destroyed) end
print('Deposit ghost uses native material without real reserve actors; exact centre, radius and cleanup pass')
