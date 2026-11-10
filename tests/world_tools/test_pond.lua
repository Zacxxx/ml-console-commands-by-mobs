package.path = 'src/mobs_console/Scripts/?.lua;' .. package.path
local function object(id, fields)
    fields = fields or {}
    fields.IsValid = function() return true end
    fields.GetAddress = function() return id end
    return fields
end
local pawn = object(1)
local region = object(2, {ownerPawn=pawn})
local engine = object(3)
local commands, calls, armed = {}, {}, nil
package.loaded.UEHelpers = {GetGameInstance=function()
    return {GetAppVersion=function() return {ToString=function() return 'Version 0.8.117' end} end}
end}
local definition = {DisplayName='Fishing Pond'}
StaticFindObject = function()
    return object(4, {FindRow=function(_, row) assert(row=='39'); return definition end})
end
local cancelled = 0
require('game_ui_tools').register(function(name, _, handler) commands[name]=handler end,
    function() return pawn end,
    function(label, callback, owned)
        armed={label=label,callback=callback,owned=owned}
        return 'armed'
    end,
    function() cancelled=cancelled+1 end,
    {preview={start=function(current,row,preview,strict)
        assert(current==pawn and row==definition)
        calls[#calls+1]={preview=preview,strict=strict}
        return 'visual preview'
    end}})

-- Placement uses its own non-building visual tool; removal keeps the normal click arm.
assert(commands['mobs.pond']({'place','preview'})=='visual preview')
assert(calls[1].preview and armed==nil and cancelled==1)
calls={}
assert(commands['mobs.pond']({'place'})=='visual preview')
assert(not calls[1].preview and not calls[1].strict and armed==nil and cancelled==2)
commands['mobs.pond']({'place','strict','preview'})
assert(calls[2].preview and calls[2].strict)
assert(not pcall(commands['mobs.pond'],{'remove','strict'}))
assert(not pcall(commands['mobs.pond'],{'place','strict','strict'}))
commands['mobs.pond']({'remove','preview'})
assert(armed.label=='Pond removal')
-- A mismatched table definition must refuse before arming or creating anything.
calls={}; armed=nil; definition.DisplayName='Unrelated building'
assert(not pcall(commands['mobs.pond'],{'place'}))
assert(armed==nil and #calls==0)
assert(not pcall(commands['mobs.pond'],{'place','500'}))
print('Pond placement uses the visual tool, preserves removal and rejects incompatible definitions')
