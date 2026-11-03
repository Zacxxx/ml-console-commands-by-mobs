-- Copyright 2026 Mobs. MIT licensed. Original implementation.
local M = {}
local function valid(object)
    local ok, result = pcall(function() return object and object:IsValid() end)
    return ok and result
end
local function same(a, b)
    return valid(a) and valid(b) and a:GetAddress() == b:GetAddress()
end
local function text(value)
    return type(value) == "string" and value or value:ToString()
end
local directory = debug.getinfo(1,"S").source:gsub("^@", ""):gsub("\\", "/"):match("^(.*)/Scripts/")
local bridge
local function native(region, pawn, mode, preview, component, at, cursor, area)
    assert(require("UEHelpers").GetGameInstance():GetAppVersion():ToString() == "Version 0.8.117",
        "Forestry supports only game 0.8.117")
    assert(directory, "Cannot locate forestry adapter")
    local folder = directory .. "/Native/"
    if not bridge then
        local manifest = assert(io.open(folder .. "bridge_name.txt", "r"), "Forestry adapter is missing")
        local name = manifest:read("*l"); manifest:close()
        assert(name and name:match("^mobs_forestry_%x+%.dll$"), "Invalid forestry adapter manifest")
        bridge = assert(package.loadlib(folder .. name, "mobs_forestry_run"))
    end
    at = at or {X=0,Y=0,Z=0}
    local request = assert(io.open(folder .. "forestry.request", "w"))
    request:write(string.format("MOBS_FORESTRY_1 %d %d %d %d %d %.17g %.17g %.17g %d\n",
        mode, preview and 1 or 0, region:GetAddress(), pawn:GetAddress(),
        component and component:GetAddress() or 0, at.X, at.Y, at.Z, cursor or 0))
    if area then request:write(string.format('%.17g %.17g %.17g\n',area.X,area.Y,area.radius)) end
    request:close()
    os.remove(folder .. "forestry.response")
    bridge()
    local response = assert(io.open(folder .. "forestry.response", "r"), "Forestry adapter did not respond")
    local result = response:read("*a"); response:close()
    os.remove(folder .. "forestry.request"); os.remove(folder .. "forestry.response")
    local before, planted, remaining, eligible, steps, enrolled, completed, blocked, next_index =
        result:match("^OK (%d+) (%d+) (%d+) (%d+) (%d+) (%d+) (%d+) (%d+) (%d+)\n$")
    assert(before, result:gsub("%s+$", ""))
    return {before=tonumber(before), planted=tonumber(planted), remaining=tonumber(remaining),
        eligible=tonumber(eligible), steps=tonumber(steps), enrolled=tonumber(enrolled),
        completed=tonumber(completed), blocked=tonumber(blocked), cursor=tonumber(next_index)}
