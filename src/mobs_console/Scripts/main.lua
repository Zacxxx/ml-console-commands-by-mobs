-- ML Console Commands by Mobs, experimental.
-- Original Lua implementation. Does not contain or require Psiae's DLL.
local core = require("core")
local helpers = require("UEHelpers")
local construction = require("construction")
local supplies = require("supplies")
local town_tools = require("town_tools")
local resources = require("resources")
local original_features = require("original_features")
local unit_tools = require("unit_tools")
local field_tools = require("field_tools")
local pile_tools = require("pile_tools")
local forestry = require("forestry")
local perk_tools = require("perk_tools")
local perk_stack = require("perk_stack")
local parity_tools = require('parity_tools')
local soil_tools = require('soil_tools')
local command_files = require('command_files')
local categories = require('command_categories')
local undo = {}
local commands = {}
local VERSION = "0.14.0-alpha.1"

local function valid(object)
    local ok, result = pcall(function() return object and object:IsValid() end)
    return ok and result
end

local function context()
    local controller = helpers.GetPlayerController()
    assert(valid(controller), "Load a settlement first")
    local pawn = controller.Pawn
    assert(valid(pawn) and pawn:IsA(StaticFindObject("/Script/ManorLords.PawnCPP")),
        "Load a settlement first")
    return pawn
end

local town = town_tools.new(context)
local region_context = town.region
local deposits = resources.new(context, region_context, town.region_label)
local units = unit_tools.new(context, town.region_label)
local fields_tools = field_tools.new(context, region_context, town.region_label)
local stacked_perks = perk_stack.new(context, region_context, town.region_label)

local function output(device, message)
    message = tostring(message)
    print("[MobsConsole] " .. message .. "\n")
    if device then pcall(function() device:Log(message) end) end
end

local delivery = supplies.new(context, function(message)
    output(nil, message)
    pcall(function()
        helpers.GetPlayerController():ClientMessage("[Mobs] " .. message, FName("None"), 6.0)
    end)
end)

local forest = forestry.new(context, region_context, town.region_label, function(message)
    output(nil, message)
    pcall(function()
        helpers.GetPlayerController():ClientMessage("[Mobs] " .. message, FName("None"), 8.0)
    end)
end)

local function notify(message)
    output(nil,message)
    pcall(function() helpers.GetPlayerController():ClientMessage('[Mobs] ' .. message,FName('None'),8.0) end)
end
local parity = parity_tools.new(context,region_context,town.region_label,notify)
parity.before_arm=function() delivery.cancel(); forest.cancel() end

local underground = require('deposit_tools').new(context,parity.arm)

local ux=require('console_ux').new(commands,{
    install=require('console_autocomplete').install,
    items=delivery.catalog,regions=town.region_choices,cards=stacked_perks.catalog,
})
local function register(name, usage, handler, description)
    local function tracked(args)
        local result=handler(args)
        ux.record(name,args)
        return result
    end
    commands[name] = {usage = usage, handler = tracked, description = description or "",
        format_error=function(value) return ux.format_error(name,value) end}
    RegisterConsoleCommandGlobalHandler(name, function(_, parameters, device)
        local ok, result = pcall(tracked, parameters)
        output(device, ok and (result or "Done") or ux.format_error(name,result))
        return true
    end)
end

local fields = {
    treasury = {property = "silver", method = "ChangeTreasury"},
    influence = {property = "influence", method = "changeInfluence"},
    wealth = {property = "regionalWealth", method = "addRegionalWealth", regional = true},
    approval = {property = "Approval", regional = true, maximum = 100},
}

