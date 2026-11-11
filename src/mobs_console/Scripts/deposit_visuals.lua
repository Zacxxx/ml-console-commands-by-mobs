-- Copyright 2026 Mobs. MIT licensed. Mineral data actors are not terrain artwork.
local access=require('game_access')
local valid,same=access.valid,access.same
local M={}
local MINERAL_ITEMS={[14]=true,[145]=true,[146]=true}
function M.new(get_pawn,api)
    api=api or {
        find=function(class) return FindAllOf(class) or {} end,
        version=function() return require('UEHelpers').GetGameInstance():GetAppVersion():ToString() end,
        loop=LoopInGameThreadWithDelay,
        cancel=CancelDelayedAction,
    }
    local self, timer = {}, nil
    function self.refresh(preview)
        assert(api.version()=='Version 0.8.117','Deposit visuals support game 0.8.117')
        local pawn=get_pawn()
        assert(valid(pawn.masterPtr),'Load a settlement first')
        local function owned(actor)
            if not valid(actor) then return false end
            local region=pawn.masterPtr:getRegionByPos(access.vector(actor:K2_GetActorLocation()),false)
            return valid(region) and same(region.ownerPawn,pawn)
        end
        local count=0
        local function hide(actor)
            count=count+1
            if not preview then actor:SetActorHiddenInGame(true) end
        end
        for _,deposit in ipairs(api.find('DepositDecal')) do
            if owned(deposit) and MINERAL_ITEMS[deposit.depositedGood.Type] then hide(deposit) end
        end
        -- Natural mineral nodes have no clumps. Older Mobs placements keep a
        -- data clump for finite amounts: retain it, hide only its terrain rendering.
        -- Node icons/hover data and surface stone actors are separate and untouched.
        for _,node in ipairs(api.find('ResourceNode')) do
            if valid(node) and same(node.masterPtr,pawn.masterPtr) and owned(node) then
                local clumps=node.resourceClumps
                if clumps and #clumps<=10000 then
                    for i=1,#clumps do
                        local clump=clumps[i]
                        if valid(clump) and MINERAL_ITEMS[clump.Type] and owned(clump) then hide(clump) end
                    end
                end
            end
        end
        return count
    end
    function self.stop()
        if timer then
            api.cancel(timer)
            timer = nil
        end
    end
    function self.start()
        if not (api.loop and api.cancel) then return false end
        if timer then return true end
        timer = api.loop(2500, function()
            -- Loading/menu transitions are expected; retry with fresh objects.
            pcall(self.refresh, false)
        end)
        return true
    end
    return self
end
return M