end
function M.new(get_pawn, get_region, region_label, notify, api)
    api = api or {run=native,
        bind=function(callback) RegisterKeyBind(Key.LEFT_MOUSE_BUTTON, callback) end,
        defer=function(callback) ExecuteWithDelay(150, function() ExecuteInGameThread(callback) end) end}
    local pending, growth_job
    local self = {}
    function self.reset() pending=nil; growth_job=nil end
    function self.cancel()
        if not pending and not growth_job then return false end
        pending=nil; growth_job=nil
        return true
    end
    local function region_context()
        local pawn, region=get_pawn(), get_region(true)
        assert(valid(region) and same(region.ownerPawn,pawn), "Choose a region owned by your lord")
        return pawn, region
    end
    local function summary(result, preview)
        if preview then
            return string.format("%d registered growing trees; %d untracked young trees eligible. Planting location %s. Preview changed nothing.",
                result.before, result.enrolled, result.eligible==1 and "eligible" or "not requested/blocked")
        end
        return string.format("Planted %d sapling(s); processed %d growth records (%d newly registered); %d remain. "
            .. "Native growth updates=%d.%s Not undoable.", result.planted, result.completed, result.enrolled,
            result.remaining, result.steps, result.remaining>0 and " Remaining records could not finish or were blocked." or "")
    end
    local function parse(args, name)
        assert(#args<=1 and (not args[1] or args[1]=="preview"), "Usage: " .. name .. " [preview]")
        return args[1]=="preview"
    end
    local function begin_growth(pawn, region, mode, preview, component, at, area)
        assert(not growth_job or preview, "Tree growth is already running; mobs.cancel stops further batches")
        local first=api.run(region,pawn,mode,preview,component,at,nil,area)
        if preview or mode==1 then
            if mode>=4 then return region_label(region) .. ': Preview: ' .. first.eligible .. ' registered trees in scope; nothing changed.' end
            return region_label(region) .. ": " .. summary(first,preview)
        end
        pending=nil
        local job={pawn=pawn,region=region,result=first,cursor=first.cursor,area=area,mode=mode>=4 and mode or 3}
        growth_job=job
        local function continue_growth()
            if growth_job~=job then return end
            local ok,err=pcall(function()
                local current=get_pawn()
                assert(same(current,job.pawn) and same(job.region.ownerPawn,current),
                    "Settlement or ownership changed; growth stopped")
                local result=api.run(job.region,current,job.mode,false,nil,nil,job.cursor,job.area)
                for _,field in ipairs({"steps","completed","blocked"}) do
                    job.result[field]=job.result[field]+result[field]
                end
                job.result.remaining=result.remaining
                job.cursor=result.cursor
                if job.cursor<result.remaining then
                    assert(result.steps>0,"Tree growth made no progress; stopped")
                    api.defer(continue_growth)
                else
                    growth_job=nil
                    notify(region_label(job.region) .. ": " .. summary(job.result,false)
                        .. (mode>=4 and ' Work-area/stage mode may leave growing trees intentionally.' or ''))
                end
            end)
            if not ok then
                growth_job=nil
                notify("Forestry stopped: " .. tostring(err) .. ". Completed changes remain; no further batches queued.")
            end
        end
        if first.cursor<first.remaining then
            api.defer(continue_growth)
            return string.format("%s: tree growth running in batches; %d records remain; registered %d previously untracked young trees. "
                .. "A completion message will follow. mobs.cancel stops future batches.",region_label(region),first.remaining,first.enrolled)
        end
        growth_job=nil
        return region_label(region) .. ": " .. summary(first,false)
            .. (mode>=4 and ' Stage/work-area scope may leave growing trees intentionally.' or '')
    end
    local function arm(mode, preview)
        assert(not growth_job, "Tree growth is already running; mobs.cancel stops further batches")
        local pawn, region=region_context()
        assert(not pawn.mapViewMode and not pawn:isInAnyConstructionMode(), "Exit the map and building placement first")
        local component
        -- Reuse the native seedling component registered to this region. Never
        -- substitute rocks, shrubs, mature forest meshes or arbitrary assets.
        for i=1,#region.regionalFoliage do
            local candidate=region.regionalFoliage[i]
            if valid(candidate) and valid(candidate.StaticMesh)
                and candidate.StaticMesh:GetFullName():find("/Trees/Oak/stc_oak_photog_babyA.",1,true) then
                assert(not component, "Multiple seedling components; planting refused")
                component=candidate
            end
        end
        assert(component, "This region has no registered oak seedling component")
        -- Validate binary/region/growing array before arming a click tool.
        api.run(region,pawn,3,true)
        pending={pawn=pawn,region=region,component=component,mode=mode,preview=preview,expires=os.time()+300}
        return string.format("%s: %s armed. Close console and click cleared ground to %s one native sapling%s. "
            .. "Expires in five minutes; mobs.cancel cancels.", region_label(region),
            preview and "Forestry preview" or "Forestry planting", preview and "preview planting" or "plant",
            mode==2 and " and mature growing trees in this region" or "")
    end
    api.bind(function()
        local request=pending
        if not request then return end
        api.defer(function()
            if pending~=request then return end
            local ok, message=pcall(function()
                if os.time()>=request.expires then pending=nil; return "Forestry click expired; nothing changed." end
                local pawn=get_pawn()
                assert(same(pawn,request.pawn), "Settlement changed; re-arm forestry")
                if pawn.isUsingUI or pawn.bFullscreenUIActive then return end
                assert(not pawn.mapViewMode and not pawn:isInAnyConstructionMode(), "Exit map and placement first")
                local at=pawn:getMouse3d()
                local region=pawn.masterPtr:getRegionByPos({X=at.X,Y=at.Y,Z=at.Z},false)
                assert(same(region,request.region) and same(region.ownerPawn,pawn), "Click cleared ground inside the armed owned region")
                assert(valid(request.component), "Seedling component is no longer available")
                -- Consume once before entering native code. Never retry a partial action.
                pending=nil
                return begin_growth(pawn,region,request.mode,request.preview,request.component,at)
            end)
            if not ok then notify("Forestry: " .. tostring(message)) elseif message then notify(message) end
        end)
    end)
    function self.register(register)
        register("mobs.grow_trees", "mobs.grow_trees [preview]", function(args)
            local preview=parse(args,"mobs.grow_trees")
            local pawn,region=region_context()
            return begin_growth(pawn,region,0,preview)
        end, "Grow registered trees and untracked native young-tree stages to maturity in batches; excludes decorative bushes. Supports preview.")
        local function growth_scope(args,name,stage)
            local values,preview=require('game_access').preview(args)
            assert(#values<=1 and (not values[1] or values[1]=='area'),'Usage: ' .. name .. ' [area] [preview]')
            local pawn,region=region_context()
            local area
            if values[1]=='area' then
                local selected=require('game_access').selected(pawn)
                assert(#selected==1 and same(selected[1].Region,region),'Select one building in the command target region')
                local building=selected[1]
                assert(building.workAreaLimited and building.workAreaRange>0 and building.workAreaRange<=25000,
                    'Set a limited work area on the selected building first (radius <=25000)')
                area={X=building.workAreaCenter.X,Y=building.workAreaCenter.Y,radius=building.workAreaRange}
            end
            return begin_growth(pawn,region,stage and (area and 5 or 4) or (area and 6 or 3),preview,nil,nil,area)
        end
        register('mobs.grow_saplings','mobs.grow_saplings [area] [preview]',function(args)
            return growth_scope(args,'mobs.grow_saplings',false)
        end,'Mature registered saplings, including forester plantings; optionally limit to the selected building work area, supports preview.')
        register('mobs.grow_stage','mobs.grow_stage [area] [preview]',function(args)
            return growth_scope(args,'mobs.grow_stage',true)
        end,'Advance each registered growing tree once through native growth; optionally target one limited work area, supports preview.')
        register("mobs.replant_trees", "mobs.replant_trees [preview]", function(args)
            return arm(1,parse(args,"mobs.replant_trees"))
        end, "Click cleared ground to replant one oak sapling in the target owned region; native collision checks; supports preview.")
        register("mobs.regrow_trees", "mobs.regrow_trees [preview]", function(args)
            return arm(2,parse(args,"mobs.regrow_trees"))
        end, "Combined tool: click to replant one sapling and mature native growing trees in the target owned region; supports preview.")
    end
    return self
end
return M
