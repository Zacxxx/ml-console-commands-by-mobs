-- Copyright 2026 Mobs. MIT licensed. Original implementation.
-- Edit amounts of existing natural resource clumps; never create or remove actors.
local core = require("core")
local M = {}
local KINDS = {"clay", "iron", "salt", "stone", "berries", "mushrooms", "fish", "eel"}
local CLASSES = {clay = "Resource_Clay", iron = "Resource_Iron",
    salt = "Resource_Salt", stone = "Resource_Stone", berries = "Resource_Berries",
    mushrooms = "Resource_Mushrooms", fish = "Resource_Fish", eel = "Resource_Eel"}

local function valid(object)
    local ok, result = pcall(function() return object and object:IsValid() end)
    return ok and result
end

local function same(a, b)
    return valid(a) and valid(b) and a:GetAddress() == b:GetAddress()
end

function M.new(get_pawn, get_region, region_label)
    local history = {}
    local self = {}

    function self.reset() history = {} end

    local function kind_arg(value)
        local kind = (value or "all"):lower()
        assert(kind == "all" or CLASSES[kind], "Choose iron, clay, stone, salt, berries, mushrooms, fish, eel, or all")
        return kind
    end

    local function deposits(region, kind)
        local result, seen = {}, {}
        for _, candidate in ipairs(KINDS) do
            if kind == "all" or kind == candidate then
                local class_name = CLASSES[candidate]
                local class = StaticFindObject("/Game/CPP_BP/Resources/" .. class_name .. "." .. class_name .. "_C")
                if valid(class) then
                    for _, actor in ipairs(FindAllOf(class_name .. "_C") or {}) do
                        if valid(actor) and actor:IsA(class) and same(actor.Region, region)
                            and not seen[actor:GetAddress()] then
                            seen[actor:GetAddress()] = true
                            result[#result + 1] = {actor = actor, kind = candidate,
                                before = core.integer(actor.amt, 0, 2147483647),
                                capacity = core.integer(actor.capacity, 0, 2147483647)}
                        end
                    end
                end
            end
        end
        return result
    end

    function self.register(register)
        register("mobs.resources", "mobs.resources [kind]", function(args)
            assert(#args <= 1, "Usage: mobs.resources [kind]")
            local region = get_region(true)
            local entries = deposits(region, kind_arg(args[1]))
            local totals = {}
            for _, entry in ipairs(entries) do
                local total = totals[entry.kind] or {count = 0, amount = 0, capacity = 0}
                total.count = total.count + 1
                total.amount = total.amount + entry.before
                total.capacity = total.capacity + entry.capacity
                totals[entry.kind] = total
            end
            local lines = {region_label(region) .. " existing natural deposits:"}
            for _, kind in ipairs(KINDS) do
                local total = totals[kind]
                if total then
                    lines[#lines + 1] = string.format("%s: %d clumps, remaining=%d, capacity=%d",
                        kind, total.count, total.amount, total.capacity)
                end
            end
            if #lines == 1 then lines[#lines + 1] = "No matching live deposits found." end
            return table.concat(lines, "\n")
        end, "Inspect existing mineral, berry, mushroom, fish and eel clumps in the target owned region; does not count stored goods.")

        local function change_resources(args,empty)
            assert(#args <= 2, "Usage: mobs.refill_resources [kind] [preview]")
            local kind, preview
            if args[1] == "preview" then
                assert(#args == 1, "Usage: mobs.refill_resources [kind] [preview]")
                kind, preview = "all", true
            else
                kind = kind_arg(args[1])
                assert(not args[2] or args[2] == "preview", "Last argument must be preview")
                preview = args[2] == "preview"
            end
            local region = get_region(true)
            local entries = deposits(region, kind)
            local plans, total, skipped = {}, 0, 0
            for _, entry in ipairs(entries) do
                entry.target=empty and 0 or entry.capacity
                if entry.capacity > 0 and entry.before ~= entry.target and entry.before <= entry.capacity then
                    plans[#plans + 1] = entry
                    total = total + entry.target - entry.before
                elseif entry.capacity <= 0 or entry.before > entry.capacity then
                    skipped = skipped + 1
                end
            end
            if preview then
                return string.format("%s: would change resource amounts by %+d units to %d clumps; %d invalid/zero capacities skipped. Nothing changed.",
                    region_label(region), total, #plans, skipped)
            end
            if #plans == 0 then return "No depleted matching live deposits with valid capacity; nothing changed." end
            local action = {pawn_address = get_pawn():GetAddress(), region = region, changes = {}}
            -- Keep the action before applying so partial writes remain undoable.
            history[#history + 1] = action
            if #history > 5 then table.remove(history, 1) end
            local added, failure = 0, nil
            for _, entry in ipairs(plans) do
                local ok, err = pcall(function()
                    assert(valid(entry.actor) and same(entry.actor.Region, region)
                        and entry.actor.amt == entry.before and entry.actor.capacity == entry.capacity,
                        "Deposit changed after preflight")
                    -- Track before the setter, which may fail after a partial write.
                    action.changes[#action.changes + 1] = entry
                    entry.actor.amt = entry.target
                    entry.after = entry.actor.amt
                    assert(entry.after == entry.target, "Game refused the resource amount")
                    added = added + entry.target - entry.before
                end)
                if not ok then
                    if action.changes[#action.changes] == entry then
                        local read_ok, actual = pcall(function() return entry.actor.amt end)
                        if read_ok then entry.after = actual end
                    end
                    failure = tostring(err)
                    break
                end
            end
            if #action.changes == 0 then table.remove(history) end
            return string.format("%s: changed resource amounts by %+d units; %d clumps attempted; %d capacities skipped.%s "
                .. "mobs.undo_resources restores only if the deposits remain unchanged.",
                region_label(region), added, #action.changes, skipped,
                failure and (" Stopped: " .. failure) or "")
        end
        register('mobs.refill_resources','mobs.refill_resources [kind] [preview]',function(args)
            return change_resources(args,false)
        end,'Refill existing iron/clay/stone/salt/berries/mushrooms/fish/eel clumps to capacity; preview and guarded undo; no new nodes.')
        register('mobs.empty_resources','mobs.empty_resources [kind] [preview]',function(args)
            return change_resources(args,true)
        end,'Empty existing matching natural resource clumps in your target region, retaining actors; preview and guarded undo. Wildlife excluded.')

        register("mobs.undo_resources", "mobs.undo_resources", function(args)
            assert(#args == 0, "Usage: mobs.undo_resources")
            local action = history[#history]
            assert(action, "No resource refill to undo")
            local pawn = get_pawn()
            assert(pawn:GetAddress() == action.pawn_address and valid(action.region)
                and same(action.region.ownerPawn, pawn), "Resource undo belongs to another settlement or owner")
            -- Validate every clump before restoring any. Mining since refill refuses undo.
            for _, entry in ipairs(action.changes) do
                assert(valid(entry.actor) and same(entry.actor.Region, action.region)
                    and entry.after ~= nil and entry.actor.amt == entry.after
                    and entry.actor.capacity == entry.capacity,
                    "Deposits changed or were removed since refill; undo refused")
            end
            for _, entry in ipairs(action.changes) do
                entry.actor.amt = entry.before
                assert(entry.actor.amt == entry.before, "Game did not restore a deposit amount")
            end
            table.remove(history)
            return string.format("Restored %d deposit clumps in %s.", #action.changes, region_label(action.region))
        end, "Undo the latest resource refill if no affected deposit has changed; holds five refills and clears on reload.")
    end

    return self
end

return M
