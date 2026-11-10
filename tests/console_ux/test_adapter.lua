package.path='src/mobs_console/Scripts/?.lua;' .. package.path
local original_open,original_remove,original_loadlib=io.open,os.remove,package.loadlib
local response='OK 2\r\n'
package.preload.UEHelpers=function() return {GetGameViewportClient=function() return {ViewportConsole={IsValid=function() return true end,GetAddress=function() return 123 end}} end} end
io.open=function(path)
    if path:match('ux_bridge_name.txt$') then return {read=function() return 'mobs_ux_abcdef123456.dll' end,close=function() end} end
    if path:match('ux.response$') then return {read=function() return response end,close=function() end} end
    assert(path:match('ux.request$'))
    return {write=function() return true end,close=function() return true end}
end
os.remove=function() end
package.loadlib=function() return function() end end
local adapter=require('console_autocomplete')
local rows={{command='mobs.pile',description='Place supplies'}}
assert(adapter.install(rows,true)==2,'Windows CRLF response must be accepted')
response='OK 1\n';assert(adapter.install(rows,true)==1)
response='OK 1\nERROR unexpected';assert(not pcall(adapter.install,rows,true),'Trailing protocol garbage must be rejected')
io.open,os.remove,package.loadlib=original_open,original_remove,original_loadlib
print('Console native adapter accepts LF/CRLF and rejects trailing errors')
