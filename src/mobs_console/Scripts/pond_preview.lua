-- Copyright 2026 Mobs. MIT licensed. A visual, non-building pond placement tool.
local access=require('game_access')
local valid,same=access.valid,access.same
local M={}
function M.new(get_pawn,notify,api,options)
    options=options or {}
    local label=options.label or 'Pond'
    local function native_request(request,region,at,preview)
        if options.request then return options.request(request.definition,region,at,preview) end
        return {mode=15,region=region,at=at,preview=preview,rich=request.strict and 1 or 0}
    end
    api=api or {
        now=os.time,
        input_defer=function(fn) ExecuteInGameThread(fn) end,
        defer=function(fn) ExecuteWithDelay(120,function() ExecuteInGameThread(fn) end) end,
        bind=function(left,right)
            RegisterKeyBind(Key.LEFT_MOUSE_BUTTON,left)
            if Key.RIGHT_MOUSE_BUTTON then RegisterKeyBind(Key.RIGHT_MOUSE_BUTTON,right) end
        end,
        available=function(pawn)
            return same(pawn,get_pawn()) and valid(pawn.masterPtr)
                and not pawn.mapViewMode and not pawn:isInAnyConstructionMode()
        end,
        sense=function(pawn)
            if pawn.isUsingUI or pawn.bFullscreenUIActive then return nil,nil,true end
            local at=access.vector(pawn:getMouse3d())
            return at,pawn.masterPtr:getRegionByPos(at,false),false
        end,
        run=require('world_tools').run,
        ghost=options.ghost or function(pawn,row,strict) return require('pond_ghost').new(pawn,row,strict) end,
    }
    local input_defer=api.input_defer or api.defer
    local pending
    local self={}
    function self.active() return pending~=nil end
    function self.cancel()
        local request=pending
        pending=nil
        if request then request.ghost.destroy() end
        return request~=nil
    end
    self.reset=self.cancel
    local function available(request)
        if api.now()>=request.expires then
            self.cancel(); notify(label .. ' preview expired.'); return false
        end
        local ok,result=pcall(api.available,request.pawn)
        if not ok or not result then
            self.cancel(); notify(label .. ' preview cancelled: settlement or placement mode changed.'); return false
        end
        return true
    end
    local function inspect(request)
        local at,region,ui=api.sense(request.pawn)
        if ui then request.ghost.hide(); return nil end
        assert(at,'Mouse terrain position unavailable')
        local ok,message=pcall(function()
            assert(valid(region) and same(region.ownerPawn,request.pawn),'Move fully inside a region owned by your lord')
            return api.run(request.pawn,native_request(request,region,at,true))
        end)
        request.ghost.show(at,ok,tostring(message),request.preview)
        return {at=at,region=region,ok=ok,message=tostring(message)}
    end
    local function tick(request)
        if pending~=request then return end
        if not available(request) then return end
        local ok,message=pcall(inspect,request)
        if not ok then self.cancel(); notify(label .. ' preview stopped: ' .. tostring(message)); return end
        api.defer(function() tick(request) end)
    end
    function self.start(pawn,row,preview,strict)
        assert(api.available(pawn),'Exit paper map and ordinary building placement before starting the preview')
        self.cancel()
        local ghost=api.ghost(pawn,row,strict)
        local request={pawn=pawn,ghost=ghost,definition=row,preview=preview,strict=strict,expires=api.now()+300}
        pending=request
        api.defer(function() tick(request) end)
        return (options.policy or (strict and 'Strict pond' or 'Relaxed pond')) .. ' preview armed. Close the console and move over terrain. Green READY / red BLOCKED label; '
            .. (preview and 'preview clicks report only and never place. ' or (options.confirm or 'left-click a valid site to create one completed empty pond. '))
            .. 'Blocked clicks keep the preview. Right-click or mobs.cancel cancels; expires in five minutes.'
    end
    api.bind(function()
        local request=pending
        if not request then return end
        input_defer(function()
            if pending~=request or not available(request) then return end
            local ok,message=pcall(function()
                -- Recheck the actual click: a green frame is never permission to use stale coordinates.
                local plan=inspect(request)
                if not plan then return end
                if not plan.ok then return label .. ' blocked: ' .. plan.message .. '. Move the preview and try again.' end
                if request.preview then return plan.message .. ' Preview remains active; nothing placed.' end
                -- Allocation can fail after modifying the world. Consume before the native call; no auto-retry.
                self.cancel()
                return api.run(request.pawn,native_request(request,plan.region,plan.at,false))
            end)
            if not ok then notify(label .. ' placement stopped: ' .. tostring(message))
            elseif message then notify(message) end
        end)
    end,function()
        local request=pending
        if not request then return end
        input_defer(function()
            if pending==request and self.cancel() then notify(label .. ' preview cancelled.') end
        end)
    end)
    return self
end
return M
