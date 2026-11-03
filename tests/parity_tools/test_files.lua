package.path='src/mobs_console/Scripts/?.lua;' .. package.path
local files=require('command_files')
local commands={['mobs.ping']={handler=function() return 'pong' end},['mobs.run']={}}
assert(#files.parse('# comment\r\nmobs.ping\n',commands)==1)
assert(not pcall(files.parse,'mobs.run nested.txt',commands))
commands.mobs={}
assert(not pcall(files.parse,'mobs run nested.txt',commands))
assert(not pcall(files.parse,'unknown',commands))
assert(not pcall(files.parse,string.rep('mobs.ping\n',101),commands))
local handler,opened
files.register(function(_,_,fn) handler=fn end,commands,function() return {GetAddress=function() return 1 end} end,
    '/commands',function(path) opened=path; return 'mobs.ping\n' end)
assert(not pcall(handler,{'../escape.txt'}))
assert(not opened)
assert(handler({'example.txt','preview'}):find('Preview'))
assert(opened=='/commands/example.txt')
assert(handler({'example.txt'}):find('1/1'))
-- Soil argument parsing and preview are separate from native memory operations.
local calls=0
local b={IsValid=function() return true end,GetAddress=function() return 2 end}
local p={IsValid=function() return true end,GetAddress=function() return 1 end}
b.Region={IsValid=function() return true end,ownerPawn=p}; b.Region.GetAddress=function() return 3 end
p.getSelectedBuildings=function() return {b} end
local soil={}
require('soil_tools').new(function() return p end,{run=function(_,mode,scope,preview,mask,value,buildings)
    assert(mode==0 and scope==0 and preview and mask==7 and value==1 and #buildings==1)
    calls=calls+1; return 3
end}).register(function(n,_,fn) soil[n]=fn end)
assert(soil['mobs.soil']({'set','all','100','preview'}):find('Preview'))
assert(calls==1)
assert(not pcall(soil['mobs.soil'],{'set','all','101'}))
assert(not pcall(soil['mobs.soil'],{'restore','all','area'}))
assert(calls==1)
print('command file and soil parsing checks passed')
