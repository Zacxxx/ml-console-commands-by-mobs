package.path = "src/mobs_console/Scripts/?.lua;" .. package.path
local version = "Version 0.8.117"
local timestamp = 0x6836c1ba
local registrations, closed = 0, 0
local blocks = {
    [0x3c] = string.pack("<I4", 0x100), [0x100] = "PE\0\0",
    [0x100 + 24 + 56] = string.pack("<I4", 0x9dfd000),
    [0x4d3cf40] = ("488bc44889580848897010574883ec50488bf10f2970e833"):gsub("..", function(h)
        return string.char(tonumber(h, 16))
    end),
}
local function load_guard()
    local env = setmetatable({
        debug = {getinfo = function() return {source="@C:/Game/ue4ss/Mods/Mobs/Scripts/construction.lua"} end},
        io = {open = function()
            local position
            return {seek=function(_, _, p) position=p; return p end,
                read=function(_, size)
                    local data = position == 0x108 and string.pack("<I4", timestamp) or blocks[position]
                    return data and data:sub(1, size)
                end,
                close=function() closed=closed+1 end}
        end},
        require = function(name)
            assert(name == "UEHelpers")
            return {GetGameInstance=function() return {GetAppVersion=function()
                return {ToString=function() return version end}
            end} end}
        end,
        PropertyTypes={FloatProperty="float"},
        RegisterCustomProperty=function() registrations=registrations+1 end,
    }, {__index=_G})
    return assert(loadfile("src/mobs_console/Scripts/construction.lua", "t", env))()
end
local guard = load_guard()
guard.ensure_layout()
assert(registrations == 2 and closed == 1)
guard.ensure_layout()
assert(registrations == 2 and closed == 1, "Guard must not register duplicate properties")
timestamp = 0
assert(not pcall(load_guard().ensure_layout))
assert(registrations == 2 and closed == 2)
version = "Version 0.8.118"
assert(not pcall(load_guard().ensure_layout))
assert(registrations == 2)
print("Construction binary guard decodes header, closes files and rejects unknown builds")
