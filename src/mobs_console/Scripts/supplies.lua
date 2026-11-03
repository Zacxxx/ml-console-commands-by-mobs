-- Copyright 2026 Mobs. MIT licensed. Original implementation.
-- One-shot delivery and native Supplies building placement.
local core = require("core")
local M = {}

local function valid(object)
    local ok, result = pcall(function() return object and object:IsValid() end)
    return ok and result
end

local function normalized(value)
    return tostring(value):lower():gsub("[^%w]", "")
end

local function text(value)
    if type(value) == "string" then return value end
    return value:ToString()
end

local function count(building, id)
    local total = 0
    local inventory = building.Inventory
    for index = 1, #inventory do
        local good = inventory[index]
        if good.Type == id then total = total + good.amt end
    end
    return total
end

function M.new(get_pawn, notify)
    local pending
    local last_result = "No supply delivery armed."
    local hook_error
    local self = {}

    local function report(message)
        last_result = message
        notify(message)
    end

    local function catalog(pawn)
        local engine = pawn.masterPtr
        assert(valid(engine) and valid(engine.itemStats), "Item data is not loaded yet")
        local result = {}
        local names = engine.itemStats:GetRowNames()
        for index = 1, #names do
            local row_name = text(names[index])
            local id = tonumber(row_name) or tonumber(row_name:match("(%d+)$"))
            if id and id > 0 then
                -- Read the table row in place. getItem() returns a large struct
                -- by value; UE4SS crashed while copying its string fields.
                local item = engine.itemStats:FindRow(row_name)
                assert(item, "Cannot read item table row " .. row_name)
                local name = text(item.Name)
                -- Livestock uses a different spawning/ownership system.
                if name ~= "" and item.ItemCategory ~= 5
                    and item.storageType >= 0 and item.storageType <= 2 then
                    result[#result + 1] = {id = id, name = name,
                        storage_type = item.storageType}
                end
            end
        end
        assert(#result > 0, "No supply items found in the game item table")
        table.sort(result, function(a, b) return a.id < b.id end)
        return result
    end

    -- Read-only rows reused by autocomplete; preserves the safe in-place table reader.
    function self.catalog() return catalog(get_pawn()) end

    function self.items(search)
        local filter = normalized(search or "")
        local lines = {}
        for _, item in ipairs(catalog(get_pawn())) do
            if normalized(item.name):find(filter, 1, true)
                or tostring(item.id) == filter then
                lines[#lines + 1] = string.format("%d: %s", item.id, item.name)
            end
        end
        return #lines > 0 and table.concat(lines, "\n") or "No matching supply items."
    end

    function self.status()
        if pending and os.time() >= pending.expires then
            pending = nil
            last_result = "Supply delivery expired; nothing added."
        end
        if pending then
            if pending.mode == "pile" then
                return string.format("New pile armed: %d %s. Close console and place the Supplies preview "
                    .. "in your region. Experimental; mobs.cancel cancels. %s",
                    pending.amount, pending.item.name, last_result)
            end
            return string.format("Armed: %d %s. Close the console and click owned storage or a construction needing this material. "
                .. "Expires in %ds; mobs.cancel cancels. Last result: %s",
                pending.amount, pending.item.name, pending.expires - os.time(), last_result)
        end
        return last_result
    end

    function self.arm(name, amount)
        assert(not hook_error, "Click delivery is unavailable: " .. tostring(hook_error))
        local pawn = get_pawn()
        local quantity = core.integer(amount, 1, 10000)
        local matches = {}
        for _, item in ipairs(catalog(pawn)) do
            if normalized(item.name) == normalized(name) or tostring(item.id) == name then
                matches[#matches + 1] = item
            end
        end
        assert(#matches == 1, "Unknown or ambiguous item; use mobs.items <search> and its numeric ID")
        pending = {item = matches[1], amount = quantity,
            pawn_address = pawn:GetAddress(), expires = os.time() + 300}
        last_result = "Delivery armed; no inventory changed yet."
        return self.status()
    end

    local function delivery_plan(pawn, building, item, requested, any_building)
        assert(valid(building), "No valid building target")
        local region = building.Region
        assert(valid(region) and valid(region.ownerPawn)
            and region.ownerPawn:GetAddress() == pawn:GetAddress(), "Choose a building owned by your lord")
        local before = count(building, item.id)
        local amount = requested
        if not building:IsConstructed() or building.isBeingUpgraded then
            local required = 0
            local goods = building.constructionGoods
            for index = 1, #goods do
                if goods[index].Type == item.id then required = required + goods[index].amt end
            end
            local inbound = building:GetStockThatPeopleAreBringing(item.id)
            assert(type(inbound) == "number", "Cannot read incoming construction materials")
            amount = math.min(amount, math.max(0, required - before - inbound))
            assert(amount > 0, "This site does not need more of this material")
        elseif any_building then
            assert(before + amount <= 1000000, "Inventory would exceed one million units")
        elseif building:GetType() ~= 88 then
            assert(building:isStorageTypeBuilding(), "Choose storage or a construction site")
            local limit = building:GetStorageLimit(item.storage_type)
            local used = building:GetStoragePlusWhatPeopleAreBringing(item.storage_type)
            assert(type(limit) == "number" and type(used) == "number" and limit - used >= amount,
                "Building lacks room for this item/amount")
        end
        return {building = building, item = item, amount = amount, before = before, region = region}
    end

    local function apply_delivery(plan)
        assert(valid(plan.building) and count(plan.building, plan.item.id) == plan.before,
            "Inventory changed after preflight; delivery stopped")
        plan.building:addToInventory({Type = plan.item.id, amt = plan.amount})
        return count(plan.building, plan.item.id) - plan.before
    end

    function self.give(name, amount, preview, any_building)
        assert(not pending, "Cancel the armed click delivery with mobs.cancel before using mobs.give")
        local pawn = get_pawn()
        local requested = core.integer(amount, 1, 10000)
        local matches = {}
        for _, item in ipairs(catalog(pawn)) do
            if normalized(item.name) == normalized(name) or tostring(item.id) == name then
                matches[#matches + 1] = item
            end
        end
        assert(#matches == 1, "Unknown or ambiguous item; use mobs.items <search> and its numeric ID")
        local targets = pawn:getSelectedBuildings()
        assert(#targets > 0 and #targets <= 32, "Select between 1 and 32 owned storage buildings or construction sites")
        local plans, seen, total = {}, {}, 0
        -- Preflight every target before writing to the first one.
        for index = 1, #targets do
            local building = targets[index]
            assert(valid(building), "Selection contains an invalid building; nothing changed")
            local address = building:GetAddress()
            if not seen[address] then
                seen[address] = true
                local plan = delivery_plan(pawn, building, matches[1], requested, any_building)
                plans[#plans + 1] = plan
                total = total + plan.amount
            end
        end
        if preview then
            return string.format("Preview: %d %s total across %d selected buildings (up to %d each). Nothing changed.",
                total, matches[1].name, #plans, requested)
        end
        local changed, delivered = 0, 0
        for _, plan in ipairs(plans) do
            local ok, delta = pcall(apply_delivery, plan)
            if not ok then
                return string.format("Delivery stopped after %d/%d buildings and %d verified goods: %s. "
                    .. "Current target may have changed; no automatic retry. Not undoable.",
                    changed, #plans, delivered, tostring(delta))
            end
            delivered = delivered + delta
            if delta ~= plan.amount then
                return string.format("Delivery stopped: current target changed by %d instead of %d; "
                    .. "%d goods counted so far. Remaining targets untouched. Not undoable.", delta, plan.amount, delivered)
            end
            changed = changed + 1
        end
        return string.format("Delivered %d %s across %d selected buildings. Not undoable.",
            delivered, matches[1].name, changed)
    end

    function self.cancel()
        local was_armed = pending ~= nil
        local was_pile = pending and pending.mode == "pile"
        pending = nil
        if was_pile then pcall(function() get_pawn():resetBuildingMode() end) end
        last_result = was_armed and "Supply delivery cancelled; nothing added." or "No supply delivery armed."
        return last_result
    end

    function self.reset()
        pending = nil
        last_result = "Supply delivery cleared on player restart."
    end

    function self.arm_pile(name, amount)
        local pawn = get_pawn()
        assert(require("UEHelpers").GetGameInstance():GetAppVersion():ToString() == "Version 0.8.117",
            "New pile placement is restricted to game 0.8.117")
        assert(not pawn.mapViewMode and not pawn:isInAnyConstructionMode(),
            "Exit the region map and building placement first")
        local stats = StaticFindObject("/Game/NotStronghold/Data/buildingStats.buildingStats")
        assert(valid(stats), "Building data is not loaded")
        local stat = stats:FindRow("88")
        assert(stat and text(stat.DisplayName):lower():find("supply", 1, true),
            "Supplies building definition differs from the supported game")
        self.arm(name, amount)
        local request = pending
        request.mode = "pile"
        request.existing = {}
        for _, building in ipairs(FindAllOf("SMBuildingMaster") or {}) do
            if valid(building) then request.existing[building:GetAddress()] = true end
        end
        -- Let the game perform creation, registration and collision checks.
        -- Never call SetupBuilding on an arbitrary or half-created actor.
        local ok, err = pcall(function()
            pawn:activateBuildingMode(88)
            assert(pawn:isInAnyConstructionMode(), "The game refused Supplies placement")
        end)
        if not ok then
            pending = nil
            error(err)
        end
        return self.status()
    end

    local function fill_new_pile(request, position, attempts)
        if pending ~= request then return end
        if os.time() >= request.expires then self.reset(); return end
        local pawn = get_pawn()
        assert(pawn:GetAddress() == request.pawn_address, "Settlement changed; cancel this delivery")
        local found
        for _, building in ipairs(FindAllOf("SMBuildingMaster") or {}) do
            if valid(building) and not request.existing[building:GetAddress()]
                and building:GetType() == 88 then
                local region = building.Region
                if valid(region) and valid(region.ownerPawn)
                    and region.ownerPawn:GetAddress() == pawn:GetAddress() then
                    local at = building:K2_GetActorLocation()
                    local dx, dy = at.X - position.X, at.Y - position.Y
                    if dx * dx + dy * dy <= 1000 * 1000 then
                        assert(not found, "Multiple new piles nearby; cancel delivery to avoid choosing the wrong pile")
                        found = building
                    end
                end
            end
        end
        if found then
            assert(#found.constructionGoods == 0, "Unexpected construction cost on new Supplies pile")
            local before = count(found, request.item.id)
            pending = nil
            last_result = "New pile delivery attempted; disarmed."
            found:addToInventory({Type = request.item.id, amt = request.amount})
            local added = count(found, request.item.id) - before
            assert(added == request.amount, "Pile inventory changed by " .. tostring(added)
                .. "; disarmed, do not retry blindly")
            -- Placement is normally repeatable; this command is one-shot.
            pawn:resetBuildingMode()
            report(string.format("New pile supplied with %d %s; delivery disarmed. Not undoable.",
                request.amount, request.item.name))
        elseif attempts > 0 then
            ExecuteWithDelay(100, function()
                ExecuteInGameThread(function()
                    if pending ~= request then return end
                    local ok, err = pcall(function() fill_new_pile(request, position, attempts - 1) end)
                    if not ok then pending = nil; report("New pile delivery stopped: " .. tostring(err)) end
                end)
            end)
        else
            request.waiting = false
            report("No new Supplies pile found at the click. Delivery remains armed; mobs.cancel cancels.")
        end
    end

    local function clicked(pawn)
        if not pending then return end
        if pending.mode == "pile" then return end
        if os.time() >= pending.expires then
            pending = nil
            report("Supply delivery expired; nothing added.")
            return
        end
        local local_pawn = get_pawn()
        if not valid(pawn) or pawn:GetAddress() ~= local_pawn:GetAddress() then return end
        if pawn:GetAddress() ~= pending.pawn_address then
            self.reset()
            return
        end
        assert(not pawn.mapViewMode, "Close the region map and click a storage building; delivery remains armed")
        assert(not pawn:isInAnyConstructionMode(), "Exit building placement first; delivery remains armed")
        local building = pawn.hitBuilding
        assert(valid(building), "Click owned storage, a supply pile, or a construction site. Ground spawning is unavailable; delivery remains armed")
        local request = pending
        local plan = delivery_plan(pawn, building, request.item, request.amount)
        -- Disarm before calling the game: failures must never retry a partial write.
        pending = nil
        last_result = "Delivery attempted; disarmed."
        local added = apply_delivery(plan)
        assert(added == plan.amount, "Game reported a different inventory change ("
            .. tostring(added) .. "); delivery disarmed, do not retry blindly")
        report(string.format("Delivered %d %s in %s. Delivery disarmed; not undoable.",
            plan.amount, request.item.name, text(plan.region.regionName)))
    end

    -- The native input path calls LMB_BP_* directly, bypassing ProcessEvent
    -- hooks. Observe the physical click and defer all UObject work to the game.
    local ok, err = pcall(function()
        RegisterKeyBind(Key.LEFT_MOUSE_BUTTON, function()
            if not pending then return end
            local request = pending
            ExecuteWithDelay(150, function()
                ExecuteInGameThread(function()
                    if pending ~= request then return end
                    local success, message = pcall(function()
                        local pawn = get_pawn()
                        if pawn.isUsingUI or pawn.bFullscreenUIActive then return end
                        if request.mode ~= "pile" then clicked(pawn); return end
                        if request.waiting then return end
                        local region = pawn.regionUnderCursor
                        assert(valid(region) and valid(region.ownerPawn)
                            and region.ownerPawn:GetAddress() == pawn:GetAddress(),
                            "Place the new pile in a region owned by your lord")
                        local at = pawn:getMouse3d()
                        local position = {X = at.X, Y = at.Y, Z = at.Z}
                        request.waiting = true
                        fill_new_pile(request, position, 19)
                    end)
                    if not success then report("Supply delivery: " .. tostring(message)) end
                end)
            end)
        end)
    end)
    if not ok then
        hook_error = tostring(err)
        notify("Supply click hook unavailable: " .. hook_error)
    end
    return self
end

return M
