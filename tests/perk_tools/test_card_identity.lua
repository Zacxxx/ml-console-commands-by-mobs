package.path='src/mobs_console/Scripts/?.lua;'..package.path
local tools=require('perk_tools')
local calls={}
FName=function(value)
    calls[#calls+1]=value
    -- Numeric construction does not reliably round-trip the same display name
    -- on this runtime; the adapter must not depend on it.
    if type(value)=='number' then error('Numeric FName reconstruction must not be used') end
    return {GetComparisonIndex=function() return 12345 end}
end
local index,number=tools.card_identity('BambergSmallholders')
assert(index==12345 and number==0)
index,number=tools.card_identity('RuralCard_2')
assert(index==12345 and number==3)
index,number=tools.card_identity('RuralCard_02')
assert(index==12345 and number==0)
index,number=tools.card_identity('RuralCard_0')
assert(index==12345 and number==1)
assert(#calls==4)
print('Card identity uses original names without numeric FName round trips')
