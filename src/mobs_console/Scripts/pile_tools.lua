-- Copyright 2026 Mobs. MIT licensed. Original implementation.
-- Use native demolition so region records, visuals and transport targets retire together.
local M = {}
local function valid(object)
    local ok, result = pcall(function() return object and object:IsValid() end)
    return ok and result
end
local function same(a, b)
    return valid(a) and valid(b) and a:GetAddress() == b:GetAddress()
end
local function empty(building)
    local ok, result = pcall(function()
        local goods = building.Inventory
        for i = 1, #goods do
            local amount = goods[i].amt
            if type(amount) ~= "number" or amount ~= 0 then return false end
        end
        return true
    end)
    return ok and result
end
local function preview(args, usage)
    assert(#args <= 1 and (not args[1] or args[1] == "preview"), "Usage: " .. usage)
    return args[1] == "preview"
end
function M.new(get_pawn, get_region, region_label, api)
    api = api or {
        buildings=function() return FindAllOf("SMBuildingMaster") or {} end,
        defer=function(callback)
            ExecuteWithDelay(200, function() ExecuteInGameThread(callback) end)
        end,
        notify=function(message) print("[MobsConsole] " .. message .. "\n") end,
        ensure_supported=function()
            assert(require("UEHelpers").GetGameInstance():GetAppVersion():ToString() == "Version 0.8.117",
                "Pile removal supports game 0.8.117")
        end,
    }
    local self = {}
    local function owned_pile(building, pawn)
        return valid(building)
            and building:IsA(StaticFindObject("/Script/ManorLords.SMBuildingMaster"))
            and building:GetType() == 88 and valid(building.Region)
            and same(building.Region.ownerPawn, pawn)
    end
    local function remove(targets, pawn, only_empty)
        api.ensure_supported()
        local requested, failures, addresses = 0, {}, {}
        -- Targets are a Lua snapshot: demolition can mutate native selection/region arrays.
        for _, building in ipairs(targets) do
            local ok, message = pcall(function()
                assert(owned_pile(building, pawn), "Pile became invalid or changed owner")
                assert(not only_empty or empty(building), "Pile is no longer empty")
                local address = building:GetAddress()
                building:demolish(false)
                addresses[address] = true
            end)
            if ok then requested=requested+1 else
                failures[#failures+1]=tostring(message)
                -- Never repeat a failed native removal or escalate to raw actor destruction.
                break
            end
        end
        if requested > 0 then
            -- Native removal retires the master on a later update. Do not treat
            -- a still-valid UObject in this frame as either failure or success.
            api.defer(function()
                local ok, message = pcall(function()
                    local remaining = 0
                    for _, building in ipairs(api.buildings()) do
                        if valid(building) and addresses[building:GetAddress()] then
                            remaining = remaining + 1
                        end
                    end
                    return string.format("Pile removal verified: %d removed; %d still present. No automatic retry.",
                        requested - remaining, remaining)
                end)
                api.notify(ok and message or ("Pile removal verification failed: " .. tostring(message)))
            end)
        end
        return string.format("Removal requested for %d/%d supply piles; %d failed before verification. No refund; not undoable.%s",
            requested, #targets, #failures, failures[1] and (" " .. failures[1]) or "")
    end
    function self.register(register)
        local usage="mobs.clear_empty_piles [preview]"
        register("mobs.clear_empty_piles", usage, function(args)
            local dry_run=preview(args, usage)
            local pawn, region=get_pawn(), get_region(true)
            assert(same(region.ownerPawn, pawn), "Choose a region owned by your lord")
            local targets, seen, kept={}, {}, 0
            for _, building in ipairs(api.buildings()) do
                if owned_pile(building, pawn) and same(building.Region, region)
                    and not seen[building:GetAddress()] then
                    seen[building:GetAddress()]=true
                    if empty(building) then targets[#targets+1]=building else kept=kept+1 end
                end
            end
            local heading=region_label(region) .. ": "
            if dry_run then
                return heading .. string.format("%d empty supply piles would be removed; %d non-empty/unreadable kept. Preview changed nothing.", #targets, kept)
            end
            return heading .. remove(targets, pawn, true)
                .. string.format(" %d non-empty/unreadable piles kept.", kept)
        end, "Remove empty owned Supplies piles in the target region; supports preview. Non-empty/unreadable piles are kept.")
        local selected_usage="mobs.remove_selected_piles [preview]"
        register("mobs.remove_selected_piles", selected_usage, function(args)
            local dry_run=preview(args, selected_usage)
            local pawn=get_pawn()
            local selected=pawn.selectedBld
            assert(#selected > 0 and #selected <= 32, "Select between 1 and 32 owned Supplies piles first")
            local targets, seen={}, {}
            -- Reject mixed/foreign selection before removing anything, regardless of region pin.
            for i=1,#selected do
                local building=selected[i]
                assert(owned_pile(building, pawn), "Select only Supplies piles owned by your lord; nothing removed")
                local id=building:GetAddress()
                if not seen[id] then targets[#targets+1]=building; seen[id]=true end
            end
            if dry_run then
                return string.format("%d selected supply piles would be removed, INCLUDING CONTENTS. Preview changed nothing.", #targets)
            end
            return remove(targets, pawn, false) .. " Selected pile contents are discarded."
        end, "Remove selected owned Supplies piles INCLUDING CONTENTS, even unfinished/bugged ones; supports preview. Ignores region pin; no undo.")
    end
    return self
end
return M
