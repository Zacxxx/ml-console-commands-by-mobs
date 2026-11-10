-- Copyright 2026 Mobs. MIT licensed. Native pond placement and existing game UI action.
local access=require('game_access')
local valid,same,text=access.valid,access.same,access.text
local M={}
function M.register(register,get_pawn,arm,cancel_tools,api)
    api=api or {preview=require('pond_preview').new(get_pawn,function(message)
        print('[MobsConsole] ' .. message .. '\n')
        pcall(function() require('UEHelpers').GetPlayerController():ClientMessage('[Mobs] ' .. message,FName('None'),8.0) end)
    end)}
    register('mobs.pond','mobs.pond <place|remove> [strict] [preview]',function(args)
        local args,preview=access.preview(args)
        local strict=args[2]=='strict'
        assert((#args==1 or (#args==2 and args[1]=='place' and strict)) and (args[1]=='place' or args[1]=='remove'),
            'Usage: mobs.pond place [strict] [preview] | mobs.pond remove [preview]')
        local pawn=get_pawn()
        assert(require('UEHelpers').GetGameInstance():GetAppVersion():ToString()=='Version 0.8.117','Pond tools support game 0.8.117')
        if args[1]=='place' then
            local stats=StaticFindObject('/Game/NotStronghold/Data/buildingStats.buildingStats')
            assert(valid(stats),'Building data not loaded')
            local row=stats:FindRow('39')
            assert(row and text(row.DisplayName):lower():find('pond',1,true),'Fishing Pond definition differs; placement refused')
            cancel_tools()
            return api.preview.start(pawn,row,preview,strict)
        end
        return arm('Pond removal',function(current,_,region,at)
            local nearest,distance=nil,1500*1500
            for _,building in ipairs(FindAllOf('SMBuildingMaster') or {}) do
                if valid(building) and building:GetType()==39 and same(building.Region,region) then
                    local pos=access.vector(building:K2_GetActorLocation())
                    local d=(pos.X-at.X)^2+(pos.Y-at.Y)^2
                    if d<distance then nearest,distance=building,d end
                end
            end
            assert(valid(nearest) and same(region.ownerPawn,current),'No owned Fishing Pond near click (within 15 metres)')
            if preview then return 'Preview: remove the nearest owned Fishing Pond; nothing changed.' end
            nearest:demolish(false)
            return 'Native Fishing Pond demolition requested; no refund or undo.'
        end)
    end,'Preview the pond footprint and clearance with a moving READY/BLOCKED label, then click to create a completed empty pond; right-click cancels. Stock with pond_fish. Relaxed by default: actual outline, 10m height spread and neighbouring owned land; strict restores the old rectangle/2m rule. Read-only preview and owned pond removal supported.')

    register('mobs.boop','mobs.boop [on|off|status]',function(args)
        assert(#args<=1 and (not args[1] or args[1]=='on' or args[1]=='off' or args[1]=='status'),
            'Usage: mobs.boop [on|off|status]')
        local pawn=get_pawn()
        assert(require('UEHelpers').GetGameInstance():GetAppVersion():ToString()=='Version 0.8.117','Boop supports game 0.8.117')
        local before=pawn.debugBoopMode
        assert(type(before)=='boolean','Game debug Boop setting unavailable')
        if args[1]=='status' then return 'Game debug Boop mode: ' .. (before and 'on' or 'off') end
        local wanted=not before
        if args[1] then wanted=args[1]=='on' end
        pawn.debugBoopMode=wanted
        pawn:updateBoopMode()
        assert(pawn.debugBoopMode==wanted,'Game did not retain the requested debug mode')
        return 'Game debug Boop mode: ' .. (wanted and 'on' or 'off') .. '. Native game behavior; use mobs.boop off to leave.'
    end,'Toggle the game debug Boop mode, explicitly enable/disable it or read status; uses the native pawn setting and refresh.')
    return api.preview
end
return M
