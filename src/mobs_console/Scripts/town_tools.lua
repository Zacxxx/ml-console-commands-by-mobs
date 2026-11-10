-- Copyright 2026 Mobs. MIT licensed. Original implementation.
local core = require("core")
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

local function quantity(value)
    return core.integer(value, 0, 1000000)
end

function M.new(get_pawn)
    local pinned
    local pinned_pawn
    local self = {}

    function self.reset()
        pinned, pinned_pawn = nil, nil
    end

    function self.region(allow_current)
        local pawn = get_pawn()
        if pinned then
            assert(pinned_pawn == pawn:GetAddress() and valid(pinned),
                "Region target expired; use mobs.region auto")
            assert(same(pinned.ownerPawn, pawn), "Target region is no longer owned by your lord")
            return pinned
        end
        local region = pawn.selectedRegion
        if not valid(region) and allow_current then region = pawn.currentRegion end
        assert(valid(region), "No region target; use mobs.regions then mobs.region <id>")
        assert(same(region.ownerPawn, pawn), "Choose a region owned by your lord")
        return region
    end

    local function region_label(region)
        return string.format("%s (ID %d)", text(region.regionName), region:getRegionUniqueID())
    end
    self.region_label = region_label

    local function item_name(id)
        -- Avoid returning the large native Item struct by value.
        local ok, name = pcall(function()
            local table = get_pawn().masterPtr.itemStats
            assert(valid(table))
            local row = table:FindRow(tostring(id))
            return row and text(row.Name)
        end)
        return ok and name and name ~= "" and name or ("Item " .. tostring(id))
    end
    self.item_name = item_name

    local function building_label(building)
        local id = building:GetType()
        local ok, name = pcall(function()
            local table = StaticFindObject("/Game/NotStronghold/Data/buildingStats.buildingStats")
            assert(valid(table))
            local row = table:FindRow(tostring(id))
            return row and text(row.DisplayName)
        end)
        return string.format("%s [type %d]", ok and name or "Building", id)
    end

    local function selected_building()
        local pawn = get_pawn()
        local buildings = require('game_access').selected(pawn)
        assert(#buildings == 1 and valid(buildings[1]), "Select exactly one building first")
        local building = buildings[1]
        assert(valid(building.Region) and same(building.Region.ownerPawn, pawn),
            "Select a building owned by your lord")
        return building
    end

    local function inventory(building)
        local totals = {}
        local goods = building.Inventory
        for index = 1, #goods do
            local good = goods[index]
            totals[good.Type] = (totals[good.Type] or 0) + quantity(good.amt)
        end
        return totals
    end

    local function sites(region)
        local result = {}
        for _, building in ipairs(FindAllOf("SMBuildingMaster") or {}) do
            if valid(building) and same(building.Region, region)
                and building:GetType() ~= 88
                and (not building:IsConstructed() or building.isBeingUpgraded) then
                result[#result + 1] = building
            end
        end
        return result
    end

    local function needs(building)
        local stored = inventory(building)
        local required, result = {}, {}
        local goods = building.constructionGoods
        for index = 1, #goods do
            local good = goods[index]
            required[good.Type] = (required[good.Type] or 0) + quantity(good.amt)
        end
        for id, total in pairs(required) do
            local incoming = quantity(building:GetStockThatPeopleAreBringing(id))
            result[#result + 1] = {id = id, required = total, stored = stored[id] or 0,
                incoming = incoming, missing = math.max(0, total - (stored[id] or 0) - incoming)}
        end
        table.sort(result, function(a, b) return a.id < b.id end)
        return result
    end

    local function sorted_ids(map)
        local result = {}
        for id in pairs(map) do result[#result + 1] = id end
        table.sort(result)
        return result
    end

    function self.region_choices()
        local pawn,rows=get_pawn(),{}
        for _,region in ipairs(FindAllOf("Region") or {}) do
            if valid(region) and same(region.ownerPawn,pawn) then
                rows[#rows+1]={id=region:getRegionUniqueID(),name=text(region.regionName)}
            end
        end
        table.sort(rows,function(a,b) return a.id<b.id end)
        return rows
    end

    function self.register(register)
        register("mobs.regions", "mobs.regions", function(args)
            assert(#args == 0, "Usage: mobs.regions")
            local pawn, lines = get_pawn(), {}
            for _, region in ipairs(FindAllOf("Region") or {}) do
                if valid(region) and same(region.ownerPawn, pawn) then
                    lines[#lines + 1] = string.format("%s | wealth=%d%s", region_label(region),
                        region.regionalWealth, same(region, pinned) and " | COMMAND TARGET" or "")
                end
            end
            table.sort(lines)
            return #lines > 0 and table.concat(lines, "\n") or "No owned regions found"
        end, "List your owned regions and their IDs for mobs.region.")

        register("mobs.region", "mobs.region [id|current|selected|auto]", function(args)
            assert(#args <= 1, "Usage: mobs.region [id|current|selected|auto]")
            if args[1] == "auto" then
                self.reset()
                return "Automatic targeting restored: selected region, otherwise current region."
            end
            if args[1] then
                local pawn, chosen = get_pawn(), nil
                if args[1] == "current" then chosen = pawn.currentRegion
                elseif args[1] == "selected" then chosen = pawn.selectedRegion
                else
                    local id = core.integer(args[1], 0, 2147483647)
                    for _, region in ipairs(FindAllOf("Region") or {}) do
                        if valid(region) and same(region.ownerPawn, pawn) and region:getRegionUniqueID() == id then
                            assert(not chosen, "Duplicate region ID; use current or selected")
                            chosen = region
                        end
                    end
                end
                assert(valid(chosen) and same(chosen.ownerPawn, pawn), "No owned region matches that target")
                pinned, pinned_pawn = chosen, pawn:GetAddress()
            end
            return "Regional commands target " .. region_label(self.region(true))
                .. (pinned and " (pinned; mobs.region auto clears it)." or " (automatic).")
        end, "Choose a region for wealth and regional construction commands; does not move the camera or alter map selection.")

        register("mobs.building", "mobs.building", function(args)
            assert(#args == 0, "Usage: mobs.building")
            local building = selected_building()
            return string.format("%s | %s | constructed=%s | upgrading=%s | construction paused=%s",
                building_label(building), region_label(building.Region), tostring(building:IsConstructed()),
                tostring(building.isBeingUpgraded), tostring(building:getConstructionPaused()))
        end, "Inspect one selected owned building and its construction state; changes nothing.")

        register("mobs.inventory", "mobs.inventory [search]", function(args)
            assert(#args <= 1, "Usage: mobs.inventory [search]")
            local building = selected_building()
            local filter, lines = (args[1] or ""):lower(), {building_label(building) .. " inventory:"}
            local totals = inventory(building)
            for _, id in ipairs(sorted_ids(totals)) do
                local name = item_name(id)
                if name:lower():find(filter, 1, true) or tostring(id) == filter then
                    lines[#lines + 1] = string.format("%d %s (ID %d)", totals[id], name, id)
                end
            end
            if #lines == 1 then lines[#lines + 1] = "No matching stored goods." end
            return table.concat(lines, "\n")
        end, "Show goods stored directly in one selected owned building; optional name or ID filter.")

        register("mobs.stock", "mobs.stock [search]", function(args)
            assert(#args <= 1, "Usage: mobs.stock [search]")
            local region = self.region(true)
            local goods = region:getStock(true)
            local totals = {}
            for index = 1, #goods do
                local good = goods[index]
                totals[good.Type] = (totals[good.Type] or 0) + core.integer(good.amt, 0, 2147483647)
            end
            local filter, lines = (args[1] or ""):lower(), {region_label(region) .. " stock (includes reserved goods):"}
            for _, id in ipairs(sorted_ids(totals)) do
                local name = item_name(id)
                if name:lower():find(filter, 1, true) or tostring(id) == filter then
                    lines[#lines + 1] = string.format("%d %s (ID %d)", totals[id], name, id)
                end
            end
            if #lines == 1 then lines[#lines + 1] = "No matching regional stock." end
            return table.concat(lines, "\n")
        end, "Show target region stock through the native stock query, including reserved goods; optional name or ID filter.")

        register("mobs.construction_needs", "mobs.construction_needs [region]", function(args)
            assert(#args == 0 or (#args == 1 and args[1] == "region"),
                "Usage: mobs.construction_needs [region]")
            local targets, heading
            if args[1] then
                local region = self.region(true)
                targets, heading = sites(region), region_label(region)
            else
                local building = selected_building()
                assert(not building:IsConstructed() or building.isBeingUpgraded, "Selected building is already complete")
                targets, heading = {building}, building_label(building)
            end
            local totals = {}
            for _, building in ipairs(targets) do
                for _, need in ipairs(needs(building)) do
                    local total = totals[need.id] or {required = 0, stored = 0, incoming = 0, missing = 0}
                    for _, key in ipairs({"required", "stored", "incoming", "missing"}) do
                        total[key] = total[key] + need[key]
                    end
                    totals[need.id] = total
                end
            end
            local lines = {heading .. ": " .. #targets .. " construction site(s)"}
            for _, id in ipairs(sorted_ids(totals)) do
                local need = totals[id]
                lines[#lines + 1] = string.format("%s (ID %d): required=%d stored=%d incoming=%d missing=%d",
                    item_name(id), id, need.required, need.stored, need.incoming, need.missing)
            end
            if #lines == 1 then lines[#lines + 1] = "No material requirements found." end
            return table.concat(lines, "\n")
        end, "Report selected construction materials, or region totals; missing counts include incoming deliveries.")

        register("mobs.supply_construction", "mobs.supply_construction [selected] [preview]", function(args)
            local selected = args[1] == "selected"
            local preview = (selected and args[2] == "preview") or (not selected and args[1] == "preview")
            assert((selected and #args <= 2 and (not args[2] or args[2] == "preview"))
                or (not selected and (#args == 0 or (#args == 1 and preview))),
                "Usage: mobs.supply_construction [selected] [preview]")
            local targets, label
            if selected then
                local pawn, seen = get_pawn(), {}
                local buildings = require('game_access').selected(pawn)
                assert(#buildings > 0 and #buildings <= 32, "Select between 1 and 32 owned construction sites")
                targets = {}
                for index = 1, #buildings do
                    local building = buildings[index]
                    assert(valid(building) and valid(building.Region) and same(building.Region.ownerPawn, pawn),
                        "Selection contains a building not owned by your lord; nothing changed")
                    assert(not building:IsConstructed() or building.isBeingUpgraded,
                        "Select only unfinished or upgrading buildings; nothing changed")
                    if not seen[building:GetAddress()] then
                        seen[building:GetAddress()] = true
                        targets[#targets + 1] = building
                    end
                end
                label = "Selected owned construction sites (ignores region pin)"
            else
                local region = self.region(true)
                targets, label = sites(region), region_label(region)
            end
            local plans, total = {}, 0
            -- Read and validate the entire batch before adding any goods.
            for _, building in ipairs(targets) do
                local plan = {building = building, goods = needs(building)}
                for _, good in ipairs(plan.goods) do total = total + good.missing end
                plans[#plans + 1] = plan
            end
            if preview then
                return string.format("%s: %d sites, %d missing materials; preview changed nothing.",
                    label, #plans, total)
            end
            local added, changed, failures = 0, 0, {}
            for _, plan in ipairs(plans) do
                local site_changed = false
                local ok, err = pcall(function()
                    for _, good in ipairs(plan.goods) do
                        if good.missing > 0 then
                            local before = inventory(plan.building)[good.id] or 0
                            plan.building:addToInventory({Type = good.id, amt = good.missing})
                            local delta = (inventory(plan.building)[good.id] or 0) - before
                            added = added + delta
                            site_changed = site_changed or delta ~= 0
                            assert(delta == good.missing, "Unexpected inventory change; no automatic retry")
                        end
                    end
                end)
                if site_changed then changed = changed + 1 end
                if not ok then failures[#failures + 1] = tostring(err) end
            end
            return string.format("%s: added %d materials to %d/%d sites; %d failures.%s "
                .. "Work and pause state unchanged. Not undoable.", label, added,
                changed, #plans, #failures, failures[1] and (" " .. failures[1]) or "")
        end, "Supply missing construction materials in the target region or selected sites; supports preview. Does not complete work.")

        register("mobs.construction", "mobs.construction <pause|resume>", function(args)
            assert(#args == 1 and (args[1] == "pause" or args[1] == "resume"),
                "Usage: mobs.construction <pause|resume>")
            local region, paused = self.region(true), args[1] == "pause"
            local targets = sites(region)
            local changed, failed = 0, 0
            for _, building in ipairs(targets) do
                local ok = pcall(function()
                    building:setConstructionPaused(paused)
                    assert(building:getConstructionPaused() == paused, "Game did not apply construction state")
                end)
                if ok then changed = changed + 1 else failed = failed + 1 end
            end
            return string.format("%s: %s %d/%d construction sites; %d failures.",
                region_label(region), paused and "paused" or "resumed", changed, #targets, failed)
        end, "Pause or resume unfinished construction across the target region.")

        register("mobs.speed", "mobs.speed [0..12]", function(args)
            assert(#args <= 1, "Usage: mobs.speed [0..12]; 0 pauses, 1 is normal")
            local engine = get_pawn().masterPtr
            assert(valid(engine), "Simulation is not loaded")
            if args[1] then engine:setGameSpeed(core.integer(args[1], 0, 12)) end
            return string.format("Simulation speed: %g; scheduled: %s (%g). 0=paused, 1=normal.",
                engine.gameSpeed, tostring(engine.isGameSpeedScheduled), engine.gameSpeedScheduled)
        end, "Read or request game speed through the native game function; 0 pauses and 1 resumes normally.")
    end

    return self
end

return M
