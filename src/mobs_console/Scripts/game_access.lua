-- Copyright 2026 Mobs. MIT licensed. Shared settlement validation.
local M = {}
function M.valid(object)
    local ok, result = pcall(function() return object and object:IsValid() end)
    return ok and result
end
function M.same(a, b)
    return M.valid(a) and M.valid(b) and a:GetAddress() == b:GetAddress()
end
function M.text(value)
    return type(value) == 'string' and value or value:ToString()
end
function M.vector(at)
    local result = {}
    for _, key in ipairs({'X','Y','Z'}) do
        local value = at[key]
        assert(type(value)=='number' and value==value and math.abs(value)<100000000,
            'Invalid world position')
        result[key] = value
    end
    return result
end
function M.selected(pawn)
    -- getSelectedBuildings returns a by-value TArray. UE4SS can outlive that
    -- temporary buffer; selectedBld is the reflected, pawn-owned live array.
    local selected = pawn.selectedBld
    assert(selected, 'Selection unavailable; load a settlement and select a building')
    assert(#selected>0 and #selected<=32, 'Select between 1 and 32 owned buildings')
    local result, seen = {}, {}
    for i=1,#selected do
        local building=selected[i]
        assert(M.valid(building) and M.valid(building.Region) and M.same(building.Region.ownerPawn,pawn),
            'Selection contains an invalid or foreign building; nothing changed')
        if not seen[building:GetAddress()] then
            seen[building:GetAddress()]=true
            result[#result+1]=building
        end
    end
    return result
end
function M.preview(args)
    local result, preview = {}, false
    for _, value in ipairs(args) do
        if value=='preview' then
            assert(not preview, 'Repeated preview argument')
            preview=true
        else result[#result+1]=value end
    end
    return result, preview
end
return M
