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

function M.new(get_pawn, region_label)
    local names = {}
    local self = {}

    function self.reset() names = {} end

    local function target_unit()
        local pawn = get_pawn()
        local unit = pawn.hoverUnit
        if not valid(unit) and pawn.followMode then unit = pawn.following end
        local class = StaticFindObject("/Script/ManorLords.SMUnit")
        assert(valid(unit) and valid(class) and unit:IsA(class),
            "Hover a unit before opening the console, or follow one first")
        assert(not unit.dead, "Choose a living unit")
        assert(same(unit.masterPtr, pawn.masterPtr), "Unit belongs to another game world")
        return unit, pawn
    end

    local function own_home(unit, pawn)
        local home = unit.Home
        assert(valid(home) and valid(home.Region) and same(home.Region.ownerPawn, pawn),
            "Renaming requires a unit with a home owned by your lord")
        return home
    end

    function self.register(register)
        register("mobs.unit", "mobs.unit", function(args)
            assert(#args == 0, "Usage: mobs.unit")
            local unit, pawn = target_unit()
            local home = unit.Home
            local home_text = valid(home) and valid(home.Region) and region_label(home.Region) or "none"
            return string.format("Unit=%s | home region=%s | currently followed=%s",
                text(unit.DisplayName), home_text, tostring(pawn.followMode and same(pawn.following, unit)))
        end, "Inspect the hovered unit, or currently followed unit when none is hovered; changes nothing.")

        register("mobs.follow", "mobs.follow [off]", function(args)
            assert(#args == 0 or (#args == 1 and args[1] == "off"), "Usage: mobs.follow [off]")
            if args[1] then
                local pawn = get_pawn()
                -- The native implementation explicitly handles a null target as stop.
                pawn:setFollowMode(nil, false)
                assert(not pawn.followMode, "Game did not stop following")
                return "Camera follow stopped."
            end
            local unit, pawn = target_unit()
            assert(valid(pawn.masterPtr), "Simulation is not loaded")
            local name = text(unit.DisplayName)
            pawn:setFollowMode(unit, false)
            assert(pawn.followMode and same(pawn.following, unit), "Game did not follow the target unit")
            return "Following " .. name .. ". mobs.follow off stops. Native follow may reduce fast-forward speed to normal."
        end, "Follow the hovered unit using the native camera function; off stops. Native follow can normalize game speed.")

        register("mobs.rename_unit", "mobs.rename_unit <new name>", function(args)
            assert(#args > 0, "Usage: mobs.rename_unit <new name>")
            local name = table.concat(args, " "):gsub("^%s+", ""):gsub("%s+$", "")
            local length = utf8.len(name)
            assert(length and length >= 1 and length <= 48 and not name:find("%c"),
                "Use a valid name of 1..48 characters without control characters")
            local unit, pawn = target_unit()
            local home = own_home(unit, pawn)
            local before = text(unit.DisplayName)
            if before == name then return "Unit already has that name; nothing changed." end
            unit.DisplayName = name
            assert(text(unit.DisplayName) == name, "Game did not apply the name")
            names[#names + 1] = {unit = unit, pawn_address = pawn:GetAddress(),
                home = home, before = before, after = name}
            if #names > 10 then table.remove(names, 1) end
            return before .. " -> " .. name .. ". mobs.undo_unit_name can restore it."
        end, "Rename the hovered/followed living unit with an owned home; supports spaces and separate guarded name undo.")

        register("mobs.undo_unit_name", "mobs.undo_unit_name", function(args)
            assert(#args == 0, "Usage: mobs.undo_unit_name")
            local entry = names[#names]
            assert(entry, "No unit rename to undo")
            local pawn = get_pawn()
            assert(pawn:GetAddress() == entry.pawn_address and valid(entry.unit)
                and same(entry.unit.masterPtr, pawn.masterPtr), "Name undo belongs to another game world")
            assert(same(own_home(entry.unit, pawn), entry.home)
                and text(entry.unit.DisplayName) == entry.after,
                "Unit name or home changed since the rename; undo refused")
            entry.unit.DisplayName = entry.before
            assert(text(entry.unit.DisplayName) == entry.before, "Game did not restore the unit name")
            table.remove(names)
            return "Restored unit name: " .. entry.before
        end, "Undo the latest unit rename if its name, home and owner are unchanged; holds ten renames until reload.")
    end

    return self
end

return M
