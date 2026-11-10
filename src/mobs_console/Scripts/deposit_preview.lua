-- Copyright 2026 Mobs. MIT licensed. Exact-click native mineral placement preview.
local access=require('game_access')
local M={}
local KINDS={
    [1]={name='SALT',material='depositMaterial_Salt'},
    [2]={name='IRON',material='depositMaterial'},
    [3]={name='CLAY',material='depositMaterial_Clay'},
}
function M.definition(settings,request)
    local kind=assert(KINDS[request.kind],'Choose iron, clay or salt')
    assert(request.rich==0 or request.rich==1,'Invalid deposit richness')
    assert(type(request.amount)=='number' and request.amount%1==0 and request.amount>=1
        and request.amount<=1000000,'Choose 1..1000000 units per deposit layer')
    local radius=settings[request.rich==1 and 'resourceRichDepositRadius' or 'resourceDepositRadius']
    assert(type(radius)=='number' and radius==radius and radius>=100 and radius<15000,
        'Native mining radius unavailable; no deposit created')
    local border={}
    for i=0,47 do
        local angle=i*2*math.pi/48
        border[#border+1]={X=math.cos(angle)*radius,Y=math.sin(angle)*radius}
    end
    return {kind=request.kind,amount=request.amount,rich=request.rich,radius=radius,
        title=kind.name .. (request.rich==1 and ' - RICH' or '') .. ' DEPOSIT',
        material_property=kind.material,customBorder=border}
end
function M.new(get_pawn,notify,api)
    local options={label='Deposit',policy='Native mineral placement',
        confirm='left-click to create one mineral group centred on that click. ',
        request=function(definition,region,at,preview)
            return {mode=4,kind=definition.kind,amount=definition.amount,rich=definition.rich,
                region=region,at=access.vector(at),preview=preview}
        end,
        ghost=function(pawn,definition)
            return require('pond_ghost').new(pawn,definition,false,{
                title=definition.title,
                detail=string.format('%.0fm native mining radius | %d surface + %d underground',
                    definition.radius/100,definition.amount,definition.amount),
                material=pawn.masterPtr[definition.material_property],decal_radius=definition.radius,
                centre_mark=true,
            })
        end,
    }
    local tool=require('pond_preview').new(get_pawn,notify,api,options)
    local self={cancel=tool.cancel,reset=tool.reset,active=tool.active}
    function self.start(pawn,request)
        local settings
        if api and api.settings then settings=api.settings()
        else
            settings=StaticFindObject('/Script/ManorLords.Default__ResourceSettings')
            assert(access.valid(settings),'Native resource settings unavailable')
        end
        local definition=M.definition(settings,request)
        return tool.start(pawn,definition,request.preview,false)
    end
    return self
end
return M
