-- Copyright 2026 Mobs. MIT licensed. Registered world resources for game 0.8.117.
local access=require('game_access')
local core=require('core')
local M={}
local KINDS={salt=1,iron=2,clay=3,fish=5,berries=6,stone=7,mushrooms=9,eel=11}
local directory=debug.getinfo(1,'S').source:gsub('^@',''):gsub('\\','/'):match('^(.*)/Scripts/')
local bridge
local function native(pawn,request)
    assert(require('UEHelpers').GetGameInstance():GetAppVersion():ToString()=='Version 0.8.117',
        'World editing currently supports game 0.8.117 only')
    local folder=assert(directory,'Cannot locate world adapter') .. '/Native/'
    if not bridge then
        local file=assert(io.open(folder .. 'world_bridge_name.txt','r'),'World adapter missing')
        local name=file:read('*l');file:close()
        assert(name and name:match('^mobs_world_%x+%.dll$'),'Invalid world adapter manifest')
        bridge=assert(package.loadlib(folder .. name,'mobs_world_run'))
    end
    local pos=request.at or {X=0,Y=0,Z=0}
    local file=assert(io.open(folder .. 'world.request','w'))
    file:write(string.format('MOBS_WORLD_1 %d %d %d %d %d %d %d %d %d %.17g %.17g %.17g %d\n',
        pawn.masterPtr:GetAddress(),pawn:GetAddress(),request.region and request.region:GetAddress() or 0,
        request.mode,request.kind or 0,request.amount or 0,request.count or 1,request.rich or 0,
        request.preview and 1 or 0,pos.X,pos.Y,pos.Z,request.target or 0))
    file:close();os.remove(folder .. 'world.response');bridge()
    file=assert(io.open(folder .. 'world.response','r'),'World adapter did not respond')
    local response=file:read('*a');file:close()
    os.remove(folder .. 'world.request');os.remove(folder .. 'world.response')
    assert(response:match('^OK '),response:gsub('%s+$',''))
    return response:sub(4):gsub('%s+$','')
