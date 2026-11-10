package.path='src/mobs_console/Scripts/?.lua;' .. package.path
local data=require('command_guides')
local registry={}
local mutations=0
for name in pairs(data.commands) do
    if name~='help' and name~='mobs.advice' and name~='mobs.tutorial' then
        registry[name]={usage=name .. ' [test arguments]',description='Test registration',handler=function() mutations=mutations+1 end}
    end
end
local function register(name,usage,handler,description) registry[name]={usage=usage,description=description,handler=handler} end
require('guidance').register(register,registry)
local aliases=0
for name,entry in pairs(registry) do
    if name:match('^mobs%.advice%.') then
        aliases=aliases+1
        local output=entry.handler({})
        assert(output:find('Target:',1,true) and output:find('How to use:',1,true) and output:find('Examples',1,true))
        assert(output:find('Limits and expected behavior:',1,true) and output:find('Wiki:',1,true))
        assert(not pcall(entry.handler,{'execute'}),'Advice aliases must reject gameplay arguments')
    end
end
assert(aliases==93)
assert(registry['mobs.advice'].handler({'pile'})==registry['mobs.advice.pile'].handler({}))
assert(registry['mobs.advice'].handler({'mobs.pile'})==registry['mobs.advice.pile'].handler({}))
assert(not pcall(registry['mobs.advice'].handler,{'does_not_exist'}))
local tutorial=registry['mobs.tutorial'].handler({'all'})
for i,chapter in ipairs(data.tutorial) do
    assert(tutorial:find(chapter.title,1,true))
    assert(registry['mobs.tutorial'].handler({tostring(i)})==registry['mobs.tutorial'].handler({chapter.key}))
end
assert(not pcall(registry['mobs.tutorial'].handler,{'does_not_exist'}))
assert(mutations==0,'Every guide and tutorial must stay read only')
print('93 advice shortcuts, menu-safe read-only guidance, aliases, validation and 13 tutorial chapters passed')
