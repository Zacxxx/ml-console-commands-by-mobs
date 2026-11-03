-- Copyright 2026 Mobs. MIT licensed. Native field reports and fertilization permission.
-- Does not write the unreflected soil fertility grid.
local M = {}
local CROPS = {wheat = 1, flax = 2, barley = 3, rye = 7, oats = 15}
local CROP_ORDER = {"wheat", "flax", "barley", "rye", "oats"}

local function valid(object)
    local ok, result = pcall(function() return object and object:IsValid() end)
    return ok and result
end

local function same(a, b)
    return valid(a) and valid(b) and a:GetAddress() == b:GetAddress()
end

local function number(value)
    return type(value) == "number" and value == value and math.abs(value) < math.huge
        and string.format("%.4f", value) or "unavailable"
end

function M.new(get_pawn, get_region, region_label)
    local history = {}
    local self = {}
    function self.reset() history = {} end

    local function selected_fields()
        local pawn = get_pawn()
        local selected = pawn:getSelectedBuildings()
        assert(#selected > 0 and #selected <= 32, "Select between 1 and 32 owned fields")
        local fields, seen = {}, {}
        for index = 1, #selected do
            local field = selected[index]
            assert(valid(field) and field:GetType() == 5 and valid(field.Region)
                and same(field.Region.ownerPawn, pawn), "Select only fields owned by your lord")
            if not seen[field:GetAddress()] then
                seen[field:GetAddress()] = true
                fields[#fields + 1] = field
            end
        end
        return fields
    end

    function self.register(register)
        register("mobs.fertility", "mobs.fertility [wheat|flax|barley|rye|oats]", function(args)
            assert(#args <= 1, "Usage: mobs.fertility [wheat|flax|barley|rye|oats]")
            local crop = args[1] and args[1]:lower()
            assert(not crop or CROPS[crop], "Choose wheat, flax, barley, rye or oats")
            local fields = selected_fields()
            local lines = {"Selected field fertility (native values; no soil changes):"}
            for index, field in ipairs(fields) do
                lines[#lines + 1] = string.format("Field %d | %s | fertilization allowed=%s | current=%d max=%d",
                    index, region_label(field.Region), tostring(field:GetAllowFertilization()),
                    field:GetCurrentFertilization(), field:GetMaxFertilization())
                for _, name in ipairs(crop and {crop} or CROP_ORDER) do
                    lines[#lines + 1] = "  " .. name .. ": " .. number(field:getAverageCropFertility(CROPS[name]))
                end
            end
            return table.concat(lines, "\n")
        end, "Read crop fertility and fertilization counters for selected owned fields; does not restore or set soil fertility.")

        register("mobs.fertilization", "mobs.fertilization <on|off> [selected|region] [preview]", function(args)
            assert(#args >= 1 and #args <= 3 and (args[1] == "on" or args[1] == "off"),
                "Usage: mobs.fertilization <on|off> [selected|region] [preview]")
            local scope, preview
            for index = 2, #args do
                if args[index] == "preview" then
                    assert(not preview, "Repeated preview argument")
                    preview = true
                else
                    assert(not scope and (args[index] == "region" or args[index] == "selected"),
                        "Choose selected or region, with optional preview")
                    scope = args[index]
                end
            end
            local fields, label = {}, "Selected owned fields"
            if scope == "region" then
                local region = get_region(true)
                label = region_label(region)
                for _, field in ipairs(FindAllOf("SMBuildingMaster") or {}) do
                    if valid(field) and field:GetType() == 5 and same(field.Region, region) then
                        fields[#fields + 1] = field
                    end
                end
            else fields = selected_fields() end
            local wanted, plans = args[1] == "on", {}
            for _, field in ipairs(fields) do
                local before = field:GetAllowFertilization()
                assert(type(before) == "boolean", "Cannot read field fertilization permission; nothing changed")
                if before ~= wanted then plans[#plans + 1] = {field = field, region = field.Region, before = before} end
            end
            if preview then
                return string.format("%s: would turn fertilization %s for %d/%d fields; nothing changed.",
                    label, args[1], #plans, #fields)
            end
            if #plans == 0 then return label .. ": no fertilization permissions need changing." end
            local pawn = get_pawn()
            local action = {pawn_address = pawn:GetAddress(), changes = {}}
            history[#history + 1] = action
            if #history > 5 then table.remove(history, 1) end
            local completed, failure = 0, nil
            for _, plan in ipairs(plans) do
                local ok, err = pcall(function()
                    assert(valid(plan.field) and same(plan.field.Region, plan.region)
                        and same(plan.region.ownerPawn, pawn)
                        and plan.field:GetAllowFertilization() == plan.before, "Field changed after preflight")
                    action.changes[#action.changes + 1] = plan
                    plan.field:SetAllowFertilization(wanted)
                    plan.after = plan.field:GetAllowFertilization()
                    assert(plan.after == wanted, "Game refused fertilization permission")
                    completed = completed + 1
                end)
                if not ok then
                    if action.changes[#action.changes] == plan then
                        local read_ok, actual = pcall(function() return plan.field:GetAllowFertilization() end)
                        if read_ok then plan.after = actual end
                    end
                    failure = tostring(err)
                    break
                end
            end
            if #action.changes == 0 then table.remove(history) end
            return string.format("%s: turned fertilization %s for %d/%d fields.%s "
                .. "This changes permission only; game prerequisites still apply. mobs.undo_fertilization can restore it.",
                label, args[1], completed, #plans, failure and (" Stopped: " .. failure) or "")
        end, "Enable/disable native fertilization permission for selected fields or the target region; supports preview. Does not add fertility.")

        register("mobs.undo_fertilization", "mobs.undo_fertilization", function(args)
            assert(#args == 0, "Usage: mobs.undo_fertilization")
            local action = history[#history]
            assert(action, "No fertilization permission change to undo")
            local pawn = get_pawn()
            assert(pawn:GetAddress() == action.pawn_address, "Fertilization undo belongs to another settlement")
            for _, plan in ipairs(action.changes) do
                assert(valid(plan.field) and valid(plan.region) and same(plan.field.Region, plan.region)
                    and same(plan.region.ownerPawn, pawn) and plan.after ~= nil
                    and plan.field:GetAllowFertilization() == plan.after,
                    "Field permission, region or ownership changed; undo refused")
            end
            for _, plan in ipairs(action.changes) do
                plan.field:SetAllowFertilization(plan.before)
                assert(plan.field:GetAllowFertilization() == plan.before, "Game did not restore permission")
            end
            table.remove(history)
            return "Restored fertilization permissions for " .. #action.changes .. " fields."
        end, "Undo the latest fertilization permission batch when fields are unchanged; holds five batches until reload.")
    end
    return self
end

return M
