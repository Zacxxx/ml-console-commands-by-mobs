-- Copyright 2026 Mobs. MIT licensed. Additional regional perk effects.
local bridge = require("perk_tools")
local M = {}
local function valid(object)
    local ok, value = pcall(function() return object and object:IsValid() end)
    return ok and value
end
local function text(value) return type(value)=="string" and value or value:ToString() end
local function normalized(value) return value:lower():gsub("[^%w]", "") end
local function copy(state)
    local result = {}
    for region, cards in pairs(state) do
        result[region]={}; for i, key in ipairs(cards) do result[region][i]=key end
    end
    return result
end
local function encode(state)
    local rows = {}
    for region, cards in pairs(state) do
        assert(region:match("^%d+$"), "Invalid region in perk state")
        for _, key in ipairs(cards) do
            assert(#key<=192 and not key:find("[%c]"), "Invalid card in perk state")
            rows[#rows+1]=region .. "\t" .. key
        end
    end
    table.sort(rows)
    return "MOBS_PERK_STACK_1\n" .. table.concat(rows,"\n") .. (#rows>0 and "\n" or "")
end
local function decode(raw)
    if not raw then return {} end
    assert(#raw<=1024*1024 and raw:sub(1,18)=="MOBS_PERK_STACK_1\n", "Unreadable perk state; keeping it unchanged")
    local state, seen, total = {}, {}, 0
    for line in raw:sub(19):gmatch("[^\n]+") do
        local region,key = line:match("^(%d+)\t([^%c]+)$")
        assert(region and #key<=192, "Invalid saved perk entry")
        state[region]=state[region] or {}; seen[region]=seen[region] or {}
        assert(not seen[region][key] and #state[region]<64, "Duplicate or excessive saved cards")
        seen[region][key]=true; table.insert(state[region],key)
        total=total+1; assert(total<=4096, "Too many saved perk entries")
    end
    return state
end
local function state_path(key)
    assert(bridge.state_directory and key:match("^[%w_%-]+$") and #key<220, "Invalid perk state path")
    return bridge.state_directory .. key .. ".txt"
end
local function read_state(key)
    local path=state_path(key)
    local file,err,code=io.open(path,"rb")
    if not file then
        assert(code==2,err or "Cannot read perk state")
        file,err,code=io.open(path .. ".bak","rb")
        if not file then assert(code==2,err or "Cannot read perk backup"); return nil end
    end
    local raw=file:read(1024*1024+1); file:close(); return raw
end
local function write_state(key, raw)
    local path=state_path(key)
    local file=assert(io.open(path .. ".tmp","wb"), "Cannot write perk state")
    local ok,err=file:write(raw); local closed,close_error=file:close()
    assert(ok and closed, err or close_error or "Cannot finish perk state write")
    -- Keep the last complete file recoverable across an interrupted replacement.
    local existing=io.open(path,"rb")
    if existing then
        existing:close(); os.remove(path .. ".bak")
        assert(os.rename(path,path .. ".bak"), "Cannot preserve previous perk state")
    end
    local renamed,rename_error=os.rename(path .. ".tmp",path)
    if not renamed then os.rename(path .. ".bak",path) end
    assert(renamed,rename_error)
end
local function catalog()
    local paths={"/Game/UI/Development/DT_RegionDevelopmentTech.DT_RegionDevelopmentTech",
        "/Game/NotStronghold/Data/techList.techList"}
    for _,path in ipairs(paths) do
        local data_table=StaticFindObject(path)
        if valid(data_table) and data_table:GetRowStruct():GetFullName():find("/Script/ManorLords.Tech",1,true) then
            local names,result=data_table:GetRowNames(),{}
            for i=1,#names do
                local key=text(names[i]); local row=data_table:FindRow(key)
                if row and (row.PerkSlot==1 or row.PerkSlot==3) then
                    local label=text(row.PerkName)
                    result[#result+1]={key=key,label=label~="" and label or key,tier=row.PerkSlot==1 and 1 or 2}
                end
            end
            if #result>0 then
                table.sort(result,function(a,b) return a.tier==b.tier and a.key<b.key or a.tier<b.tier end)
                return result,data_table
            end
        end
    end
    error("Regional card data is not loaded; open Development once, then try again")
end
function M.new(get_pawn,get_region,region_label,api)
    api=api or {catalog=catalog,apply=bridge.overlay,files=bridge.files,read=read_state,write=write_state,
        load_slot=function() return text(require("UEHelpers").GetGameInstance().savefileToLoad) end,
        regions=function() return FindAllOf("Region") or {} end}
    local session, last_error
    local self={}
    local handlers={}
    local function owned(region,pawn)
        return valid(region) and valid(region.ownerPawn) and region.ownerPawn:GetAddress()==pawn:GetAddress()
    end
    local function context()
        local pawn=get_pawn(); local region=get_region(true)
        assert(owned(region,pawn) and valid(region.PerkComponent), "Choose a region owned by your lord")
        return region,pawn
    end
    local function ensure()
        local pawn=get_pawn()
        assert(valid(pawn.masterPtr), "Load a settlement first")
        local metadata=api.files()
        local slot=api.load_slot():gsub("\\","/"):match("([^/]+)$") or ""
        slot=slot:gsub("%.sav$", "")
        assert(slot:match("^[%w_%-]+$") and metadata.files[slot],
            "Load a saved game before using extra cards; save and reload a new settlement first")
        local key=string.format("session_%d_%d_%d_%s",metadata.pid,pawn:GetAddress(),pawn.masterPtr:GetAddress(),slot)
        if not session or session.key~=key then
            local raw=api.read(key)
            if not raw then raw=api.read("save_" .. slot .. "_" .. metadata.files[slot]) end
            session={key=key,state=decode(raw),seen=metadata.files,applied={}}
        else
            -- Snapshot extras against completed save writes, including autosaves
            -- and Save As. Also called before every command edits the state.
            for name,stamp in pairs(metadata.files) do
                if session.seen[name]~=stamp then
                    api.write("save_" .. name .. "_" .. stamp,encode(session.state))
                end
            end
            session.seen=metadata.files
        end
        return session,pawn
    end
    local function selected_cards(state,region,rows)
        local index,result={},{}
        for _,row in ipairs(rows) do index[row.key]=row end
        for _,key in ipairs(state[tostring(region:getRegionUniqueID())] or {}) do
            assert(index[key], "Saved card is absent from this game build: " .. key)
            result[#result+1]=index[key]
        end
        return result
    end
    local function signature(region,cards)
        local component=region.PerkComponent
        local parts={tostring(component:GetAddress())}
        for _,slot in ipairs({1,2,3}) do parts[#parts+1]=text(component:GetActivePerkInSlot(slot)) end
        for _,card in ipairs(cards) do parts[#parts+1]=card.key end
        return table.concat(parts,"|")
    end
    local function apply(region,pawn,state,preview)
        local rows,table=api.catalog()
        local cards=selected_cards(state,region,rows)
        local result=api.apply(region,pawn,region.PerkComponent,table,cards,preview)
        if not preview then session.applied[tostring(region:getRegionUniqueID())]=signature(region,cards) end
        return result
    end
    local function commit(region,pawn,next_state)
        apply(region,pawn,next_state,true)
        local previous=session.state
        api.write(session.key,encode(next_state))
        local ok,result=pcall(apply,region,pawn,next_state,false)
        if not ok then
            pcall(api.write,session.key,encode(previous))
            session.applied={}
            error(result)
        end
        session.state=next_state
        return result
    end
    local function resolve(args,rows)
        local tokens,preview={},false
        for i,token in ipairs(args) do
            if token=="preview" and i==#args then preview=true else tokens[#tokens+1]=token end
        end
        local search=normalized(table.concat(tokens," "))
        assert(search~="", "Use a card number or name from mobs.perks list")
        local number=tonumber(search)
        if number and #tokens==1 and tostring(number)==tokens[1] and rows[number] then return rows[number],preview end
        local exact,matches=nil,{}
        for _,row in ipairs(rows) do
            if normalized(row.key)==search or normalized(row.label)==search then
                assert(not exact, "Ambiguous card name; use its number from mobs.perks list")
                exact=row
            end
            if normalized(row.key .. " " .. row.label):find(search,1,true) then matches[#matches+1]=row end
        end
        if exact then return exact,preview end
        assert(#matches==1, #matches==0 and "No matching card; use mobs.perks list" or
            "More than one card matches; use its number from mobs.perks list")
        return matches[1],preview
    end
    function self.describe(args)
        if args[1]=="add" or args[1]=="remove" or args[1]=="clear" then
            local handler=assert(handlers["mobs.perk_" .. args[1]], "Perk commands are not registered yet")
            local rest={}; for i=2,#args do rest[#rest+1]=args[i] end
            return handler(rest)
        end
        local region,pawn=context(); local s=ensure()
        local rows=api.catalog(); local filters={}
        for _,arg in ipairs(args) do if arg~="list" then filters[#filters+1]=arg end end
        local filter=normalized(table.concat(filters," ")); local lines={region_label(region) .. ": regional cards"}
        local extras={}; for _,key in ipairs(s.state[tostring(region:getRegionUniqueID())] or {}) do extras[key]=true end
        for i,row in ipairs(rows) do
            if filter=="" or normalized(row.key .. row.label):find(filter,1,true) then
                local primary=text(region.PerkComponent:GetActivePerkInSlot(row.tier==1 and 1 or 3))==row.key
                lines[#lines+1]=string.format("%d. [Tier %d] %s (%s)%s",i,row.tier,row.label,row.key,
                    primary and " [primary]" or extras[row.key] and " [extra active]" or "")
            end
        end
        lines[#lines+1]="mobs.perks add <number/name> | mobs.perks remove <number/name> | mobs.perks clear"
        lines[#lines+1]="Extras include bonuses AND penalties. Shared effects apply once. Game screen shows primary cards only."
        return table.concat(lines,"\n")
    end
    function self.clear_tiers(mask)
        local region,pawn=context(); local s=ensure(); local state=copy(s.state)
        local id=tostring(region:getRegionUniqueID()); local keep={}; local removed=0
        local rows=api.catalog(); local index={}; for _,row in ipairs(rows) do index[row.key]=row end
        for _,key in ipairs(state[id] or {}) do
            local row=assert(index[key],"Saved card is absent from the game: " .. key)
            if mask==5 or (mask==4 and row.tier==2) then removed=removed+1 else keep[#keep+1]=key end
        end
        state[id]=keep
        -- Reapply retained extras even if the native respec just cleared their cache.
        commit(region,pawn,state)
        return string.format(" Cleared %d extra card(s).",removed)
    end
    function self.preflight_reset(mask)
        local region,pawn=context()
        local ok,s=pcall(ensure)
        if not ok then
            -- A new, unsaved game cannot have stored extras. Preserve the
            -- original primary respec behavior without inventing a save scope.
            if tostring(s):find("Load a saved game",1,true) then return false end
            error(s)
        end
        local state=copy(s.state); local id=tostring(region:getRegionUniqueID())
        local rows=api.catalog(); local keep={}; local index={}
        for _,row in ipairs(rows) do index[row.key]=row end
        for _,key in ipairs(state[id] or {}) do
            local card=assert(index[key],"Saved card missing: " .. key)
            if mask~=5 and not (mask==4 and card.tier==2) then keep[#keep+1]=key end
        end
        state[id]=keep
        apply(region,pawn,state,true)
        return true
    end
    function self.register(register)
        local function command(name,usage,handler,description)
            handlers[name]=handler
            register(name,usage,handler,description)
        end
        command("mobs.perk_add","mobs.perk_add <number|name> [preview]",function(args)
            local region,pawn=context(); local s=ensure(); local rows=api.catalog()
            local card,preview=resolve(args,rows)
            if text(region.PerkComponent:GetActivePerkInSlot(card.tier==1 and 1 or 3))==card.key then
                return card.label .. " is already your primary card; no duplicate added."
            end
            local state=copy(s.state); local id=tostring(region:getRegionUniqueID()); state[id]=state[id] or {}
            for _,key in ipairs(state[id]) do if key==card.key then return card.label .. " is already active." end end
            assert(#state[id]<64,"Maximum 64 extra cards per region")
            state[id][#state[id]+1]=card.key; table.sort(state[id])
            local result=preview and apply(region,pawn,state,true) or commit(region,pawn,state)
            return string.format("%s: %s%s. %d extra card(s), %d distinct active effects. Save normally to keep extras with that save.",
                region_label(region),preview and "Preview: would activate " or "Activated ",card.label,#state[id],result.effects)
        end,"Activate an additional tier 1/2 card without replacing primary cards; includes its penalties. Use mobs.perks list for numbers.")
        command("mobs.perk_remove","mobs.perk_remove <number|name> [preview]",function(args)
            local region,pawn=context(); local s=ensure(); local rows=api.catalog()
            local card,preview=resolve(args,rows); local state=copy(s.state); local id=tostring(region:getRegionUniqueID())
            local keep,found={},false
            for _,key in ipairs(state[id] or {}) do if key==card.key then found=true else keep[#keep+1]=key end end
            assert(found,"That card is not an extra. Use mobs.respec_perks to reset primary cards")
            state[id]=keep
            if preview then apply(region,pawn,state,true) else commit(region,pawn,state) end
            return (preview and "Preview: would remove " or "Removed ") .. card.label .. "; primary cards and shared effects are preserved."
        end,"Remove one extra card and rebuild active effects; preserves primary cards and effects supplied by other cards.")
        command("mobs.perk_clear","mobs.perk_clear [preview]",function(args)
            assert(#args<=1 and (not args[1] or args[1]=="preview"),"Usage: mobs.perk_clear [preview]")
            local region,pawn=context(); local s=ensure(); local state=copy(s.state)
            local id=tostring(region:getRegionUniqueID()); local count=#(state[id] or {}); state[id]={}
            if args[1] then apply(region,pawn,state,true) else commit(region,pawn,state) end
            return string.format("%s%d extra card(s); primary cards preserved.",args[1] and "Preview: would clear " or "Cleared ",count)
        end,"Remove all extra cards in the target region, keeping normal primary cards.")
        for _,action in ipairs({"add","remove","clear"}) do
            local handler=handlers["mobs.perk_" .. action]
            register("mobs.perks_" .. action,"mobs.perks_" .. action ..
                (action=="clear" and " [preview]" or " <number|name> [preview]"),handler,
                "Alias for mobs.perk_" .. action .. "; also accepts mobs.perks " .. action .. ".")
        end
    end
    function self.tick()
        local s,pawn=ensure()
        for _,region in ipairs(api.regions()) do
            if owned(region,pawn) and valid(region.PerkComponent) then
                local id=tostring(region:getRegionUniqueID())
                if s.state[id] and #s.state[id]>0 then
                    local rows=api.catalog(); local cards=selected_cards(s.state,region,rows)
                    if s.applied[id]~=signature(region,cards) then apply(region,pawn,s.state,false) end
                end
            end
        end
    end
    function self.catalog() return api.catalog() end
    function self.reset() session=nil end
    function self.start()
        if not ExecuteWithDelay then return end
        local function loop()
            ExecuteWithDelay(2000,function()
                ExecuteInGameThread(function()
                    local ok,err=pcall(self.tick)
                    if not ok and last_error~=tostring(err) then
                        last_error=tostring(err)
                        -- No loaded save is normal at the menu; actual state/API
                        -- failures remain visible without retry spam.
                        if not last_error:find("Load a settlement",1,true) and
                            not last_error:find("Load a saved game",1,true) then
                            print("[MobsConsole] Extra perk restore paused: " .. last_error .. "\n")
                        end
                    elseif ok then last_error=nil end
                end)
                loop()
            end)
        end
        loop()
    end
    return self
end
M.encode=encode
M.decode=decode
return M
