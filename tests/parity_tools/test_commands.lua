package.path = 'src/mobs_console/Scripts/?.lua;' .. package.path
local function object(id, values)
    values = values or {}
    values.IsValid = function() return true end
    values.GetAddress = function() return id end
    return values
end
local engine = object(2)
local pawn = object(1, {masterPtr=engine, selectedBld={}, selectedRegion=nil, claims={}})
local region = object(3, {ownerPawn=pawn, regionName='Test'})
local weather = object(4, {targetRaining=0, raining=0, day=5, daysTotal=5})
pawn.getSelectedBuildings=function() return pawn.selectedBld end
engine.TemporalComponent = weather
local notified, deferred, clicked, commands = {}, {}, nil, {}
local api = {
    bind=function(fn) clicked=fn end,
    defer=function(fn) deferred[#deferred+1]=fn end,
    version=function() return 'Version 0.8.117' end,
    find=function(class) return class=='Region' and {region} or {} end,
}
local tools = require('parity_tools').new(function() return pawn end, function() return region end,
    function() return 'Test' end, function(s) notified[#notified+1]=s end, api)
tools.register(function(name, _, fn) commands[name]=fn end)
local function rejects(name,args)
    local ok=pcall(commands[name],args)
    assert(not ok, name .. ' should reject this request')
end
assert(commands['mobs.weather']({'rain','preview'}):find('Preview'))
assert(weather.targetRaining==0)
commands['mobs.weather']({'rain','instant'})
assert(weather.targetRaining==1 and weather.raining==1 and weather.isDrought==false)
commands['mobs.weather']({'clear','instant'})
assert(weather.targetRaining==0 and weather.raining==0)
rejects('mobs.weather',{'rain','typo'})
assert(weather.raining==0)
local removed=0
local good=object(5,{Region=region, canBeDemolished=function() return true end,
    demolish=function(_,refund) assert(refund); removed=removed+1 end})
local foreign=object(6,{Region=object(7,{ownerPawn=object(8)})})
pawn.selectedBld={good,foreign}
rejects('mobs.demolish',{'selected'})
assert(removed==0)
pawn.selectedBld={good,good}
assert(commands['mobs.demolish']({'selected','preview'}):find('1'))
assert(removed==0)
commands['mobs.demolish']({'selected'})
assert(removed==1)
-- Native day update is requested once per skipped day, rather than overwriting the date.
engine.setDay=function(_,day) weather.day=day; weather.daysTotal=weather.daysTotal+1 end
commands['mobs.skip_day']({'2'})
assert(weather.daysTotal==7)
rejects('mobs.skip_day',{'31'})
-- Claims use the explicitly selected map region, not our owned region pin.
local target=object(9,{ownerPawn=nil,regionName='Unclaimed'})
pawn.selectedRegion=target
local claims={}
pawn.layClaim=function(_,r,favor,consume) assert(not favor and not consume); claims[#claims+1]=r; pawn.claims[#pawn.claims+1]={Region=r} end
pawn.getRelevantClaimedRegions=function() return claims end
assert(commands['mobs.claim']({'start','preview'}):find('Preview'))
assert(#claims==0)
commands['mobs.claim']({'start'})
assert(claims[1]==target)
pawn.finalizeClaim=function(_,r,remove)
    assert(remove, 'Completed claims must be removed to avoid repeated finalization')
    r.ownerPawn=pawn
    for i=#pawn.claims,1,-1 do if pawn.claims[i].Region==r then table.remove(pawn.claims,i) end end
end
commands['mobs.claim']({'finish'})
assert(target.ownerPawn==pawn and #pawn.claims==0)
-- Armed click consumes once, respects UI, and revalidates ownership.
pawn.isUsingUI=true
pawn.isInAnyConstructionMode=function() return false end
pawn.getMouse3d=function() return {X=10,Y=20,Z=0} end
engine.getRegionByPos=function() return region end
engine.SpawnLivestock=function(_,role,at,r) assert(role==12 and r==region and at.X==10); return object(10) end
commands['mobs.animal']({'ox'})
clicked(); table.remove(deferred,1)()
assert(#notified==0)
pawn.isUsingUI=false
clicked(); table.remove(deferred,1)()
assert(notified[1]:find('1'))
clicked(); assert(#deferred==0)
rejects('mobs.animal',{'soldier'})
print('parity_tools commands passed')
