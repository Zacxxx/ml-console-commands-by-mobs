package.path = "src/mobs_console/Scripts/?.lua;" .. package.path
local registry, logs = {}, {}
local region, pawn, controller
region = {regionalWealth = 200, regionName = {ToString = function() return "Test Region" end}}
pawn = {silver = 50, influence = 100, selectedRegion = region}
region.ownerPawn = pawn
region.getRegionUniqueID = function() return 1 end
controller = {Pawn = pawn}
for i, object in ipairs({region, pawn, controller}) do
    object.IsValid = function() return true end
    object.GetAddress = function() return i end
end
pawn.IsA = function() return true end
pawn.ChangeTreasury = function(self, amount) self.silver = self.silver + amount end
pawn.changeInfluence = function(self, amount) self.influence = self.influence + amount end
region.addRegionalWealth = function(self, amount) self.regionalWealth = self.regionalWealth + amount end
package.preload.UEHelpers = function() return {GetPlayerController = function() return controller end} end
StaticFindObject = function() return {} end
RegisterConsoleCommandGlobalHandler = function(name, fn) registry[name] = fn end
local reset
Key = {LEFT_MOUSE_BUTTON = 1}
RegisterKeyBind = function() end
RegisterHook = function(_, fn) reset = fn end
local background_timers, autocomplete_timers = {}, {}
local pending_autocomplete = 0
ExecuteWithDelay = function() error("Startup must not queue async Lua work") end
ExecuteInGameThread = function() error("Startup must not hand async callbacks to the game thread") end
LoopInGameThreadWithDelay = function(delay, callback)
    assert(not background_timers[delay], "Background timer already registered")
    background_timers[delay] = callback
    return delay
end
ExecuteInGameThreadWithDelay = function(delay, callback)
    assert(delay == 1500)
    pending_autocomplete = pending_autocomplete + 1
    autocomplete_timers[pending_autocomplete] = callback
    return pending_autocomplete
end
CancelDelayedAction = function(handle)
    assert(autocomplete_timers[handle], "Unknown autocomplete timer")
    autocomplete_timers[handle] = nil
end
dofile("src/mobs_console/Scripts/main.lua")
assert(background_timers[2000] and background_timers[2500])
assert(autocomplete_timers[1])
local device = {Log = function(_, message) logs[#logs + 1] = message end}
local function run(name, args) assert(registry[name](name, args or {}, device)) end
run("mobs.treasury", {"add", "25"})
assert(pawn.silver == 75)
run("mobs.undo")
assert(pawn.silver == 50)
run("mobs.influence", {"set", "1000"})
assert(pawn.influence == 1000)
pawn.influence = 1001
run("mobs.undo")
assert(pawn.influence == 1001 and logs[#logs]:find("refused"))
run("mobs.wealth", {"add", "10"})
assert(region.regionalWealth == 210)
run("mobs.treasury", {"set", "nan"})
assert(pawn.silver == 50 and logs[#logs]:find("ERROR"))
region.ownerPawn = controller
run("mobs.wealth", {"set", "1000"})
assert(region.regionalWealth == 210 and logs[#logs]:find("owned"))
reset()
assert(not autocomplete_timers[1] and autocomplete_timers[2])
run("mobs.undo")
assert(logs[#logs]:find("No Mobs economy"))
run("mobs.help", {"treasury"})
assert(logs[#logs]:find("mobs.treasury <set|add> <amount>", 1, true))
assert(registry.help, "The plain help command must be registered")
run("help")
for name in pairs(registry) do
    if not name:match("^mobs%.advice%.") then
        assert(logs[#logs]:find(name, 1, true), "Help is missing registered command " .. name)
    end
end
run("help", {"no_such_command"})
assert(logs[#logs]:find("No matching"))
run("help", {"treasury", "extra"})
assert(logs[#logs]:find("Usage"))
run("mobs", {"treasury", "add", "5"})
assert(pawn.silver == 55)
run("mobs.recent")
assert(logs[#logs]:find("mobs.treasury add 5",1,true))
run("mobs", {"treasry", "add", "500"})
assert(pawn.silver == 55 and logs[#logs]:find("Did you mean",1,true))
run("mobs.treasury", {"set", "wrong"})
assert(logs[#logs]:find("Usage: mobs.treasury",1,true) and not logs[#logs]:find(".lua:",1,true))
controller.Pawn = nil
run("mobs.treasury", {"set", "10"})
assert(logs[#logs]:find("settlement"))
print("Command behavior, undo conflicts, ownership, and unloaded-world checks passed")
