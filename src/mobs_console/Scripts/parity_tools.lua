-- Copyright 2026 Mobs. MIT licensed. Independent counterparts using game 0.8.117 interfaces.
local core = require('core')
local access = require('game_access')
local valid, same, text = access.valid, access.same, access.text
local M = {}
local ANIMALS = {deer=8,chicken=9,sheep=10,lamb=11,ox=12,goat=13,hound=14,
    horse=15,mule=16,pig=19,hare=20,cow=21,calf=22}

function M.new(get_pawn, get_region, region_label, notify, api)
    api = api or {
        bind=function(callback) RegisterKeyBind(Key.LEFT_MOUSE_BUTTON, callback) end,
        defer=function(callback) ExecuteWithDelay(150, function() ExecuteInGameThread(callback) end) end,
        version=function() return require('UEHelpers').GetGameInstance():GetAppVersion():ToString() end,
        find=function(class) return FindAllOf(class) or {} end,
        instant_defer=function(callback) ExecuteWithDelay(1000,function() ExecuteInGameThread(callback) end) end,
    }
    local pending
    local self = {}
    function self.cancel()
        local had = pending~=nil
        pending=nil
        return had
    end
    function self.reset() pending=nil end
    local function context()
        assert(api.version()=='Version 0.8.117', 'These tools currently support only game 0.8.117')
        local pawn=get_pawn()
        assert(valid(pawn.masterPtr), 'Settlement simulation unavailable')
        return pawn,pawn.masterPtr
    end
    local function selected(pawn)
        return access.selected(pawn)
    end
    local function arm(label, callback, owned)
        local pawn=context()
        assert(not pawn.mapViewMode and not pawn:isInAnyConstructionMode(), 'Exit map and building placement first')
        if self.before_arm then self.before_arm() end
        if api.on_arm then api.on_arm() end
        pending={pawn=pawn, callback=callback, label=label, expires=os.time()+300, owned=owned~=false}
        return label .. ' armed. Close the console and click ground once; mobs.cancel cancels. Expires in five minutes.'
    end
    self.arm=arm
    api.bind(function()
        local request=pending
        if not request then return end
        api.defer(function()
            if pending~=request then return end
            local ok,message=pcall(function()
                if os.time()>=request.expires then pending=nil; return request.label .. ' expired.' end
                local pawn,engine=context()
                assert(same(pawn,request.pawn), 'Settlement changed; arm the tool again')
                if pawn.isUsingUI or pawn.bFullscreenUIActive then return end
                assert(not pawn.mapViewMode and not pawn:isInAnyConstructionMode(), 'Exit map and building placement first')
                local at=access.vector(pawn:getMouse3d())
                local region=engine:getRegionByPos(at,false)
                assert(valid(region), 'Click inside a playable region')
                if request.owned then assert(same(region.ownerPawn,pawn), 'Click inside a region owned by your lord') end
                -- A failed preflight leaves the tool armed; a native operation consumes it once.
                pending=nil
                return request.callback(pawn,engine,region,at)
            end)
            if not ok then notify(request.label .. ': ' .. tostring(message))
            elseif message then notify(message) end
        end)
    end)

    function self.register(register)
        register('mobs.weather', 'mobs.weather <rain|drought|clear|end_rain|end_drought> [instant] [damaging] [preview]', function(args)
            local args,preview=access.preview(args)
            local mode=args[1]
            assert(mode=='rain' or mode=='drought' or mode=='clear' or mode=='end_rain' or mode=='end_drought',
                'Choose rain, drought, clear, end_rain or end_drought')
            local instant,damaging=false,false
            for i=2,#args do
                if args[i]=='instant' then assert(not instant,'Repeated instant'); instant=true
                elseif args[i]=='damaging' then assert(mode=='rain' and not damaging,'damaging applies only to rain'); damaging=true
                else error('Unexpected weather argument: ' .. args[i]) end
            end
            local _,engine=context()
            local weather=engine.TemporalComponent
            assert(valid(weather), 'Weather component unavailable')
            if preview then return 'Preview: ' .. mode .. (instant and ' instantly' or ' with a normal transition') .. '; nothing changed.' end
            if mode=='rain' then
                weather.isDrought=false
                weather.targetRaining=1
                weather.targetCloudiness=1
                weather.rainMeter=3
                weather.damagingRain=damaging
                if instant then weather.raining=1; weather.cloudiness=1; weather.droughtLevel=0 end
            elseif mode=='drought' then
                weather.isDrought=true
                weather.targetRaining=0
                weather.targetSnowing=0
                weather.targetCloudiness=0
                weather.damagingRain=false
                if instant then weather.raining=0; weather.snowing=0; weather.cloudiness=0; weather.droughtLevel=1 end
            else
                if mode~='end_drought' then
                    weather.targetRaining=0; weather.targetCloudiness=0; weather.damagingRain=false
                    if instant then weather.raining=0; weather.cloudiness=0 end
                end
                if mode~='end_rain' then
                    weather.isDrought=false
                    if instant then weather.droughtLevel=0 end
                end
            end
            return 'Weather requested: ' .. mode .. (instant and ' (instant).' or ' (normal transition).')
                .. ' The simulation may later choose new weather; no undo.'
        end, 'Start/end rain or drought; optional immediate transition and damaging rain. Supports preview.')

        register('mobs.skip_day', 'mobs.skip_day [1..30] [preview]', function(args)
            local args,preview=access.preview(args)
            assert(#args<=1, 'Usage: mobs.skip_day [1..30] [preview]')
            local count=core.integer(args[1] or 1,1,30)
            local _,engine=context()
            local weather=engine.TemporalComponent
            assert(valid(weather),'Weather component unavailable')
            if preview then return 'Preview: advance ' .. count .. ' day(s); nothing changed.' end
            local before=weather.daysTotal
            for _=1,count do engine:setDay(weather.day+1) end
            return string.format('Native date update requested %d time(s): total days %d -> %d. Daily events may run; no undo.',
                count,before,weather.daysTotal)
        end, 'Advance days through the native date update rather than overwrite the calendar; maximum 30, preview available.')

        register('mobs.demolish', 'mobs.demolish selected [preview]', function(args)
            local args,preview=access.preview(args)
            assert(#args==1 and args[1]=='selected','Usage: mobs.demolish selected [preview]')
            local pawn=context()
            local targets=selected(pawn)
            for _,building in ipairs(targets) do
                assert(building:canBeDemolished(), 'A selected building cannot be demolished; nothing changed')
            end
            if preview then return 'Preview: demolish ' .. #targets .. ' selected owned building(s), using native refunds; nothing changed.' end
            local requested=0
            for _,building in ipairs(targets) do
                if valid(building) then
                    assert(valid(building.Region) and same(building.Region.ownerPawn,pawn), 'Ownership changed; demolition stopped')
                    building:demolish(true)
                    requested=requested+1
                end
            end
            return 'Native demolition requested for ' .. requested .. ' building(s); native refund rules apply. No undo.'
        end, 'Demolish selected owned buildings through the game with normal refund rules; preflight all targets and support preview.')

        register('mobs.claim', 'mobs.claim <start|finish> [region-id|all] [preview]', function(args)
            local args,preview=access.preview(args)
            assert(#args>=1 and #args<=2 and (args[1]=='start' or args[1]=='finish'),
                'Usage: mobs.claim <start|finish> [region-id|all] [preview]')
            local pawn,engine=context()
            local targets={}
            local active={}
            local claims=pawn.claims
            for i=1,#claims do
                if valid(claims[i].Region) then active[#active+1]=claims[i].Region end
            end
            if args[2]=='all' then
                assert(args[1]=='finish', 'all only finishes your existing claims')
                for i=1,#active do targets[#targets+1]=active[i] end
            else
                local region=args[2] and engine:findRegionByID(core.integer(args[2],0,2147483647)) or pawn.selectedRegion
                assert(valid(region), 'Select a region on the map or provide its ID; mobs.map_regions lists IDs')
                targets={region}
            end
            local seen,plans={},{}
            for _,region in ipairs(targets) do
                assert(valid(region),'Invalid claim target')
                if not same(region.ownerPawn,pawn) and not seen[region:GetAddress()] then
                    local found=false
                    for i=1,#active do if same(active[i],region) then found=true end end
                    if args[1]=='finish' then
                        assert(found,'You have no active claim on ' .. text(region.regionName) .. '; use mobs.claim start first')
                    else
                        assert(not found,'You already have an active claim on ' .. text(region.regionName))
                    end
                    seen[region:GetAddress()]=true; plans[#plans+1]=region
                end
            end
            if preview then return 'Preview: ' .. args[1] .. ' ' .. #plans .. ' claim(s); nothing changed.' end
            local completed=0
            for _,region in ipairs(plans) do
                if args[1]=='start' then pawn:layClaim(region,false,false)
                else pawn:finalizeClaim(region,true) end
                completed=completed+1
            end
            return 'Requested ' .. args[1] .. ' for ' .. completed .. ' claim(s); start consumes no influence. Native rules still apply; no undo.'
        end, 'Start a claim without influence cost, or finish your existing claim(s); explicit map selection/ID, supports preview.')

        register('mobs.map_regions', 'mobs.map_regions', function(args)
            assert(#args==0,'Usage: mobs.map_regions')
            local pawn=context()
            local lines={'All map regions (claims use map selection or explicit ID):'}
            for _,region in ipairs(api.find('Region')) do
                if valid(region) then lines[#lines+1]=region_label(region) .. (same(region.ownerPawn,pawn) and ' [owned]' or ' [other/unclaimed]') end
            end
            return table.concat(lines,'\n')
        end, 'List map region IDs including unclaimed/foreign regions for claim commands.')

        register('mobs.animal', 'mobs.animal <type> [1..20] [preview]', function(args)
            local args,preview=access.preview(args)
            assert(#args>=1 and #args<=2,'Usage: mobs.animal <type> [1..20] [preview]')
            local role=ANIMALS[args[1]:lower()]
            assert(role,'Choose deer, chicken, sheep, lamb, ox, goat, hound, horse, mule, pig, hare, cow or calf')
            local count=core.integer(args[2] or 1,1,20)
            return arm('Animal placement', function(_,engine,region,at)
                if preview then return 'Preview: place ' .. count .. ' ' .. args[1] .. ' in ' .. region_label(region) .. '; nothing changed.' end
                local completed=0
                for i=1,count do
                    local pos={X=at.X+(i-1)%5*100,Y=at.Y+math.floor((i-1)/5)*100,Z=at.Z}
                    assert(same(engine:getRegionByPos(pos,false),region),'Animal spread crosses a region boundary; stopped')
                    local animal=engine:SpawnLivestock(role,pos,region)
                    assert(valid(animal),'Native animal creation failed; previous spawns remain')
                    completed=completed+1
                end
                return 'Created ' .. completed .. ' ' .. args[1] .. '. Native housing/pasture rules apply; no undo.'
            end)
        end, 'Click inside an owned region to spawn 1..20 animals using native livestock registration; preview available.')

        register('mobs.rehouse', 'mobs.rehouse selected [preview]', function(args)
            local args,preview=access.preview(args)
            assert(#args==1 and args[1]=='selected','Usage: mobs.rehouse selected [preview]')
            local pawn=context()
            local targets=selected(pawn)
            assert(#targets==1,'Select one destination house')
            local home=targets[1]
            assert(home:IsConstructed() and home:isResidentialBuilding(),'Select a completed residential building')
            local unit=pawn.hoverUnit
            if not valid(unit) and pawn.followMode then unit=pawn.following end
            assert(valid(unit) and not unit.dead and valid(unit.Home) and same(unit.Home.Region,home.Region),
                'Hover/follow a living family member with a home in the destination region')
            local id=core.integer(unit.workerFamilyID,0,2147483647)
            if same(unit.Home,home) then return 'Family already lives here; nothing changed.' end
            assert(home:getNumResidingFamilies()<home:getMaxResidingFamilies(),'Destination has no free family space')
            if preview then return 'Preview: move family ' .. id .. ' to the selected house; nothing changed.' end
            home.Region:SetFamilyHome(id,home,false)
            assert(same(unit.Home,home),'Game did not update the hovered family member home')
            return 'Moved family ' .. id .. ' to the selected house; no undo.'
        end, 'Move a hovered/followed family to one selected completed house in the same owned region; checks capacity, supports preview.')

        register('mobs.bandits', 'mobs.bandits [preview]', function(args)
            local args,preview=access.preview(args)
            assert(#args==0,'Usage: mobs.bandits [preview]')
            local _,engine=context()
            if preview then return 'Preview: request a native bandit camp at a game-chosen valid location; nothing changed.' end
            engine:spawnBanditCamp()
            return 'Native bandit camp spawn requested; the game chooses location and may refuse if no valid site. No undo.'
        end, 'Ask the game to spawn a bandit camp at a valid random location; supports preview.')

        register('mobs.raiders', 'mobs.raiders [1..6] [preview]', function(args)
            local args,preview=access.preview(args)
            assert(#args<=1,'Usage: mobs.raiders [1..6] [preview]')
            local count=core.integer(args[1] or 1,1,6)
            return arm('Raider placement',function(_,engine,_,at)
                if preview then return 'Preview: request ' .. count .. ' raider squad(s) at this location; nothing changed.' end
                engine:spawnRaiders(count,at)
                return 'Native raider spawn requested for ' .. count .. ' squad(s); hostile units, no undo.'
            end,false)
        end, 'Click a playable region to request native hostile raider squads; maximum six, supports preview.')


    end
    return self
end
return M
