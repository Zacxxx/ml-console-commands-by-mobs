-- Export the real registry with a mocked engine; no game process or commands run.
package.path='src/mobs_console/Scripts/?.lua;' .. package.path
local registry
local ux=require('console_ux')
local original_new=ux.new
ux.new=function(commands,api) registry=commands; return original_new(commands,api) end
package.preload.UEHelpers=function() return {} end
StaticFindObject=function() return {IsValid=function() return false end} end
Key={LEFT_MOUSE_BUTTON=1}
RegisterKeyBind=function() end
RegisterHook=function() end
RegisterConsoleCommandGlobalHandler=function() end
print=function() end
dofile('src/mobs_console/Scripts/main.lua')
local categories=require('command_categories')
local names={}; for name,entry in pairs(registry) do if not entry.hidden then names[#names+1]=name end end
table.sort(names)
for _,name in ipairs(names) do
    local entry=registry[name]
    local function cell(value) return value:gsub('[\t\r\n]',' ') end
    io.write(cell(name),'\t',categories.get(name),'\t',cell(entry.usage),'\t',cell(entry.description),'\n')
end