end
M.run=native
function M.new(get_pawn,arm,api)
    api=api or {run=native,find=function(class) return FindAllOf(class) or {} end}
    local self={}
    local function kind(value,allow_all)
        if allow_all and (not value or value=='all') then return 0 end
        return assert(KINDS[value],'Choose iron, clay, salt, stone, berries, mushrooms, fish or eel')
    end
    local function click(label,request)
        return arm(label,function(pawn,_,region,at)
            request.region=region;request.at=access.vector(at)
            return api.run(pawn,request)
        end)
    end
    function self.register(register)
        register('mobs.spawn_resource','mobs.spawn_resource <kind> [amount per clump] [1..64 clumps] [rich] [preview]',function(args)
            local args,preview=access.preview(args)
            local rich=args[#args]=='rich'
            if rich then table.remove(args) end
            assert(#args>=1 and #args<=3,'Usage: mobs.spawn_resource <kind> [amount] [1..64 clumps] [rich] [preview]')
            return click('Resource placement',{mode=1,kind=kind(args[1]),amount=args[2] and core.integer(args[2],1,1000000) or 0,
                count=core.integer(args[3] or 1,1,64),rich=rich and 1 or 0,preview=preview})
        end,'Click to create a registered surface resource group; amount is per clump, defaults to native capacity. Fish/eel require water; preview available.')
        register('mobs.resource','mobs.resource <add|rich|normal|remove|remove_clump> [kind|all] [amount for add] [preview]',function(args)
            local args,preview=access.preview(args)
            if args[1]=='add' then
                assert(#args==3,'Usage: mobs.resource add <kind> <amount> [preview]')
                return click('Add resource',{mode=9,kind=kind(args[2]),amount=core.integer(args[3],1,1000000),preview=preview})
            end
            local modes={rich=2,normal=2,remove=3,remove_clump=3}
            assert(#args>=1 and #args<=2 and modes[args[1]],'Choose rich, normal, remove or remove_clump, then optional kind and preview')
            return click('Resource ' .. args[1],{mode=modes[args[1]],kind=kind(args[2],true),
                count=args[1]=='remove_clump' and 1 or 0,rich=args[1]=='rich' and 1 or 0,preview=preview})
        end,'Click near an owned resource to add to one clump, change group richness/capacity, or remove a whole group/one clump. Maximum distance 2500; no undo.')
        register('mobs.spawn_deposit','mobs.spawn_deposit <iron|clay|salt> <amount> [rich] [preview]',function(args)
            local args,preview=access.preview(args)
            local rich=args[#args]=='rich';if rich then table.remove(args) end
            assert(#args==2 and (args[1]=='iron' or args[1]=='clay' or args[1]=='salt'),
                'Usage: mobs.spawn_deposit <iron|clay|salt> <amount> [rich] [preview]')
            return click('Underground deposit placement',{mode=4,kind=kind(args[1]),amount=core.integer(args[2],1,1000000),rich=rich and 1 or 0,preview=preview})
        end,'Click to create a new registered underground iron/clay/salt deposit and matching map node; one million units maximum; no undo.')
        register('mobs.remove_deposit','mobs.remove_deposit [iron|clay|salt|all] [preview]',function(args)
            local args,preview=access.preview(args)
            assert(#args<=1 and (not args[1] or args[1]=='all' or args[1]=='iron' or args[1]=='clay' or args[1]=='salt'),
                'Usage: mobs.remove_deposit [iron|clay|salt|all] [preview]')
            return click('Underground deposit removal',{mode=5,kind=kind(args[1],true),preview=preview})
        end,'Click near an owned underground deposit to remove its reserves/decal and unregister it; surface clumps are separate; no undo.')
        register('mobs.pond_fish','mobs.pond_fish [amount] [rich] [preview]',function(args)
            local args,preview=access.preview(args)
            local rich=args[#args]=='rich';if rich then table.remove(args) end
            assert(#args<=1,'Usage: mobs.pond_fish [amount] [rich] [preview]')
            local amount=core.integer(args[1] or 500,1,1000000)
            return arm('Pond fish placement',function(pawn,_,region,at)
                    local nearest,best=nil,1500*1500
                    for _,building in ipairs(api.find('SMBuildingMaster')) do
                        if access.valid(building) and building:GetType()==39 and building:IsConstructed()
                            and access.same(building.Region,region) then
                            local pos=access.vector(building:K2_GetActorLocation())
                            local distance=(pos.X-at.X)^2+(pos.Y-at.Y)^2
                            if distance<best then nearest,best=building,distance end
                        end
                    end
                    assert(nearest,'Click near a completed owned Fishing Pond (within 1500 game units)')
                    at=access.vector(nearest:K2_GetActorLocation())
                    return api.run(pawn,{mode=6,kind=5,region=region,at=at,amount=amount,count=1,rich=rich and 1 or 0,preview=preview,target=nearest:GetAddress()})
            end)
        end,'Add one fish shoal to the nearest completed owned Fishing Pond; rejects ponds already containing fish. Use refill_resources for existing shoals.')
        register('mobs.bandit_camp','mobs.bandit_camp [preview]',function(args)
            local args,preview=access.preview(args)
            assert(#args==0,'Usage: mobs.bandit_camp [preview]')
            return arm('Bandit camp placement',function(pawn,engine,region,at)
                assert(not access.valid(region.ownerPawn),'Bandit camps require an unclaimed region')
                assert(access.valid(engine.DT_Units) and engine.DT_Units:FindRow('brigands'),'Native brigands squad template is not loaded')
                assert(not engine:pointCollidesWithBuildingBorder(at),'Choose clear ground away from buildings')
                return api.run(pawn,{mode=8,region=region,at=access.vector(at),preview=preview})
            end,false)
        end,'Click clear unclaimed ground to register a native hostile camp squad and camp-building order; resume simulation afterward; no undo.')
        register('mobs.debug_task','mobs.debug_task',function(args)
            assert(#args==0,'Usage: mobs.debug_task')
            assert(access.valid(get_pawn()),'Load a settlement first')
            return 'Player context available. The reference dbg.doTask has no gameplay task body; no units or jobs changed.'
        end,'Diagnostic counterpart for the original developer placeholder: validate the loaded player context and report; no gameplay mutation.')
        register('mobs.instant_build','mobs.instant_build <on|off|status> [preview]',function(args)
            local args,preview=access.preview(args)
            local modes={on=1,off=0,status=2}
            assert(#args==1 and modes[args[1]],'Usage: mobs.instant_build <on|off|status> [preview]')
            return api.run(get_pawn(),{mode=7,rich=modes[args[1]],preview=preview or args[1]=='status'})
        end,'Use the game native instaBuild setting for newly placed buildings, including materials. Applies globally this session until off; existing sites use finish_constructions.')
    end
    return self
end
return M
