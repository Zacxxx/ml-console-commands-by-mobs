-- Copyright 2026 Mobs. MIT licensed. Real soil grid edits, separate from fertilization permission.
local access=require('game_access')
local core=require('core')
local M={}
local directory=debug.getinfo(1,'S').source:gsub('^@',''):gsub('\\','/'):match('^(.*)/Scripts/')
local bridge
local function native(pawn,mode,scope,preview,mask,value,buildings)
    assert(require('UEHelpers').GetGameInstance():GetAppVersion():ToString()=='Version 0.8.117',
        'Soil editing supports only game 0.8.117')
    assert(directory,'Cannot locate soil adapter')
    local folder=directory .. '/Native/'
    if not bridge then
        local file=assert(io.open(folder .. 'soil_bridge_name.txt','r'),'Soil adapter missing')
        local name=file:read('*l'); file:close()
        assert(name and name:match('^mobs_soil_%x+%.dll$'),'Invalid soil adapter manifest')
        bridge=assert(package.loadlib(folder .. name,'mobs_soil_run'))
    end
    local file=assert(io.open(folder .. 'soil.request','w'))
    file:write(string.format('MOBS_SOIL_1 %d %d %d %d %d %d %.9g %d\n',
        pawn.masterPtr:GetAddress(),pawn:GetAddress(),mode,scope,preview and 1 or 0,mask,value,#buildings))
    for _,building in ipairs(buildings) do file:write(string.format('%d\n',building:GetAddress())) end
    file:close(); os.remove(folder .. 'soil.response')
    bridge()
    file=assert(io.open(folder .. 'soil.response','r'),'Soil adapter did not respond')
    local response=file:read('*a'); file:close()
    os.remove(folder .. 'soil.request'); os.remove(folder .. 'soil.response')
    if mode==3 and response:match('^PLANTS\n') then
        assert(not response:find('ERROR',1,true),response)
        return response:sub(8)
    end
    local count=response:match('^OK (%d+)\n$')
    assert(count,response:gsub('%s+$',''))
    return tonumber(count)
end
function M.new(get_pawn,api)
    api=api or {run=native}
    local self={}
    function self.register(register)
        register('mobs.plants','mobs.plants',function(args)
            assert(#args==0,'Usage: mobs.plants')
            local pawn=get_pawn()
            return api.run(pawn,3,0,true,7,0,access.selected(pawn))
        end,'Inspect selected buildings planted crops: type, position, growth, yield and soil-cell index; read only, first 100 plants.')
        register('mobs.soil','mobs.soil <set|restore> <wheat|flax|barley|all> [0..100] [selected|area] [preview]',function(args)
            local args,preview=access.preview(args)
            local mode=args[1]
            assert(mode=='set' or mode=='restore','Choose set or restore')
            local masks={wheat=1,flax=2,barley=4,all=7}
            local mask=masks[args[2]]
            assert(mask,'Choose wheat, flax, barley or all; rye shares wheat soil and oats share barley soil')
            local index,value=3,0
            if mode=='set' then value=core.integer(args[index],0,100)/100; index=index+1 end
            local scope=args[index] or 'selected'
            assert((scope=='selected' or scope=='area') and #args<=index,'Usage: mobs.soil <set|restore> <crop|all> [percent for set] [selected|area] [preview]')
            local pawn=get_pawn()
            local buildings=access.selected(pawn)
            if scope=='area' then
                for _,building in ipairs(buildings) do
                    assert(building.workAreaLimited and building.workAreaRange>0,'Set an explicit limited work area on every selected building first')
                end
            end
            local count=api.run(pawn,mode=='set' and 0 or 1,scope=='area' and 1 or 0,preview,mask,value,buildings)
            return string.format('%s%d soil channel(s) %s. %s',preview and 'Preview: ' or '',count,
                preview and 'would change' or 'changed',preview and 'Nothing changed.' or
                'mobs.undo_soil can restore this batch while soil is unchanged. Fertility overlay may refresh later.')
        end,'Set baseline/current soil fertility or restore depletion for selected planted plots or limited work areas; 0..100%, preview and guarded undo.')
        register('mobs.undo_soil','mobs.undo_soil [preview]',function(args)
            local args,preview=access.preview(args)
            assert(#args==0,'Usage: mobs.undo_soil [preview]')
            local count=api.run(get_pawn(),2,0,preview,7,0,{})
            return (preview and 'Preview: would restore ' or 'Restored ') .. count .. ' soil channel(s).'
        end,'Undo the latest soil batch only if all edited values and ownership are unchanged; supports preview.')
    end
    return self
end
return M
