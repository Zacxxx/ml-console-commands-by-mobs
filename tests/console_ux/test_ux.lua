package.path='src/mobs_console/Scripts/?.lua;' .. package.path
local ux=require('console_ux')
local commands,ran={},0
local native_calls={}
local ui=ux.new(commands,{install=function(rows,on) native_calls[#native_calls+1]={rows=rows,on=on}; return #rows end,
    items=function() return {{id=3,name='Bread'},{id=7,name='Wooden Parts'}} end,
    regions=function() return {{id=99,name='My Region'}} end,
    cards=function() return {{key='BambergSmallholders',label='Bamberg',tier=1}} end})
local function register(name,usage,handler,description)
    commands[name]={usage=usage,description=description or '',handler=function(args)
        local value=handler(args); ui.record(name,args); return value
    end}
end
register('mobs.finish_constructions','mobs.finish_constructions [preview]',function(args) ran=ran+1; return table.concat(args,',') end,'Finish regional construction')
register('mobs.give','mobs.give <item|id> <amount> [preview]',function() ran=ran+1 end,'Supply selected buildings')
register('mobs.treasury','mobs.treasury <set|add> <amount>',function() ran=ran+1 end,'Change money')
register('mobs.region','mobs.region [id|current|selected|auto]',function() end,'Choose region')
register('mobs.perk_add','mobs.perk_add <number/name>',function() end,'Extra regional card')
ui.register(register)
assert(ui.find('finish buildings')[1].name=='mobs.finish_constructions' or ui.find('finish buildings')[1].name=='mobs.give')
assert(ui.find('finsh_constructions')[1].name=='mobs.finish_constructions')
assert(commands['mobs'].handler({'finish','constructions','preview'})=='preview' and ran==1)
assert(commands['mobs'].handler({'finsh_constructions'}):find('mobs.finish_constructions',1,true) and ran==1)
assert(commands['mobs'].handler({}):find('mobs.find',1,true))
assert(commands['mobs.usage'].handler({'treasury'}):find('<set|add>',1,true) and ran==1)
assert(commands['mobs.find'].handler({'construction'}):find('mobs.finish_constructions',1,true) and ran==1)
local result=commands['mobs.complete'].handler({'mobs.give','wo'})
assert(result:find('mobs.give woodenparts',1,true) and result:find('Wooden Parts',1,true))
assert(commands['mobs.complete'].handler({'mobs.give','bread','100','p'}):find('mobs.give bread 100 preview',1,true))
assert(commands['mobs.complete'].handler({'mobs.give','bread','100'}):find('mobs.give bread 100 preview',1,true))
assert(not commands['mobs.complete'].handler({'mobs.g'}):find('mobs.give bread',1,true), 'Partial command prefixes must not show item variants')
assert(commands['mobs.complete'].handler({'mobs.give'}):find('mobs.give bread',1,true))
local count=ui.refresh()
assert(type(count)=='string' and #native_calls==1 and native_calls[1].on)
local seen={}
for _,row in ipairs(native_calls[1].rows) do seen[row.command]=row.description end
assert(seen['mobs.treasury add'] and seen['mobs.finish_constructions preview'])
assert(seen['mobs.give woodenparts'] and seen['mobs.give 3'])
assert(seen['mobs.region 99']:find('My Region',1,true))
assert(seen['mobs.perk_add BambergSmallholders'])
assert(not seen['mobs.give item'] and not seen['mobs.give id'] and not seen['mobs.region id'])
assert(commands['mobs.autocomplete'].handler({'off'}):find('off') and native_calls[2].on==false)
local previous=#native_calls
ui.refresh(); assert(#native_calls==previous,'Loading a save must respect session off')
commands['mobs.autocomplete'].handler({'on'}); assert(#native_calls==previous+1)
local before=#ui.history()
ui.record('mobs.ping',{}); ui.record('mobs.ping',{})
assert(#ui.history()==before+1,'Consecutive duplicates are collapsed')
for i=1,60 do ui.record('mobs.give',{'bread',tostring(i)}) end
assert(#ui.history()==30)
local history=ui.history(); history[1]='tampered'; assert(ui.history()[1]~='tampered')
local error_text=ui.format_error('mobs.give','some/private/path.lua:99: Choose a building owned by your lord')
assert(not error_text:find('path.lua',1,true) and error_text:find('Usage: mobs.give',1,true))
assert(ran==1,'Discovery/completion must never execute gameplay commands')
local unavailable=ux.new(commands,{install=function() error('unsupported binary') end,items=function() error('not loaded') end})
assert(unavailable.refresh():find('unavailable'))
assert(#unavailable.suggestions()>0,'Static suggestions work without loaded data')
print('Console UX routing, typo search, contextual completion, isolation and history passed')
