# Command reference

Version 0.14.0-alpha.1 — 91 registered names, including aliases.

Generated from the registered implementation without executing gameplay commands.

Use mobs.usage <command> for targeting help. Required arguments use <...>;
optional arguments use [...]. Replace the placeholders; do not type their brackets.

Preview/undo are available only where explicitly documented. Read KNOWN_ISSUES.md.

## Lord

| Usage | Behavior |
| --- | --- |
| `mobs.influence <set\|add> <amount>` | Change influence; records an economy undo step. |
| `mobs.status` | Show your lord's balances and the command target region's wealth. |
| `mobs.treasury <set\|add> <amount>` | Change treasury; records an economy undo step. |
| `mobs.undo` | Undo the last economy edit unless its value has changed since. |

## Region

| Usage | Behavior |
| --- | --- |
| `mobs.animal <type> [1..20] [preview]` | Click inside an owned region to spawn 1..20 animals using native livestock registration; preview available. |
| `mobs.approval <set\|add> <amount>` | Set/add current approval (0..100); game may recalculate it. Records an undo step. |
| `mobs.building` | Inspect one selected owned building and its construction state; changes nothing. |
| `mobs.claim <start\|finish> [region-id\|all] [preview]` | Start a claim without influence cost, or finish your existing claim(s); explicit map selection/ID, supports preview. |
| `mobs.clear_empty_piles [preview]` | Remove empty owned Supplies piles in the target region; supports preview. Non-empty/unreadable piles are kept. |
| `mobs.construction <pause\|resume>` | Pause or resume unfinished construction across the target region. |
| `mobs.construction_needs [region]` | Report selected construction materials, or region totals; missing counts include incoming deliveries. |
| `mobs.demolish selected [preview]` | Demolish selected owned buildings through the game with normal refund rules; preflight all targets and support preview. |
| `mobs.deposit <add\|rich\|normal> <iron\|clay\|salt> [amount for add] [preview]` | Click near an existing owned underground iron/clay/salt deposit to add reserves or change its rich flag; preview and guarded undo; does not spawn deposits. |
| `mobs.drop [item\|id amount]` | Deliver to clicked owned storage or supply needed construction materials. No arguments shows status. |
| `mobs.empty_resources [kind] [preview]` | Empty existing matching natural resource clumps in your target region, retaining actors; preview and guarded undo. Wildlife excluded. |
| `mobs.fertility [wheat\|flax\|barley\|rye\|oats]` | Read crop fertility and fertilization counters for selected owned fields; does not restore or set soil fertility. |
| `mobs.fertilization <on\|off> [selected\|region] [preview]` | Enable/disable native fertilization permission for selected fields or the target region; supports preview. Does not add fertility. |
| `mobs.finish_constructions [preview]` | Finish construction work in the selected/current owned region and let the game finalize sites during simulation; preview lists the count. |
| `mobs.give <item\|id> <amount> [preview]` | Deliver up to this amount to EACH selected owned storage building or construction site (max 32); supports preview. |
| `mobs.grow_population [attempts]` | Request native population growth in the target settlement, up to ten attempts; reports actual resident counts. |
| `mobs.grow_saplings [area] [preview]` | Mature registered saplings, including forester plantings; optionally limit to the selected building work area, supports preview. |
| `mobs.grow_stage [area] [preview]` | Advance each registered growing tree once through native growth; optionally target one limited work area, supports preview. |
| `mobs.grow_trees [preview]` | Grow registered trees and untracked native young-tree stages to maturity in batches; excludes decorative bushes. Supports preview. |
| `mobs.instant_build <on\|off\|status> [preview]` | Use the game native instaBuild setting for newly placed buildings, including materials. Applies globally this session until off; existing sites use finish_constructions. |
| `mobs.inventory [search]` | Show goods stored directly in one selected owned building; optional name or ID filter. |
| `mobs.inventory_add <item\|id> <amount> [preview]` | Add goods to EACH selected owned building, including production/housing (maximum 32); bypass completed-building storage limits. Construction sites receive only needed materials; preview available. |
| `mobs.livestock_cooldown [reset]` | Read or clear the target region's next livestock order cooldown; does not spawn or deliver animals. |
| `mobs.map_regions` | List map region IDs including unclaimed/foreign regions for claim commands. |
| `mobs.perk_add <number\|name> [preview]` | Activate an additional tier 1/2 card without replacing primary cards; includes its penalties. Use mobs.perks list for numbers. |
| `mobs.perk_clear [preview]` | Remove all extra cards in the target region, keeping normal primary cards. |
| `mobs.perk_points <1\|2\|both> [preview]` | Restore a regional card choice by resetting that tier; tier 1 also resets tier 2. One card per tier; settlement gates remain. |
| `mobs.perk_remove <number\|name> [preview]` | Remove one extra card and rebuild active effects; preserves primary cards and effects supplied by other cards. |
| `mobs.perks [list\|add\|remove\|clear\|search]` | List/search cards, or use mobs.perks add/remove <card> and mobs.perks clear; preview is supported for changes. |
| `mobs.perks_add <number\|name> [preview]` | Alias for mobs.perk_add; also accepts mobs.perks add. |
| `mobs.perks_clear [preview]` | Alias for mobs.perk_clear; also accepts mobs.perks clear. |
| `mobs.perks_remove <number\|name> [preview]` | Alias for mobs.perk_remove; also accepts mobs.perks remove. |
| `mobs.pile <item\|id> <amount>` | Experimental: enter native Supplies placement and fill the newly placed pile; owned region only. |
| `mobs.pond_fish [amount] [rich] [preview]` | Add one fish shoal to the nearest completed owned Fishing Pond; rejects ponds already containing fish. Use refill_resources for existing shoals. |
| `mobs.refill_resources [kind] [preview]` | Refill existing iron/clay/stone/salt/berries/mushrooms/fish/eel clumps to capacity; preview and guarded undo; no new nodes. |
| `mobs.region [id\|current\|selected\|auto]` | Choose a region for wealth and regional construction commands; does not move the camera or alter map selection. |
| `mobs.regions` | List your owned regions and their IDs for mobs.region. |
| `mobs.regrow_trees [preview]` | Combined tool: click to replant one sapling and mature native growing trees in the target owned region; supports preview. |
| `mobs.rehouse selected [preview]` | Move a hovered/followed family to one selected completed house in the same owned region; checks capacity, supports preview. |
| `mobs.remove_deposit [iron\|clay\|salt\|all] [preview]` | Click near an owned underground deposit to remove its reserves/decal and unregister it; surface clumps are separate; no undo. |
| `mobs.remove_selected_piles [preview]` | Remove selected owned Supplies piles INCLUDING CONTENTS, even unfinished/bugged ones; supports preview. Ignores region pin; no undo. |
| `mobs.replant_trees [preview]` | Click cleared ground to replant one oak sapling in the target owned region; native collision checks; supports preview. |
| `mobs.resource <add\|rich\|normal\|remove\|remove_clump> [kind\|all] [amount for add] [preview]` | Click near an owned resource to add to one clump, change group richness/capacity, or remove a whole group/one clump. Maximum distance 2500; no undo. |
| `mobs.resources [kind]` | Inspect existing mineral, berry, mushroom, fish and eel clumps in the target owned region; does not count stored goods. |
| `mobs.respec_perks [1\|2\|all] [preview]` | Reset regional perk cards and rebuild active effects. Default both tiers; resetting Origins also resets Rural Foundations. |
| `mobs.skip_mourning [preview]` | Clear active mourning timers on owned buildings in the target region; preview lists the affected count. |
| `mobs.soil <set\|restore> <wheat\|flax\|barley\|all> [0..100] [selected\|area] [preview]` | Set baseline/current soil fertility or restore depletion for selected planted plots or limited work areas; 0..100%, preview and guarded undo. |
| `mobs.spawn_deposit <iron\|clay\|salt> <amount> [rich] [preview]` | Click to create a new registered underground iron/clay/salt deposit and matching map node; one million units maximum; no undo. |
| `mobs.spawn_resource <kind> [amount per clump] [1..64 clumps] [rich] [preview]` | Click to create a registered surface resource group; amount is per clump, defaults to native capacity. Fish/eel require water; preview available. |
| `mobs.stock [search]` | Show target region stock through the native stock query, including reserved goods; optional name or ID filter. |
| `mobs.supply_construction [selected] [preview]` | Supply missing construction materials in the target region or selected sites; supports preview. Does not complete work. |
| `mobs.undo_deposit` | Undo the latest unchanged underground deposit edit; holds ten edits until mod/player reload. |
| `mobs.undo_fertilization` | Undo the latest fertilization permission batch when fields are unchanged; holds five batches until reload. |
| `mobs.undo_resources` | Undo the latest resource refill if no affected deposit has changed; holds five refills and clears on reload. |
| `mobs.undo_soil [preview]` | Undo the latest soil batch only if all edited values and ownership are unchanged; supports preview. |
| `mobs.wealth <set\|add> <amount>` | Change wealth; records an economy undo step. |

