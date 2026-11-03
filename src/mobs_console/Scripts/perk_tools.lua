-- Copyright 2026 Mobs. MIT licensed. Regional perk card choices and respec.
local M = {}
local directory = debug.getinfo(1, "S").source:gsub("^@", ""):gsub("\\", "/"):match("^(.*)/Scripts/")
local bridge
local files_bridge
local function load_bridge()
    assert(directory, "Cannot locate perk adapter")
    local folder = directory .. "/Native/"
    if not bridge then
        local manifest = assert(io.open(folder .. "perks_bridge_name.txt", "r"), "Perk adapter is missing")
        local name = manifest:read("*l"); manifest:close()
        assert(name and name:match("^mobs_perks_%x+%.dll$"), "Invalid perk adapter manifest")
        bridge = assert(package.loadlib(folder .. name, "mobs_perks_run"))
        files_bridge = assert(package.loadlib(folder .. name, "mobs_perks_files"))
    end
    return folder
end
local function valid(object)
    local ok, result = pcall(function() return object and object:IsValid() end)
    return ok and result
end
local function native(region, pawn, component, mask, preview)
    assert(require("UEHelpers").GetGameInstance():GetAppVersion():ToString() == "Version 0.8.117",
        "Regional perk commands support only game 0.8.117")
    local folder = load_bridge()
    local request = assert(io.open(folder .. "perks.request", "w"))
    request:write(string.format("MOBS_PERKS_1 %d %d %d %d %d\n", mask, preview and 1 or 0,
        region:GetAddress(), pawn:GetAddress(), component:GetAddress()))
    request:close()
    os.remove(folder .. "perks.response")
    bridge()
    local response = assert(io.open(folder .. "perks.response", "r"), "Perk adapter did not respond")
    local result = response:read("*a"); response:close()
    os.remove(folder .. "perks.request"); os.remove(folder .. "perks.response")
    local a, b, c, d = result:match("^OK (%d+) (%d+) (%d+) (%d+)\n$")
    assert(a, result:gsub("%s+$", ""))
    return {removed1=tonumber(a), removed2=tonumber(b), available1=tonumber(c), available2=tonumber(d)}
end
function M.card_identity(key)
    -- Use the original name for its comparison index. Constructing an FName
    -- from that integer is not a reliable display-name round trip in UE4SS.
    local index = FName(key):GetComparisonIndex()
    local number = 0
    local suffix = key:match("_(%d+)$")
    if suffix and #suffix<=10 and (#suffix==1 or suffix:sub(1,1)~="0") then
        local value = tonumber(suffix)
        if value and value<2147483647 then number=value+1 end
    end
    assert(type(index)=="number" and index>0 and index<=4294967295,
        "Cannot find card name in the game: " .. key)
    return index, number
