-- Copyright 2026 Mobs. MIT licensed. Independent counterparts to original features.
local core = require("core")
local M = {}

local function valid(object)
    local ok, result = pcall(function() return object and object:IsValid() end)
    return ok and result
end

local function same(a, b)
    return valid(a) and valid(b) and a:GetAddress() == b:GetAddress()
end

function M.register(register, get_pawn, get_region, region_label, item_name, version)
    register("mobs.mercenaries", "mobs.mercenaries reroll", function(args)
        assert(#args == 1 and args[1] == "reroll", "Usage: mobs.mercenaries reroll")
        local engine = get_pawn().masterPtr
        assert(valid(engine), "Simulation is not loaded")
        engine:rerollMercenaries()
        return "Called the game's mercenary reroll. Reopen the hiring panel to inspect the result. Not undoable."
    end, "Reroll mercenary offers through the native game function; does not hire any units.")

    require('population_tools').register(register,get_pawn,get_region,region_label)

    register("mobs.livestock_cooldown", "mobs.livestock_cooldown [reset]", function(args)
        assert(#args == 0 or (#args == 1 and args[1] == "reset"), "Usage: mobs.livestock_cooldown [reset]")
        local region = get_region(true)
        local label = region_label(region)
        local before = core.integer(region.nextLivestockOrderIn, -2147483648, 2147483647)
        if args[1] and before > 0 then
            region.nextLivestockOrderIn = 0
            assert(region.nextLivestockOrderIn == 0, "Game did not clear the livestock order cooldown")
            return string.format("%s: livestock order cooldown %d -> 0. Existing orders unchanged; not undoable.", label, before)
        end
        return string.format("%s: livestock order cooldown=%d (game counter); %s.",
            label, before, before <= 0 and "already ready" or "use mobs.livestock_cooldown reset to clear")
    end, "Read or clear the target region's next livestock order cooldown; does not spawn or deliver animals.")

    register("mobs.skip_mourning", "mobs.skip_mourning [preview]", function(args)
        assert(#args == 0 or (#args == 1 and args[1] == "preview"), "Usage: mobs.skip_mourning [preview]")
        local region, plans = get_region(true), {}
        local label = region_label(region)
        for _, building in ipairs(FindAllOf("SMBuildingMaster") or {}) do
            if valid(building) and same(building.Region, region) then
                local before = core.integer(building.mourningPeriod, -2147483648, 2147483647)
                if before > 0 then plans[#plans + 1] = {building = building, before = before} end
            end
        end
        if args[1] then
            return string.format("%s: %d buildings have active mourning; preview changed nothing.", label, #plans)
        end
        local changed, failure = 0, nil
        for _, plan in ipairs(plans) do
            local ok, err = pcall(function()
                assert(valid(plan.building) and same(plan.building.Region, region)
                    and plan.building.mourningPeriod == plan.before, "Building changed after preflight")
                plan.building.mourningPeriod = 0
                assert(plan.building.mourningPeriod == 0, "Game did not clear mourning")
            end)
            if not ok then failure = tostring(err); break end
            changed = changed + 1
        end
        return string.format("%s: cleared mourning for %d/%d buildings.%s Not undoable.",
            label, changed, #plans, failure and (" Stopped: " .. failure) or "")
    end, "Clear active mourning timers on owned buildings in the target region; preview lists the affected count.")

    register("mobs.foreign_supply", "mobs.foreign_supply [search]", function(args)
        assert(#args <= 1, "Usage: mobs.foreign_supply [search]")
        local engine = get_pawn().masterPtr
        assert(valid(engine), "Simulation is not loaded")
        local supply, totals, ids = engine.ForeignMarketSupply, {}, {}
        for index = 1, #supply do
            local good = supply[index]
            if totals[good.Type] == nil then ids[#ids + 1] = good.Type; totals[good.Type] = 0 end
            totals[good.Type] = totals[good.Type] + core.integer(good.amt, -2147483648, 2147483647)
        end
        table.sort(ids)
        local filter, lines = (args[1] or ""):lower(), {"Global foreign-market supply (not regional stock):"}
        for _, id in ipairs(ids) do
            local name = item_name(id)
            if name:lower():find(filter, 1, true) or tostring(id) == filter then
                lines[#lines + 1] = string.format("%s (ID %d): %d", name, id, totals[id])
            end
        end
        if #lines == 1 then lines[#lines + 1] = "No matching foreign supply entries." end
        return table.concat(lines, "\n")
    end, "Print the global foreign market supply, optionally filtered by item name or ID; changes nothing.")

    register("mobs.ping", "mobs.ping", function(args)
        assert(#args == 0, "Usage: mobs.ping")
        return "Pong. ML Console Commands by Mobs " .. version .. " is responding."
    end, "Check that this mod's console handler responds; works without a loaded settlement.")

    register("mobs.is_in_game", "mobs.is_in_game", function(args)
        assert(#args == 0, "Usage: mobs.is_in_game")
        local ok = pcall(get_pawn)
        return ok and "Yes: local settlement pawn is available." or "No: load a settlement first."
    end, "Check whether the local settlement pawn required by gameplay commands is available.")
end

return M
