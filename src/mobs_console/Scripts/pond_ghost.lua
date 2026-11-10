-- Copyright 2026 Mobs. MIT licensed. Transient outline actors, never registered game buildings.
local access=require('game_access')
local valid=access.valid
local M={}
local function asset(path)
    local object=StaticFindObject(path)
    if not valid(object) then LoadAsset(path); object=StaticFindObject(path) end
    assert(valid(object),'Pond preview asset unavailable: ' .. path)
    return object
end
local function clean_reason(message)
    return message:gsub('^.-ERROR%s*',''):gsub('^.-%.lua:%d+:%s*',''):gsub('[\r\n].*',''):sub(1,110)
end
function M.outline(row,strict)
    local points={}
    local border=row.customBorder
    assert(border and #border>=3 and #border<=256,'Pond preview border unavailable')
    local ex,ey=0,0
    local min_x,min_y,max_x,max_y=math.huge,math.huge,-math.huge,-math.huge
    for i=1,#border do
        local x,y=border[i].X,border[i].Y
        assert(type(x)=='number' and type(y)=='number' and x==x and y==y
            and math.abs(x)<16000 and math.abs(y)<16000,'Invalid pond preview border')
        points[#points+1]={X=x,Y=y}
        ex=math.max(ex,math.abs(x)); ey=math.max(ey,math.abs(y))
        min_x=math.min(min_x,x); min_y=math.min(min_y,y)
        max_x=math.max(max_x,x); max_y=math.max(max_y,y)
    end
    -- Only strict placement checks the symmetric rectangle with a 1m margin.
    -- Relaxed placement checks the actual polygon; do not show empty corners as required land.
    ex,ey=ex+100,ey+100
    local lines={}
    local function line(a,b,clearance)
        local dx,dy=b.X-a.X,b.Y-a.Y
        local length=math.sqrt(dx*dx+dy*dy)
        if length>1 then
            lines[#lines+1]={x=(a.X+b.X)/2,y=(a.Y+b.Y)/2,
                yaw=math.deg(math.atan(dy,dx)),length=length,clearance=clearance}
        end
    end
    for i=1,#points do line(points[i],points[i%#points+1],false) end
    if strict then
        local corners={{X=-ex,Y=-ey},{X=ex,Y=-ey},{X=ex,Y=ey},{X=-ex,Y=ey}}
        for i=1,4 do line(corners[i],corners[i%4+1],true) end
        return lines,ex*2/100,ey*2/100
    end
    return lines,(max_x-min_x)/100,(max_y-min_y)/100
end
function M.new(pawn,row,strict,options)
    options=options or {}
    local lines,width,depth=M.outline(row,strict)
    if options.centre_mark then
        lines[#lines+1]={x=0,y=0,yaw=0,length=240}
        lines[#lines+1]={x=0,y=0,yaw=90,length=240}
    end
    local helpers=require('UEHelpers')
    local world=helpers.GetWorld()
    assert(valid(world),'World unavailable for pond preview')
    local mesh_class=asset('/Script/Engine.StaticMeshActor')
    local text_class=asset('/Script/Engine.TextRenderActor')
    local mesh_component=asset('/Script/Engine.StaticMeshComponent')
    local text_component=asset('/Script/Engine.TextRenderComponent')
    local cube=asset('/Engine/BasicShapes/Cube.Cube')
    local material=asset('/Engine/BasicShapes/BasicShapeMaterial.BasicShapeMaterial')
    local actors,meshes={},{}
    local label,label_component,decal
    local color_name=FName('Color')
    local self={}
    function self.destroy()
        for _,actor in ipairs(actors) do
            if valid(actor) then pcall(function() actor:K2_DestroyActor() end) end
        end
        actors={}; meshes={}; label=nil; label_component=nil; decal=nil
    end
    local function spawn(class,rotation)
        local actor=world:SpawnActor(class,{X=0,Y=0,Z=0},rotation or {Pitch=0,Yaw=0,Roll=0})
        assert(valid(actor),'Cannot create pond preview visual')
        actors[#actors+1]=actor
        actor:SetActorEnableCollision(false)
        actor:SetActorHiddenInGame(true)
        actor:SetLifeSpan(30)
        return actor
    end
    local ok,message=pcall(function()
        for _,line in ipairs(lines) do
            local actor=spawn(mesh_class,{Pitch=0,Yaw=line.yaw,Roll=0})
            actor:SetMobility(2)
            local component=actor:GetComponentByClass(mesh_component)
            assert(valid(component),'Pond outline mesh component unavailable')
            component:SetCollisionEnabled(0)
            assert(component:SetStaticMesh(cube),'Cannot set pond outline mesh')
            component:SetMaterial(0,material)
            -- Probe a real parameter default before relying on it. Some cooked engine
            -- materials expose no tint parameter; the coloured text remains authoritative.
            local tint
            local tint_ok,result=pcall(function()
                local mid=component:CreateDynamicMaterialInstance(0,material,FName('None'))
                if not valid(mid) then return nil end
                local default=mid:K2_GetVectorParameterValue(color_name)
                if default.R~=0 or default.G~=0 or default.B~=0 then return mid end
            end)
            if tint_ok then tint=result end
            actor:SetActorScale3D({X=line.length/100,Y=line.clearance and 0.12 or 0.22,Z=0.08})
            meshes[#meshes+1]={actor=actor,line=line,tint=tint}
        end
        if options.decal_radius and valid(options.material) then
            -- A plain DecalActor previews the game's native ground material. Never
            -- spawn a DepositDecal here: those carry real reserves and save state.
            decal=spawn(asset('/Script/Engine.DecalActor'),{Pitch=-90,Yaw=0,Roll=0})
            local component=decal:GetComponentByClass(asset('/Script/Engine.DecalComponent'))
            assert(valid(component),'Native deposit preview decal unavailable')
            component:SetMobility(2)
            component.DecalSize={X=25000,Y=options.decal_radius*2,Z=options.decal_radius*2}
            component:SetDecalMaterial(options.material)
        end
        label=spawn(text_class)
        label_component=label:GetComponentByClass(text_component)
        assert(valid(label_component),'Pond preview label unavailable')
        label_component:SetMobility(2)
        label_component:SetHorizontalAlignment(1)
        label_component:SetWorldSize(180)
        label_component:SetText(FText((options.title or 'POND') .. ' PREVIEW'))
    end)
    if not ok then self.destroy(); error(message) end
    function self.hide()
        for _,actor in ipairs(actors) do
            if valid(actor) then actor:SetActorHiddenInGame(true); actor:SetLifeSpan(30) end
        end
    end
    function self.show(at,allowed,reason,preview)
        local color=allowed and {R=45,G=255,B=90,A=255} or {R=255,G=65,B=45,A=255}
        for _,entry in ipairs(meshes) do
            local actor,line=entry.actor,entry.line
            assert(valid(actor),'Pond preview expired; arm it again')
            -- Lift the outline above the terrain at the cursor. It represents the
            -- native footprint and clearance, not the final water/terrain deformation.
            actor:K2_SetActorLocation({X=at.X+line.x,Y=at.Y+line.y,Z=at.Z+45},false,{},true)
            actor:SetActorHiddenInGame(false)
            actor:SetLifeSpan(30)
            if entry.tint then
                entry.tint:SetVectorParameterValue(color_name,
                    {R=allowed and 0.04 or 1,G=allowed and 1 or 0.04,B=0.04,A=1})
            end
        end
        if decal then
            assert(valid(decal),'Deposit preview expired; arm it again')
            decal:K2_SetActorLocation(at,false,{},true)
            decal:SetActorHiddenInGame(false)
            decal:SetLifeSpan(30)
        end
        assert(valid(label),'Placement preview label expired; arm it again')
        label:K2_SetActorLocation({X=at.X,Y=at.Y,Z=at.Z+600},false,{},true)
        local camera=helpers.GetPlayerController().PlayerCameraManager
        if valid(camera) then
            local rotation=camera:GetCameraRotation()
            label:K2_SetActorRotation({Pitch=-rotation.Pitch,Yaw=rotation.Yaw+180,Roll=0},true)
        end
        label_component:SetTextRenderColor(color)
        local caption=allowed and (preview and 'READY - preview only' or 'READY - left-click to place')
            or ('BLOCKED - ' .. clean_reason(reason))
        local heading=options.title and (options.title .. '\n' .. (options.detail or ''))
            or string.format('POND %.0f x %.0f m - %s',width,depth,strict and 'STRICT' or 'RELAXED')
        label_component:SetText(FText(heading .. '\n' .. caption .. '\nRight-click to cancel'))
        label:SetActorHiddenInGame(false)
        label:SetLifeSpan(30)
    end
    return self
end
return M