end
function M.overlay(region, pawn, component, table, cards, preview)
    assert(require("UEHelpers").GetGameInstance():GetAppVersion():ToString() == "Version 0.8.117",
        "Regional perk commands support only game 0.8.117")
    local folder = load_bridge()
    local lines = {string.format("MOBS_PERKS_2 0 %d %d %d %d %d %d\n", preview and 1 or 0,
        region:GetAddress(), pawn:GetAddress(), component:GetAddress(), table:GetAddress(), #cards)}
    for _, card in ipairs(cards) do
        local index, number = M.card_identity(card.key)
        lines[#lines+1] = string.format("%d %d\n", index, number)
    end
    local request = assert(io.open(folder .. "perks.request", "w"))
    request:write(_G.table.concat(lines))
    request:close(); os.remove(folder .. "perks.response"); bridge()
    local response = assert(io.open(folder .. "perks.response", "r"), "Perk adapter did not respond")
    local result = response:read("*a"); response:close()
    os.remove(folder .. "perks.request"); os.remove(folder .. "perks.response")
    local count, effects = result:match("^OVERLAY (%d+) (%d+)\n$")
    assert(count and tonumber(count)==#cards, result:gsub("%s+$", ""))
    return {effects=tonumber(effects)}
end
function M.files()
    local folder = load_bridge()
    os.remove(folder .. "perks.files"); files_bridge()
    local response = assert(io.open(folder .. "perks.files", "r"), "Cannot inspect save metadata")
    local result = response:read("*a"); response:close(); os.remove(folder .. "perks.files")
    local pid = result:match("^OK (%d+)\n")
    assert(pid, result:gsub("%s+$", ""))
    local files = {}
    for slot, stamp in result:gmatch("\n([%w_%-%.]+)%.sav ([%x_]+)") do files[slot]=stamp end
    return {pid=tonumber(pid), files=files}
end
M.state_directory = directory and (directory .. "/Native/State/")
function M.new(get_pawn, get_region, region_label, api, stack)
    api = api or {run=native}
    local self = {}
    local function context()
        local pawn, region = get_pawn(), get_region(true)
        assert(valid(region) and valid(region.ownerPawn) and region.ownerPawn:GetAddress()==pawn:GetAddress(),
            "Choose a region owned by your lord")
        assert(valid(region.PerkComponent), "Region has no perk component")
        return region, pawn, region.PerkComponent
    end
    local function reset(args, name, default)
        assert(#args<=2 and (args[1] or default) and
            (not args[2] or args[2]=="preview"), "Usage: " .. name .. " <1|2|both> [preview]")
        local tier = args[1] or default
        assert(tier=="1" or tier=="2" or tier=="both" or (name=="mobs.respec_perks" and tier=="all"),
            "Choose 1 (Origins), 2 (Rural Foundations), or both")
        -- Replacing Origins also invalidates the later Rural Foundations choice.
        local mask = tier=="2" and 4 or 5
        local region, pawn, component = context()
        local preview = args[2]=="preview"
        local stack_ready = stack and stack.preflight_reset(mask)
        local result = api.run(region, pawn, component, mask, preview)
        local extra = stack_ready and not preview and stack.clear_tiers(mask) or ""
        return string.format("%s: %s Origins=%d, Rural Foundations=%d. " ..
            "%sAvailable choices: tier 1=%d, tier 2=%d. " ..
            "One primary card per tier; mobs.perk_add activates extras. Choose Origins before tier 2. " ..
            "Close and reopen Development. %s", region_label(region),
            preview and "Would reset" or "Reset", result.removed1, result.removed2,
            preview and "Currently " or "", result.available1, result.available2,
            (preview and "Preview changed nothing." or "Previous one-time rewards are not reversed; not undoable.") .. extra)
    end
    function self.register(register)
        register("mobs.perks", "mobs.perks [list|add|remove|clear|search]", function(args)
            if stack then return stack.describe(args) end
            assert(#args==0, "Usage: mobs.perks")
            local region, pawn, component = context()
            local result = api.run(region, pawn, component, 0, true)
            local function card(slot) return component:GetActivePerkInSlot(slot):ToString() end
            return string.format("%s: tier 1 Origins=%s; tier 2 Rural Foundations=%s. Available choices: %d / %d. " ..
                "One choice per tier. mobs.perk_points <1|2|both> reopens a choice; resetting tier 1 resets tier 2 too.",
                region_label(region), card(1), card(3), result.available1, result.available2)
        end, "List/search cards, or use mobs.perks add/remove <card> and mobs.perks clear; preview is supported for changes.")
        register("mobs.perk_points", "mobs.perk_points <1|2|both> [preview]", function(args)
            return reset(args, "mobs.perk_points")
        end, "Restore a regional card choice by resetting that tier; tier 1 also resets tier 2. One card per tier; settlement gates remain.")
        register("mobs.respec_perks", "mobs.respec_perks [1|2|all] [preview]", function(args)
            if #args==1 and args[1]=="preview" then args={"all", "preview"} end
            return reset(args, "mobs.respec_perks", "all")
        end, "Reset regional perk cards and rebuild active effects. Default both tiers; resetting Origins also resets Rural Foundations.")
    end
    return self
end
return M
