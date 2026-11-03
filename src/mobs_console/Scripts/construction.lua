-- Original Mobs code. Non-reflected work fields are gated to the verified build.
local M = {}
local source = debug.getinfo(1, "S").source:gsub("^@", ""):gsub("\\", "/")
local registered = false

local function valid(object)
    local ok, result = pcall(function() return object and object:IsValid() end)
    return ok and result
end

local function same(a, b)
    return valid(a) and valid(b) and a:GetAddress() == b:GetAddress()
end

local function finite(value)
    return type(value) == "number" and value == value and math.abs(value) < math.huge
end

function M.ensure_layout()
    if registered then return end
    local helpers = require("UEHelpers")
    assert(helpers.GetGameInstance():GetAppVersion():ToString() == "Version 0.8.117",
        "Construction completion supports only the verified Steam 0.8.117 build")
    local directory = assert(source:match("^(.*)/ue4ss/Mods/"), "Cannot locate game binary")
    local file = assert(io.open(directory .. "/ManorLords-Win64-Shipping.exe", "rb"))
    local ok, message = pcall(function()
        local function read_at(offset, size)
            assert(file:seek("set", offset))
            local data = file:read(size)
            assert(data and #data == size, "Cannot read game fingerprint")
            return data
        end
        local pe = string.unpack("<I4", read_at(0x3c, 4))
        assert(read_at(pe, 4) == "PE\0\0", "Invalid game binary")
        assert(string.unpack("<I4", read_at(pe + 8, 4)) == 0x6836c1ba,
            "Unsupported game binary timestamp")
        assert(string.unpack("<I4", read_at(pe + 24 + 56, 4)) == 0x9dfd000,
            "Unsupported game binary layout")
        local signature = ("488bc44889580848897010574883ec50488bf10f2970e833"):gsub("..", function(hex)
            return string.char(tonumber(hex, 16))
        end)
        assert(read_at(0x4d3cf40, #signature) == signature,
            "Game construction getter fingerprint changed")
    end)
    file:close()
    assert(ok, message)
    RegisterCustomProperty({Name="MobsConstructionWorkDone", Type=PropertyTypes.FloatProperty,
        BelongsToClass="/Script/ManorLords.SMBuilding", OffsetInternal=0x314})
    RegisterCustomProperty({Name="MobsConstructionWorkTotal", Type=PropertyTypes.FloatProperty,
        BelongsToClass="/Script/ManorLords.SMBuilding", OffsetInternal=0x318})
    registered = true
end

function M.prepare(region, preview, api)
    api = api or {
        buildings = function() return FindAllOf("SMBuildingMaster") or {} end,
        parts = function() return FindAllOf("SMBuilding") or {} end,
        ensure_layout = M.ensure_layout,
    }
    local candidates = {}
    for _, building in ipairs(api.buildings()) do
        if valid(building) and same(building.Region, region)
                and building:GetType() ~= 88
                and (not building:IsConstructed() or building.isBeingUpgraded) then
            candidates[#candidates + 1] = building
        end
    end
    local result = {pending=#candidates, prepared=0, failures={}}
    if preview or #candidates == 0 then return result end
    api.ensure_layout()
    local parts, plans = api.parts(), {}
    -- Validate the whole batch before changing any inventory or work values.
    for _, building in ipairs(candidates) do
        local plan = {building=building, parts={}, missing={}}
        for _, part in ipairs(parts) do
            if valid(part) and same(part.BuildingMaster, building) then
                local done, total = part.MobsConstructionWorkDone, part.MobsConstructionWorkTotal
                assert(finite(done) and finite(total) and total >= 0 and total <= 100000000
                    and done >= 0 and done <= total + 1,
                    "Invalid construction work values; no buildings changed")
                if total > 0 then plan.parts[#plan.parts + 1] = part end
            end
        end
        assert(#plan.parts > 0, "No construction parts found; no buildings changed")
        local counts = {}
        local inventory = building.Inventory
        for i = 1, #inventory do
            local good = inventory[i]
            counts[good.Type] = (counts[good.Type] or 0) + good.amt
        end
        local required = {}
        for i = 1, #building.constructionGoods do
            local good = building.constructionGoods[i]
            assert(finite(good.amt) and good.amt >= 0 and good.amt <= 1000000,
                "Invalid construction material requirement; no buildings changed")
            required[good.Type] = (required[good.Type] or 0) + good.amt
        end
        for good_type, amount in pairs(required) do
            local missing = amount - (counts[good_type] or 0)
            if missing > 0 then plan.missing[#plan.missing + 1] = {Type=good_type, amt=missing} end
        end
        plans[#plans + 1] = plan
    end
    for _, plan in ipairs(plans) do
        local ok, message = pcall(function()
            for _, good in ipairs(plan.missing) do plan.building:addToInventory(good) end
            for _, part in ipairs(plan.parts) do
                part.MobsConstructionWorkDone = part.MobsConstructionWorkTotal
            end
            plan.building:setConstructionPaused(false)
        end)
        if ok then
            result.prepared = result.prepared + 1
        else
            result.failures[#result.failures + 1] = tostring(message)
        end
    end
    return result
end

return M