## Army

| Usage | Behavior |
| --- | --- |
| `mobs.bandit_camp [preview]` | Click clear unclaimed ground to register a native hostile camp squad and camp-building order; resume simulation afterward; no undo. |
| `mobs.bandits [preview]` | Ask the game to spawn a bandit camp at a valid random location; supports preview. |
| `mobs.follow [off]` | Follow the hovered unit using the native camera function; off stops. Native follow can normalize game speed. |
| `mobs.mercenaries reroll` | Reroll mercenary offers through the native game function; does not hire any units. |
| `mobs.raiders [1..6] [preview]` | Click a playable region to request native hostile raider squads; maximum six, supports preview. |
| `mobs.rename_unit <new name>` | Rename the hovered/followed living unit with an owned home; supports spaces and separate guarded name undo. |
| `mobs.teleport <unit\|squads> [preview]` | Click to relocate an owned unit or selected squads, preserving formation offsets; preview supported; existing orders remain active. |
| `mobs.undo_unit_name` | Undo the latest unit rename if its name, home and owner are unchanged; holds ten renames until reload. |
| `mobs.unit` | Inspect the hovered unit, or currently followed unit when none is hovered; changes nothing. |

## Misc

| Usage | Behavior |
| --- | --- |
| `help [search]` | Alias for mobs.help. |
| `mobs [command words...]` | Quick-start dashboard or run an exact command using spaces; misspellings only suggest, never execute. |
| `mobs.autocomplete [status\|refresh\|on\|off]` | Refresh game-data suggestions, inspect status, or enable/disable only our native console suggestions. |
| `mobs.boop [on\|off\|status]` | Toggle the game debug Boop mode, explicitly enable/disable it or read status; uses the native pawn setting and refresh. |
| `mobs.cancel` | Cancel pending supply/forestry tools or further tree-growth batches; completed changes remain. |
| `mobs.complete <partial text...>` | Show contextual completion choices in text; useful if the native dropdown is unavailable. |
| `mobs.debug_task` | Diagnostic counterpart for the original developer placeholder: validate the loaded player context and report; no gameplay mutation. |
| `mobs.find <words...>` | Ranked multiword and typo-tolerant command search; read only. |
| `mobs.foreign_supply [search]` | Print the global foreign market supply, optionally filtered by item name or ID; changes nothing. |
| `mobs.help [search]` | List all commands; filter by army, lord, region, misc, or search usage/descriptions. |
| `mobs.is_in_game` | Check whether the local settlement pawn required by gameplay commands is available. |
| `mobs.items [search]` | List supply item IDs and names from the loaded game's item table; optionally filter. |
| `mobs.ping` | Check that this mod's console handler responds; works without a loaded settlement. |
| `mobs.plants` | Inspect selected buildings planted crops: type, position, growth, yield and soil-cell index; read only, first 100 plants. |
| `mobs.pond <place\|remove> [preview]` | Start the native Fishing Pond placement tool or click to remove an owned pond; supports preview. |
| `mobs.recent [1..30]` | List recent successful Mobs commands without replaying them; keeps 30, cleared on mod reload. |
| `mobs.run <filename.txt> [preview]` | Run up to 100 Mobs commands from a local Commands/*.txt file; no scripts, traversal or recursion; preview lists commands; stop on first error. |
| `mobs.skip_day [1..30] [preview]` | Advance days through the native date update rather than overwrite the calendar; maximum 30, preview available. |
| `mobs.speed [0..12]` | Read or request game speed through the native game function; 0 pauses and 1 resumes normally. |
| `mobs.usage <command>` | Explain exact syntax, targeting, previews and click tools without running anything. |
| `mobs.version` | Show the installed Mobs version and supported target. |
| `mobs.weather <rain\|drought\|clear\|end_rain\|end_drought> [instant] [damaging] [preview]` | Start/end rain or drought; optional immediate transition and damaging rain. Supports preview. |
