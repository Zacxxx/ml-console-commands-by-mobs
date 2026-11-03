-- Copyright 2026 Mobs. MIT licensed. Discovery never guesses and executes a command.
local M={}
local function clean(value)
    local text=tostring(value):gsub('[%c]',' ')
    local finish=math.min(#text,700)
    while finish>0 and text:byte(finish+1) and text:byte(finish+1)>=128 and text:byte(finish+1)<=191 do finish=finish-1 end
    return text:sub(1,finish)
end
local function norm(value) return value:lower():gsub('[^%w]','') end
local function words(value)
    local result={}; for word in value:gmatch('%S+') do result[#result+1]=word end; return result
end
local function distance(a,b)
    local row={}; for j=0,#b do row[j]=j end
    for i=1,#a do
        local next_row={[0]=i}
        for j=1,#b do next_row[j]=math.min(next_row[j-1]+1,row[j]+1,row[j-1]+(a:sub(i,i)==b:sub(j,j) and 0 or 1)) end
        row=next_row
    end
    return row[#b]
end
local function grammar(usage)
    local result,at={},1
    while at<=#usage do
        local ch=usage:sub(at,at)
        if ch==' ' then at=at+1
        elseif ch=='<' or ch=='[' then
            local finish=usage:find(ch=='<' and '>' or ']',at+1,true) or #usage
            result[#result+1]=usage:sub(at,finish); at=finish+1
        else
            local finish=usage:find(' ',at,true) or (#usage+1)
            result[#result+1]=usage:sub(at,finish-1); at=finish
        end
    end
    return result
end
local placeholders={item=true,id=true,amount=true,search=true,name=true,number=true,kind=true,type=true,
    filename=true,command=true,words=true,text=true,scope=true,percent=true}
local function choices(token)
    if not token then return {} end
    local result={}
    for value in token:gsub('^[<%[]',''):gsub('[>%]]$',''):gmatch('[^|]+') do
        if value:match('^[%w_%-]+$') and not placeholders[value] then result[#result+1]=value end
    end
    return result
end
function M.new(commands,api)
    api=api or {}
    local self,history,enabled,last_status={},{},true,'Not initialized; use mobs.autocomplete refresh.'
    local cached,provider_notes=nil,{}
    local discovery={mobs=true,help=true,['mobs.help']=true,['mobs.find']=true,['mobs.usage']=true,
        ['mobs.complete']=true,['mobs.recent']=true,['mobs.autocomplete']=true}
    function self.record(name,args)
        if discovery[name] then return end
        local value=name .. (#args>0 and (' ' .. table.concat(args,' ')) or '')
        if history[#history]~=value then history[#history+1]=clean(value) end
        if #history>30 then table.remove(history,1) end
    end
    function self.history() local copy={}; for i,v in ipairs(history) do copy[i]=v end; return copy end
    function self.find(query)
        query=clean(query):lower(); local needle=norm(query)
        if needle=='' then return {} end
        local result={}
        for name,entry in pairs(commands) do
            local short=name:gsub('^mobs%.',''):lower()
            local hay=(entry.usage .. ' ' .. entry.description):lower()
            local score=0
            for _,word in ipairs(words(query)) do
                local part=norm(word)
                if norm(short)==part then score=score+100
                elseif norm(short):sub(1,#part)==part then score=score+60
                elseif norm(short):find(part,1,true) then score=score+40
                elseif hay:find(word,1,true) then score=score+15 end
            end
            local delta=distance(needle,norm(short))
            if delta<=math.max(1,math.min(3,math.floor(#needle/4))) then score=score+80-delta*10 end
            if score>0 then result[#result+1]={name=name,score=score,entry=entry} end
        end
        table.sort(result,function(a,b) return a.score==b.score and a.name<b.name or a.score>b.score end)
        return result
    end
    function self.suggestions(refresh)
        if cached and not refresh then return cached end
        local result,seen={},{}
        provider_notes={}
        local function add(command,description)
            if #result>=6000 or #command>240 or command:find('[%c]') or seen[command:lower()] then return end
            seen[command:lower()]=true
            result[#result+1]={command=command,description=clean(description)}
        end
        for name,entry in pairs(commands) do
            add(name,entry.usage .. ' - ' .. entry.description)
            local tokens=grammar(entry.usage)
            local function expand(prefix,index)
                if index>5 then return end
                for _,choice in ipairs(choices(tokens[index])) do
                    local value=prefix .. ' ' .. choice
                    add(value,entry.usage .. ' - ' .. entry.description)
                    expand(value,index+1)
                end
            end
            expand(name,2)
        end
        local function provider(label,callback)
            if not api[label] then return end
            local ok,rows=pcall(api[label])
            if ok then callback(rows) else provider_notes[#provider_notes+1]=label .. ' not loaded' end
        end
        provider('items',function(rows)
            for _,item in ipairs(rows) do
                for _,name in ipairs({'mobs.give','mobs.drop','mobs.pile','mobs.inventory_add','mobs.items','mobs.stock','mobs.foreign_supply','mobs.inventory'}) do
                    if commands[name] then
                        local desc=item.name .. ' (ID ' .. item.id .. '). ' .. commands[name].usage
                        add(name .. ' ' .. item.id,desc)
                        local token=norm(item.name)
                        if token~='' then add(name .. ' ' .. token,desc) end
                    end
                end
            end
        end)
        provider('regions',function(rows)
            for _,region in ipairs(rows) do
                if commands['mobs.region'] then add('mobs.region ' .. region.id,'Target owned region: ' .. region.name) end
            end
        end)
        provider('cards',function(rows)
            for _,card in ipairs(rows) do
                for _,name in ipairs({'mobs.perk_add','mobs.perk_remove','mobs.perks_add','mobs.perks_remove'}) do
                    if commands[name] and card.key:match('^[%w_%-]+$') then
                        local desc='Tier ' .. card.tier .. ': ' .. card.label .. '. ' .. commands[name].usage
                        add(name .. ' ' .. card.key,desc)
                        if name=='mobs.perk_add' then add('mobs.perks add ' .. card.key,desc) end
                        if name=='mobs.perk_remove' then add('mobs.perks remove ' .. card.key,desc) end
                    end
                end
            end
        end)
        table.sort(result,function(a,b) return a.command<b.command end)
        cached=result; return result
    end
    function self.refresh(force)
        if not enabled and not force then return 'Autocomplete is off for this mod session.' end
        local rows=self.suggestions(true)
        local ok,result=pcall(function()
            assert(api.install,'Native console adapter missing')
            return api.install(rows,true)
        end)
        last_status=ok and ('Autocomplete on: ' .. result .. ' suggestions. Type mobs. and use Tab; Enter runs the command.')
            or ('Autocomplete unavailable: ' .. clean(result):gsub('^.-:%d+: ','') .. '. Use mobs.complete <text> or mobs.find <words>.')
        if #provider_notes>0 then last_status=last_status .. ' Dynamic data: ' .. table.concat(provider_notes,', ') .. '; refresh after loading/opening Development.' end
        return last_status
    end
    function self.format_error(name,value)
        local message=tostring(value):match('^([^\n]*)') or tostring(value)
        message=message:gsub('^.-%.lua:%d+:%s*','')
        local entry=commands[name]
        return 'ERROR: ' .. message .. (entry and ('\nUsage: ' .. entry.usage .. '\nDetails: mobs.usage ' .. name:gsub('^mobs%.','')) or '')
    end
    local function completion(query)
        query=clean(query):gsub('^%s+','')
        if not query:match('^mobs') then query='mobs.' .. query end
        local result,seen={},{}
        local function add(command,description)
            if not seen[command] then result[#result+1]={command=command,description=description}; seen[command]=true end
        end
        for _,entry in ipairs(self.suggestions()) do
            if entry.command:lower():sub(1,#query)==query:lower() then add(entry.command,entry.description) end
        end
        local tokens=words(query)
        local entry=commands[tokens[1]]
        if entry then
            local supplied=#tokens-1
            local trailing=query:sub(-1)==' '
            local index=trailing and supplied+2 or supplied+1
            local prefix=trailing and '' or tokens[#tokens]
            local base={}; for i=1,(trailing and #tokens or #tokens-1) do base[#base+1]=tokens[i] end
            local tokens_grammar=grammar(entry.usage)
            for _,choice in ipairs(choices(tokens_grammar[index])) do
                if choice:lower():sub(1,#prefix)==prefix:lower() then add(table.concat(base,' ') .. ' ' .. choice,entry.usage) end
            end
            -- The console discards trailing spaces in handler arguments. Offer
            -- next-token literals after a completed numeric placeholder too.
            if not trailing and tonumber(prefix) and #choices(tokens_grammar[index])==0 then
                for _,choice in ipairs(choices(tokens_grammar[index+1])) do add(query .. ' ' .. choice,entry.usage) end
            end
        end
        table.sort(result,function(a,b) return a.command<b.command end)
        if #result==0 then
            local lines={'No prefix matches. Try mobs.find ' .. query:gsub('^mobs%.','')}
            for i,match in ipairs(self.find(query:gsub('^mobs%.',''))) do if i<=3 then lines[#lines+1]='Did you mean: ' .. match.entry.usage end end
            return table.concat(lines,'\n')
        end
        local lines={#result .. ' suggestions (showing up to 12; read only):'}
        for i=1,math.min(12,#result) do lines[#lines+1]=result[i].command .. ' - ' .. result[i].description end
        return table.concat(lines,'\n')
    end
    function self.register(register)
        register('mobs','mobs [command words...]',function(args)
            if #args==0 then
                local total=0; for _ in pairs(commands) do total=total+1 end
                return 'ML Console Commands by Mobs: ' .. total .. ' commands.\n'
                    .. 'Type mobs. for suggestions; Tab completes, Enter runs.\n'
                    .. 'mobs.find <words> - search names and descriptions, including close spellings\n'
                    .. 'mobs.usage <command> - syntax and targeting guidance\n'
                    .. 'mobs.help region | army | lord | misc - browse categories\n'
                    .. 'mobs.regions / mobs.region <id> - choose your target\n'
                    .. 'mobs.cancel - cancel a pending click tool; mobs.recent - last successful commands\n'
                    .. 'Spaces also work: mobs finish constructions preview'
            end
            for length=#args,1,-1 do
                local pieces={}; for i=1,length do pieces[i]=args[i]:lower() end
                local name=table.concat(pieces,'_'):gsub('^mobs%.','')
                name='mobs.' .. name
                if commands[name] then
                    local rest={}; for i=length+1,#args do rest[#rest+1]=args[i] end
                    return commands[name].handler(rest)
                end
            end
            local matches=self.find(table.concat(args,' '))
            local lines={'Unknown command. No action taken. Try mobs.find <words>.'}
            for i=1,math.min(3,#matches) do lines[#lines+1]='Did you mean: ' .. matches[i].entry.usage end
            return table.concat(lines,'\n')
        end,'Quick-start dashboard or run an exact command using spaces; misspellings only suggest, never execute.')
        register('mobs.find','mobs.find <words...>',function(args)
            assert(#args>0,'Enter a word, for example mobs.find construction')
            local matches=self.find(table.concat(args,' '))
            local lines={#matches .. ' matches (showing up to 12):'}
            for i=1,math.min(12,#matches) do lines[#lines+1]=matches[i].entry.usage .. ' - ' .. matches[i].entry.description end
            return table.concat(lines,'\n')
        end,'Ranked multiword and typo-tolerant command search; read only.')
        register('mobs.usage','mobs.usage <command>',function(args)
            assert(#args>0,'Choose a command, for example mobs.usage pile')
            local name=table.concat(args,'_'):lower():gsub('^mobs%.','')
            name=name=='mobs' and 'mobs' or 'mobs.' .. name
            local entry=commands[name]; assert(entry,'Unknown command; use mobs.find ' .. table.concat(args,' '))
            return entry.usage .. '\n' .. entry.description .. '\n'
                .. 'Required arguments: <...>. Optional: [...]. Choices: a|b. Omit the brackets when typing.\n'
                .. (entry.usage:find('item',1,true) and 'Find item IDs with mobs.items <search>. Names can omit spaces (woodenparts).\n' or '')
                .. (entry.description:lower():find('select',1,true) and 'For selected buildings, click them before opening F10.\n' or '')
                .. 'Regional target: mobs.regions, then mobs.region <id>; mobs.region auto restores normal targeting.\n'
                .. (entry.usage:find('preview',1,true) and 'Append preview to inspect the result first.\n' or '')
                .. 'Click tools: close F10 to click/place; mobs.cancel stops pending tools.'
        end,'Explain exact syntax, targeting, previews and click tools without running anything.')
        register('mobs.complete','mobs.complete <partial text...>',function(args)
            assert(#args>0,'Enter a prefix, for example mobs.complete give br')
            return completion(table.concat(args,' '))
        end,'Show contextual completion choices in text; useful if the native dropdown is unavailable.')
        register('mobs.recent','mobs.recent [1..30]',function(args)
            assert(#args<=1,'Usage: mobs.recent [1..30]')
            local count=tonumber(args[1] or '10'); assert(count and count%1==0 and count>=1 and count<=30,'Choose 1..30')
            local lines={'Recent successful commands, newest first (read only; mod session only):'}
            for i=#history,math.max(1,#history-count+1),-1 do lines[#lines+1]=history[i] end
            if #history==0 then lines[#lines+1]='No successful commands recorded yet.' end
            return table.concat(lines,'\n')
        end,'List recent successful Mobs commands without replaying them; keeps 30, cleared on mod reload.')
        register('mobs.autocomplete','mobs.autocomplete [status|refresh|on|off]',function(args)
            assert(#args<=1,'Usage: mobs.autocomplete [status|refresh|on|off]')
            local action=args[1] or 'status'
            if action=='status' then return last_status end
            if action=='off' then
                assert(api.install,'Native console adapter missing'); api.install({},false)
                enabled=false; last_status='Autocomplete off for this mod session. mobs.autocomplete on restores it.'; return last_status
            end
            assert(action=='refresh' or action=='on','Choose status, refresh, on or off')
            if action=='on' then enabled=true end
            return self.refresh()
        end,'Refresh game-data suggestions, inspect status, or enable/disable only our native console suggestions.')
    end
    return self
end
return M
