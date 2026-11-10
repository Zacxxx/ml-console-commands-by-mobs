-- Copyright 2026 Mobs. MIT licensed. Explicit native resident creation.
local access=require('game_access')
local core=require('core')
local M={}
function M.register(register,get_pawn,get_region,region_label,api)
    api=api or {
        find=function() return FindAllOf('SMBuildingMaster') or {} end,
        spawn=function(pawn,region,family_id,role,home,preview)
            return require('world_tools').run(pawn,{mode=14,region=region,amount=family_id+1,
                kind=role,target=home:GetAddress(),preview=preview})
        end,
    }
    local function usable(home,region)
        return access.valid(home) and access.same(home.Region,region) and home.buildingFunction==1
            and home:IsConstructed() and not home.sleep and home.mourningPeriod<=0
    end
    local function snapshot(region)
        local plans,homes,seen,occupied={}, {}, {}, {}
        local families=region.workerFamilies
        local available=0
        local function add(plan)
            available=available+1
            if #plans<10 then plans[#plans+1]=plan end
        end
        for i=1,#families do
            local family=families[i]
            local home=family.familyHome
            if access.valid(home) then
                local id=home:GetAddress();occupied[id]=(occupied[id] or 0)+1
            end
            local members=family.familyMembers
            if usable(home,region) and #members>0 and #members<3 then
                local roles,ready={},true
                for j=1,#members do
                    local member=members[j]
                    if not access.valid(member) or member.dead or not access.same(member.Home,home) then ready=false;break end
                    local role=member.assignedUnitRole
                    if role~=0 and role~=1 and role~=2 or roles[role] then ready=false;break end
                    roles[role]=true
                end
                if ready then
                    for role=0,2 do if not roles[role] then add({home=home,family_id=i-1,role=role}) end end
                end
            end
        end
        local homeless=core.integer(region:getNumHomelessFamilies(),0,100000)
        for _,home in ipairs(api.find()) do
            if usable(home,region) and not seen[home:GetAddress()] then
                seen[home:GetAddress()]=true;homes[#homes+1]=home
            end
        end
        table.sort(homes,function(a,b) return a:GetAddress()<b:GetAddress() end)
        local group=0
        -- Do not take vacant homes ahead of existing homeless families.
        if homeless==0 then
            for _,home in ipairs(homes) do
                local maximum=core.integer(home:getMaxResidingFamilies(),0,64)
                local current=math.max(core.integer(home:getNumResidingFamilies(),0,100000),occupied[home:GetAddress()] or 0)
                for _=current+1,maximum do
                    group=group+1
                    for role=0,2 do add({home=home,group=group,role=role}) end
                end
            end
        end
        return plans,available,homeless
    end
    register('mobs.grow_population','mobs.grow_population [1..10|status] [preview]',function(args)
        local args,preview=access.preview(args)
        assert(#args<=1,'Usage: mobs.grow_population [1..10|status] [preview]')
        local requested=args[1]=='status' and 0 or core.integer(args[1] or '1',1,10)
        local pawn,region=get_pawn(),get_region(true)
        assert(access.valid(region) and access.same(region.ownerPawn,pawn),'Choose a region owned by your lord')
        assert(region.isSettled,'Choose an established settlement first')
        local plans,available,homeless=snapshot(region)
        local monthly=region:GetMonthlyPopChange()
        local context=string.format('%s: approval=%d; natural monthly growth=%d; housing places=%d; homeless families=%d.',
            region_label(region),region.Approval,monthly,available,homeless)
        if requested==0 then return context .. ' Explicit growth bypasses approval/arrival-day gates but requires usable housing.' end
        assert(available>=requested,context .. ' Need ' .. requested .. ' places. Complete/unpause housing, let homeless families settle, or wait for mourning to end. Nothing changed.')
        -- Native preflight checks each distinct family/home entrance before any
        -- creation. New-family followers do not have an index until their head exists.
        local checked={}
        for i=1,requested do
            local plan=plans[i]
            local key=plan.group and ('new:' .. plan.group) or ('family:' .. plan.family_id .. ':' .. plan.role)
            if not checked[key] then
                api.spawn(pawn,region,plan.family_id or -1,plan.group and 0 or plan.role,plan.home,true)
                checked[key]=true
            end
        end
        if preview then return context .. ' Preview: add ' .. requested .. ' people immediately through native creation; nothing changed.' end
        local before=region:getNumHumanResidents()
        local groups,failure={},nil
        for i=1,requested do
            local plan=plans[i]
            local ok,err=pcall(function()
                assert(access.same(get_pawn(),pawn) and access.same(region.ownerPawn,pawn),'Settlement or ownership changed')
                local family_id=plan.family_id
                if plan.group then family_id=groups[plan.group] or -1 end
                local count=region:getNumHumanResidents()
                local family_count=#region.workerFamilies
                api.spawn(pawn,region,family_id,plan.role,plan.home,false)
                assert(region:getNumHumanResidents()==count+1,'Native creation did not add exactly one resident; no automatic retry')
                if family_id<0 then
                    assert(#region.workerFamilies==family_count+1,'Unexpected family registration; no automatic retry')
                    groups[plan.group]=family_count
                end
            end)
            if not ok then failure=tostring(err);break end
        end
        local after=region:getNumHumanResidents()
        if after>before then
            local ok,err=pcall(function() region:redistributeMilitiaRecruits() end)
            if not ok then failure=(failure and (failure .. '; ') or '') .. 'Recruit refresh: ' .. tostring(err) end
        end
        return string.format('%s: added %d/%d people; human residents %d -> %d.%s Native families/housing registered. No date or approval override; no undo.',
            region_label(region),after-before,requested,before,after,failure and (' Stopped: ' .. failure) or '')
    end,'Add 1..10 human residents immediately through native family/housing creation; bypasses natural approval/arrival-day gates. Requires usable housing; status explains capacity; preview available; no undo.')
end
return M
