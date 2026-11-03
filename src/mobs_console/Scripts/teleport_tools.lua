-- Copyright 2026 Mobs. MIT licensed. Experimental native-unit relocation.
local access=require('game_access')
local valid,same=access.valid,access.same
local M={}
function M.register(register,get_pawn,arm)
    register('mobs.teleport','mobs.teleport <unit|squads> [preview]',function(args)
        local args,preview=access.preview(args)
        assert(#args==1 and (args[1]=='unit' or args[1]=='squads'),'Usage: mobs.teleport <unit|squads> [preview]')
        local pawn=get_pawn()
        local targets,seen={},{}
        local function add(unit)
            assert(valid(unit) and not unit.dead and same(unit.masterPtr,pawn.masterPtr),'Invalid unit or another world')
            if not seen[unit:GetAddress()] then
                targets[#targets+1]=unit; seen[unit:GetAddress()]=true
            end
        end
        local function own_unit(unit)
            return valid(unit.Home) and valid(unit.Home.Region) and same(unit.Home.Region.ownerPawn,pawn)
        end
        if args[1]=='unit' then
            local unit=pawn.hoverUnit
            if not valid(unit) and pawn.followMode then unit=pawn.following end
            assert(valid(unit) and own_unit(unit),'Hover/follow a living unit with an owned home')
            add(unit)
        else
            local squads=pawn.selectedSquads
            assert(#squads>0 and #squads<=12,'Select between 1 and 12 of your squads')
            for i=1,#squads do
                local handle=squads[i]
                assert(same(pawn:getSquadOwner(handle),pawn),'Select only squads owned by your lord')
                local units=pawn:GetSquadUnits(handle)
                for j=1,#units do add(units[j]) end
            end
        end
        assert(#targets>0 and #targets<=1000,'No living targets, or more than 1000 units')
        local mode=args[1]
        return arm('Teleport',function(current,engine,region,at)
            assert(same(current,pawn),'Settlement changed')
            local plans,center={}, {X=0,Y=0,Z=0}
            for _,unit in ipairs(targets) do
                assert(valid(unit) and not unit.dead and same(unit.masterPtr,engine),'Unit disappeared; nothing changed')
                assert(mode=='unit' and own_unit(unit) or mode=='squads' and same(pawn:getSquadOwner(unit.assignedSquadID),pawn),
                    'Unit ownership changed; nothing changed')
                local from=access.vector(unit.realPos)
                plans[#plans+1]={unit=unit,from=from}
                center.X=center.X+from.X; center.Y=center.Y+from.Y
            end
            center.X=center.X/#plans; center.Y=center.Y/#plans
            for _,plan in ipairs(plans) do
                plan.at={X=at.X+plan.from.X-center.X,Y=at.Y+plan.from.Y-center.Y,Z=at.Z}
                assert(same(engine:getRegionByPos(plan.at,false),region),'Formation crosses region boundary; nothing changed')
            end
            if preview then return 'Preview: teleport ' .. #plans .. ' unit(s), preserving relative formation; nothing changed.' end
            local moved=0
            for _,plan in ipairs(plans) do
                local unit=plan.unit
                local rotation=unit:K2_GetActorRotation()
                assert(unit:K2_TeleportTo(plan.at,rotation),'Native teleport refused; earlier unit moves remain')
                -- Simulation and interpolation positions must follow the actor move.
                unit.realPos=plan.at
                unit.lastInstacePosition=plan.at
                unit.prevToLastInstacePosition=plan.at
                unit:updateCurrentRegion(false)
                moved=moved+1
            end
            return 'Teleported ' .. moved .. ' unit(s). Experimental; existing movement orders remain active; no undo.'
        end,false)
    end,'Click to relocate an owned unit or selected squads, preserving formation offsets; preview supported; existing orders remain active.')
end
return M
