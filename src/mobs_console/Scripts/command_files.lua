-- Copyright 2026 Mobs. MIT licensed. Bounded local command lists, no Lua/shell execution.
local M={}
function M.parse(content,commands)
    assert(#content<=65536,'Command file exceeds 64 KiB')
    local result={}
    for line in (content .. '\n'):gmatch('(.-)\n') do
        line=line:gsub('\r$',''):match('^%s*(.-)%s*$')
        if line~='' and not line:match('^#') and not line:match('^%-%-') then
            assert(not line:find('[%z\1-\8\11\12\14-\31]'),'Control character in command file')
            local words={}
            for word in line:gmatch('%S+') do words[#words+1]=word end
            local name=table.remove(words,1)
            assert(commands[name], 'Unknown command: ' .. tostring(name))
            assert(name~='mobs.run','Nested command files are not supported')
            assert(name~='mobs','Use direct mobs.command syntax in files; root dispatch is console-only')
            result[#result+1]={name=name,args=words,line=line}
            assert(#result<=100,'At most 100 commands per file')
        end
    end
    assert(#result>0,'Command file contains no commands')
    return result
end
function M.register(register,commands,get_pawn,folder,read)
    local running=false
    read=read or function(path)
        local file=assert(io.open(path,'rb'),'Cannot open command file')
        local content=file:read(65537); file:close()
        return content or ''
    end
    register('mobs.run','mobs.run <filename.txt> [preview]',function(args)
        assert((#args==1 or (#args==2 and args[2]=='preview')),'Usage: mobs.run <filename.txt> [preview]')
        assert(#args[1]<=80 and args[1]:match('^[%w_-]+%.txt$'),'Use a simple .txt filename in this mod\'s Commands folder')
        assert(not running,'Command file is already running')
        local entries=M.parse(read(folder .. '/' .. args[1]),commands)
        if args[2]=='preview' then
            local lines={'Preview: ' .. #entries .. ' registered command(s); arguments and gameplay preconditions are checked only when executed:'}
            for i,entry in ipairs(entries) do lines[#lines+1]=i .. '. ' .. entry.line end
            return table.concat(lines,'\n')
        end
        local pawn=get_pawn():GetAddress()
        running=true
        local lines,completed={},0
        for index,entry in ipairs(entries) do
            local ok,message=pcall(function()
                assert(get_pawn():GetAddress()==pawn,'Settlement changed')
                return commands[entry.name].handler(entry.args)
            end)
            if not ok then
                local entry_command=commands[entry.name]
                local reason=entry_command.format_error and entry_command.format_error(message) or tostring(message)
                lines[#lines+1]='Stopped at line ' .. index .. ': ' .. reason .. '. Earlier changes remain.'
                break
            end
            completed=completed+1
            lines[#lines+1]=entry.name .. ': ' .. tostring(message or 'Done')
        end
        running=false
        return completed .. '/' .. #entries .. ' commands executed.\n' .. table.concat(lines,'\n')
    end,'Run up to 100 Mobs commands from a local Commands/*.txt file; no scripts, traversal or recursion; preview lists commands; stop on first error.')
end
return M
