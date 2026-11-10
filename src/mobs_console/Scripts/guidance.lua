-- Copyright 2026 Mobs. MIT licensed. Shared in-game and wiki guidance.
local data=require('command_guides')
local M={}
function M.short(name) return name:gsub('^mobs%.','') end
function M.resolve(value)
    value=value:lower():gsub('^mobs%.advice%.',''):gsub('^mobs%.','')
    if value=='mobs' then return value end
    return 'mobs.' .. value
end
function M.render(name,entry)
    local guide=assert(data.commands[name],'Guide unavailable; use mobs.help')
    local lines={entry.usage,entry.description,'','Target: ' .. guide.target,'','How to use: ' .. guide.steps,'','Examples (read only):'}
    for _,example in ipairs(guide.examples) do lines[#lines+1]='  ' .. example end
    lines[#lines+1]='';lines[#lines+1]='Limits and expected behavior: ' .. guide.notes
    if #guide.related>0 then
        local related={}
        for _,short in ipairs(guide.related) do related[#related+1]='mobs.advice.' .. short end
        lines[#lines+1]='';lines[#lines+1]='Related: ' .. table.concat(related,', ')
    end
    lines[#lines+1]='Wiki: https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-' .. M.short(name)
    return table.concat(lines,'\n')
end
function M.register(register,commands)
    register('mobs.advice','mobs.advice [command]',function(args)
        assert(#args<=1,'Usage: mobs.advice <command> or mobs.advice.<command>')
        if #args==0 then return 'Detailed, read-only command guides: mobs.advice.<command> or mobs.advice <command>.\nExamples: mobs.advice.pile | mobs.advice.spawn_resource | mobs.advice.soil\nUse mobs.help to find names, or mobs.tutorial for the chapter list.' end
        local name=M.resolve(args[1]);assert(commands[name] and data.commands[name],'Unknown command; use mobs.find')
        return M.render(name,commands[name])
    end,'Read a detailed command guide with targeting, explanations, examples and limits; dotted advice shortcuts also work.')
    register('mobs.tutorial','mobs.tutorial [chapter|all]',function(args)
        assert(#args<=1,'Usage: mobs.tutorial [chapter number|name|all]')
        local choice=(args[1] or ''):lower()
        local lines={'ML Console Commands by Mobs - tutorial (read only; examples never run)'}
        if choice=='' then
            for i,chapter in ipairs(data.tutorial) do lines[#lines+1]=i .. '. ' .. chapter.key .. ' - ' .. chapter.title end
            lines[#lines+1]='Read one: mobs.tutorial 1 or mobs.tutorial resources. Full tutorial: mobs.tutorial all.'
            lines[#lines+1]='Wiki: https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki'
            return table.concat(lines,'\n')
        end
        local found=false
        for i,chapter in ipairs(data.tutorial) do
            if choice=='all' or choice==tostring(i) or choice==chapter.key then
                found=true;lines[#lines+1]='';lines[#lines+1]=i .. '. ' .. chapter.title
                for _,paragraph in ipairs(chapter.paragraphs) do lines[#lines+1]=paragraph end
                lines[#lines+1]='Guides: ' .. table.concat(chapter.guides,', ')
            end
        end
        assert(found,'Unknown chapter; mobs.tutorial lists all chapter names')
        return table.concat(lines,'\n')
    end,'Read the tutorial chapter index, a numbered/named chapter, or the complete tutorial with all.')
    local names={}
    for name in pairs(commands) do if name~='help' then names[#names+1]=name end end
    table.sort(names)
    for _,name in ipairs(names) do
        assert(data.commands[name],'Missing detailed guide: ' .. name)
        local alias='mobs.advice.' .. M.short(name)
        register(alias,alias,function(args)
            assert(#args==0,'This is a read-only guide; use ' .. name .. ' for the actual command')
            return M.render(name,commands[name])
        end,'Detailed guide for ' .. name .. '; explains targeting, examples and limits without running it.')
        commands[alias].hidden=true
    end
end
return M
