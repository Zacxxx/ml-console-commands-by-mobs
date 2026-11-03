-- Copyright 2026 Mobs. MIT licensed. Category filters for the live command registry.
local M={}
local categories={
    lord={'treasury','influence','status','undo'},
    army={'mercenaries','bandits','raiders','bandit_camp','teleport','unit','follow','rename_unit','undo_unit_name'},
    region={'wealth','approval','regions','region','map_regions','construction','construction_needs','supply_construction',
        'finish_constructions','instant_build','grow_population','livestock_cooldown','skip_mourning','stock',
        'resources','spawn_resource','resource','spawn_deposit','remove_deposit','pond_fish','deposit','undo_deposit','refill_resources','empty_resources','undo_resources','claim','rehouse','soil','undo_soil',
        'fertility','fertilization','undo_fertilization','grow_trees','grow_saplings','grow_stage','regrow_trees','replant_trees',
        'animal','give','inventory_add','drop','pile','clear_empty_piles','remove_selected_piles','demolish','building','inventory',
        'perk_points','perks','respec_perks','perk_add','perk_remove','perk_clear','perks_add','perks_remove','perks_clear'},
    misc={'help','version','ping','is_in_game','speed','skip_day','weather','foreign_supply','items','cancel','run','plants','debug_task'},
}
function M.get(name)
    local suffix=name:gsub('^mobs%.','')
    for category,names in pairs(categories) do
        for _,candidate in ipairs(names) do if suffix==candidate then return category end end
    end
    return 'misc'
end
function M.matches(name,entry,filter)
    if categories[filter] then return M.get(name)==filter end
    return string.find(string.lower(entry.usage .. ' ' .. entry.description),filter,1,true)~=nil
end
return M
