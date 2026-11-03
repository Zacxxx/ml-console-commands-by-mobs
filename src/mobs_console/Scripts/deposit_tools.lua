-- Copyright 2026 Mobs. MIT licensed. Existing underground DepositDecal edits.
-- These are distinct from surface Resource actors and resource-node spawning.
local access=require('game_access')
local core=require('core')
local valid,same=access.valid,access.same
local M={}
local TYPES={iron=14,salt=145,clay=146} -- EItemType in the supported reflection dump.
function M.new(get_pawn,arm,api)
    api=api or {find=function() return FindAllOf('DepositDecal') or {} end}
    local history={}
    local self={}
    function self.reset() history={} end
    local function own(pawn,deposit,region)
        return valid(deposit) and valid(region) and same(region.ownerPawn,pawn)
            and same(pawn.masterPtr:getRegionByPos(access.vector(deposit:K2_GetActorLocation()),false),region)
    end
    function self.register(register)
        register('mobs.deposit','mobs.deposit <add|rich|normal> <iron|clay|salt> [amount for add] [preview]',function(args)
            local args,preview=access.preview(args)
            local mode,kind=args[1],args[2]
            assert(mode=='add' or mode=='rich' or mode=='normal','Choose add, rich or normal')
            assert(TYPES[kind],'Choose iron, clay or salt')
            local amount=mode=='add' and core.integer(args[3],1,1000000) or 0
            assert(#args==(mode=='add' and 3 or 2),'Usage: mobs.deposit <add|rich|normal> <kind> [amount for add] [preview]')
            return arm('Underground deposit edit',function(pawn,_,region,at)
                local target,best=nil,2500*2500
                for _,deposit in ipairs(api.find()) do
                    if own(pawn,deposit,region) and deposit.depositedGood.Type==TYPES[kind] then
                        local pos=access.vector(deposit:K2_GetActorLocation())
                        local distance=(at.X-pos.X)^2+(at.Y-pos.Y)^2
                        if distance<best then target,best=deposit,distance end
                    end
                end
                assert(target,'No matching existing owned underground deposit within 2500 game units; no deposit was created')
                local before=core.integer(target.depositedGood.amt,0,2147483647)
                local rich_before=target.bRichDeposit
                assert(type(rich_before)=='boolean','Cannot read deposit richness')
                local after=mode=='add' and core.integer(before+amount,0,2147483647) or before
                local rich_after=rich_before
                if mode=='rich' then rich_after=true elseif mode=='normal' then rich_after=false end
                local limit=core.integer(target.Limit,0,2147483647)
                assert(mode~='add' or limit==0 or after<=limit,'Requested amount exceeds this deposit native limit')
                if preview then return string.format('Preview: underground %s amount %d -> %d, rich %s -> %s; nothing changed.',kind,before,after,tostring(rich_before),tostring(rich_after)) end
                local entry={pawn=pawn:GetAddress(),deposit=target,region=region,kind=TYPES[kind],limit=limit,
                    before=before,after=after,rich_before=rich_before,rich_after=rich_after}
                history[#history+1]=entry
                if #history>10 then table.remove(history,1) end
                target.depositedGood.amt=after
                target.bRichDeposit=rich_after
                assert(target.depositedGood.amt==after and target.bRichDeposit==rich_after,'Game did not retain the edit; inspect the deposit before continuing')
                return string.format('Underground %s amount %d -> %d, rich %s -> %s. Surface clumps unchanged; mobs.undo_deposit can restore this edit.',kind,before,after,tostring(rich_before),tostring(rich_after))
            end)
        end,'Click near an existing owned underground iron/clay/salt deposit to add reserves or change its rich flag; preview and guarded undo; does not spawn deposits.')
        register('mobs.undo_deposit','mobs.undo_deposit',function(args)
            assert(#args==0,'Usage: mobs.undo_deposit')
            local pawn=get_pawn()
            local entry=history[#history]
            assert(entry,'No underground deposit edit to undo')
            local deposit=entry.deposit
            assert(entry.pawn==pawn:GetAddress() and own(pawn,deposit,entry.region),'Deposit/world/ownership changed; undo refused')
            assert(deposit.Limit==entry.limit and deposit.depositedGood.Type==entry.kind
                and deposit.depositedGood.amt==entry.after and deposit.bRichDeposit==entry.rich_after,
                'Deposit changed since edit; undo refused')
            deposit.depositedGood.amt=entry.before
            deposit.bRichDeposit=entry.rich_before
            table.remove(history)
            return 'Restored underground deposit amount and richness.'
        end,'Undo the latest unchanged underground deposit edit; holds ten edits until mod/player reload.')
    end
    return self
end
return M