for label, descriptor in pairs(fields) do
    register("mobs." .. label, "mobs." .. label .. " <set|add> <amount>", function(args)
        assert(#args == 2, "Usage: mobs." .. label .. " <set|add> <amount>")
        local amount = core.integer(args[2], -100000000, 100000000)
        local object = descriptor.regional and region_context(true) or context()
        local target = descriptor.regional and (label .. " in " .. town.region_label(object)) or label
        local before = object[descriptor.property]
        local after = core.target(before, args[1], amount)
        if descriptor.maximum then after = core.integer(after, 0, descriptor.maximum) end
        if descriptor.method then
            object[descriptor.method](object, after - before)
        else
            object[descriptor.property] = after
        end
        assert(object[descriptor.property] == after, "Game did not apply the requested value")
        undo[#undo + 1] = {object = object, property = descriptor.property,
            method = descriptor.method, before = before, after = after,
            pawn_address = context():GetAddress()}
        if #undo > 30 then table.remove(undo, 1) end
        return string.format("%s: %d -> %d. mobs.undo can restore this change.", target, before, after)
    end, label == "approval" and "Set/add current approval (0..100); game may recalculate it. Records an undo step."
        or ("Change " .. label .. "; records an economy undo step."))
end

register("mobs.undo", "mobs.undo", function(args)
    assert(#args == 0, "Usage: mobs.undo")
    local entry = undo[#undo]
    assert(entry, "No Mobs economy change to undo")
    local pawn = context()
    assert(pawn:GetAddress() == entry.pawn_address and valid(entry.object),
        "Undo belongs to a previous settlement; reload clears undo")
    assert(entry.object[entry.property] == entry.after,
        "Value changed since that command; undo refused to overwrite newer changes")
    if entry.method then
        entry.object[entry.method](entry.object, entry.before - entry.after)
    else
        entry.object[entry.property] = entry.before
    end
    assert(entry.object[entry.property] == entry.before, "Game did not restore the value")
    table.remove(undo)
    return string.format("Restored %s: %d -> %d", entry.property, entry.after, entry.before)
end, "Undo the last economy edit unless its value has changed since.")

register("mobs.status", "mobs.status", function(args)
    assert(#args == 0, "Usage: mobs.status")
    local pawn = context()
    local info = string.format("Treasury=%d Influence=%d", pawn.silver, pawn.influence)
    local ok, region = pcall(region_context, true)
    if ok then
        info = info .. string.format(" Target=%s Wealth=%d Approval=%d", town.region_label(region),
            region.regionalWealth, region.Approval)
    else
        info = info .. " | No owned region target; use mobs.regions / mobs.region <id>."
    end
    return info
end, "Show your lord's balances and the command target region's wealth.")

register("mobs.version", "mobs.version", function(args)
    assert(#args == 0, "Usage: mobs.version")
    return "ML Console Commands by Mobs " .. VERSION .. "; target 0.8.117; experimental"
end, "Show the installed Mobs version and supported target.")

register("mobs.drop", "mobs.drop [item|id amount]", function(args)
    assert(#args == 0 or #args == 2, "Usage: mobs.drop <item|id> <amount>, or mobs.drop for status")
    if #args == 0 then return delivery.status() end
    forest.cancel()
    parity.cancel()
    return delivery.arm(args[1], args[2])
end, "Deliver to clicked owned storage or supply needed construction materials. No arguments shows status.")

register("mobs.pile", "mobs.pile <item|id> <amount>", function(args)
    assert(#args == 2, "Usage: mobs.pile <item|id> <amount>")
    forest.cancel()
    parity.cancel()
    return delivery.arm_pile(args[1], args[2])
end, "Experimental: enter native Supplies placement and fill the newly placed pile; owned region only.")

register("mobs.give", "mobs.give <item|id> <amount> [preview]", function(args)
    assert((#args == 2 or #args == 3) and (not args[3] or args[3] == "preview"),
        "Usage: mobs.give <item|id> <amount> [preview]")
    return delivery.give(args[1], args[2], args[3] == "preview")
end, "Deliver up to this amount to EACH selected owned storage building or construction site (max 32); supports preview.")

register("mobs.inventory_add", "mobs.inventory_add <item|id> <amount> [preview]", function(args)
    assert(#args==2 or (#args==3 and args[3]=='preview'), 'Usage: mobs.inventory_add <item|id> <amount> [preview]')
    return delivery.give(args[1],args[2],args[3]=='preview',true)
end, 'Add goods to EACH selected owned building, including production/housing (maximum 32); bypass completed-building storage limits. Construction sites receive only needed materials; preview available.')

register("mobs.cancel", "mobs.cancel", function(args)
    assert(#args == 0, "Usage: mobs.cancel")
    local cancelled = forest.cancel()
    local parity_cancelled = parity.cancel()
    local result = delivery.cancel()
    if parity_cancelled then return "Click tool cancelled; completed changes remain." end
    return cancelled and "Forestry cancelled; no further clicks or growth batches. Completed changes remain." or result
end, "Cancel pending supply/forestry tools or further tree-growth batches; completed changes remain.")

register("mobs.items", "mobs.items [search]", function(args)
    assert(#args <= 1, "Usage: mobs.items [search]")
    return delivery.items(args[1])
end, "List supply item IDs and names from the loaded game's item table; optionally filter.")

register("mobs.finish_constructions", "mobs.finish_constructions [preview]", function(args)
    assert(#args <= 1 and (not args[1] or args[1] == "preview"),
        "Usage: mobs.finish_constructions [preview]")
    local region = region_context(true)
    local result = construction.prepare(region, args[1] == "preview")
    local name = region.regionName:ToString()
    if args[1] == "preview" then
        return string.format("%s: %d unfinished constructions; preview changed nothing.", name, result.pending)
    end
    return string.format("%s: prepared %d/%d constructions for normal simulation completion. Resume if paused; workers may need to reach the sites. "
        .. "Supplies missing materials; not undoable. %d failures.%s", name, result.prepared,
        result.pending, #result.failures, result.failures[1] and (" " .. result.failures[1]) or "")
end, "Finish construction work in the selected/current owned region and let the game finalize sites during simulation; preview lists the count.")

local function show_help(args)
    assert(#args <= 1, "Usage: help [search] or mobs.help [search]")
    local filter = string.lower(args[1] or "")
    local lines = {}
    for name, entry in pairs(commands) do
        if categories.matches(name,entry,filter) then
            lines[#lines + 1] = entry.usage .. " - " .. entry.description
        end
    end
    table.sort(lines)
    return #lines > 0 and ("ML Console Commands by Mobs (" .. #lines .. " matching commands):\n"
        .. table.concat(lines, "\n")) or "No matching Mobs commands"
end

town.register(register)
deposits.register(register)
original_features.register(register, context, region_context, town.region_label, town.item_name, VERSION)
units.register(register)
fields_tools.register(register)
perk_tools.new(context, region_context, town.region_label, nil, stacked_perks).register(register)
stacked_perks.register(register)
pile_tools.new(context, region_context, town.region_label).register(register)
forest.register(function(name, usage, handler, description)
    register(name, usage, function(args)
        if name ~= "mobs.grow_trees" and name ~= "mobs.grow_saplings" and name ~= "mobs.grow_stage" then delivery.cancel(); parity.cancel() end
        return handler(args)
    end, description)
end)

parity.register(function(name,usage,handler,description)
    register(name,usage,function(args)
        if name=='mobs.animal' or name=='mobs.raiders' then delivery.cancel(); forest.cancel() end
        return handler(args)
    end,description)
end)
underground.register(function(name,usage,handler,description)
    register(name,usage,function(args)
        if name=='mobs.deposit' then delivery.cancel(); forest.cancel() end
        return handler(args)
    end,description)
end)
soil_tools.new(context).register(register)
require('world_tools').new(context,parity.arm).register(register)
require('teleport_tools').register(function(name,usage,handler,description)
    register(name,usage,function(args) delivery.cancel(); forest.cancel(); return handler(args) end,description)
end,context,parity.arm)
require('game_ui_tools').register(register,context,parity.arm,function()
    delivery.cancel(); forest.cancel(); parity.cancel()
end)
local mod_directory=debug.getinfo(1,'S').source:gsub('^@',''):gsub('\\','/'):match('^(.*)/Scripts/')
command_files.register(register,commands,context,(mod_directory or '.') .. '/Commands')

ux.register(register)

register("mobs.help", "mobs.help [search]", show_help, "List all commands; filter by army, lord, region, misc, or search usage/descriptions.")
register("help", "help [search]", show_help, "Alias for mobs.help.")

local function refresh_autocomplete()
    if ExecuteWithDelay and ExecuteInGameThread then
        ExecuteWithDelay(1500,function()
            ExecuteInGameThread(function()
                local ok,result=pcall(ux.refresh)
                output(nil,ok and result or ('Autocomplete refresh failed: ' .. tostring(result)))
            end)
        end)
    end
end

RegisterHook("/Script/Engine.PlayerController:ClientRestart", function()
    undo = {}
    delivery.reset()
    town.reset()
    deposits.reset()
    units.reset()
    fields_tools.reset()
    forest.reset()
    stacked_perks.reset()
    parity.reset()
    underground.reset()
    refresh_autocomplete()
end)

stacked_perks.start()
refresh_autocomplete()
print("[MobsConsole] " .. VERSION .. " loaded. Open F10 and enter mobs\n")
