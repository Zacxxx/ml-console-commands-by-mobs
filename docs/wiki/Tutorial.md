# Full tutorial

For **0.16.1-alpha.5**, game **0.8.117**. In game: `mobs.tutorial` lists chapters, `mobs.tutorial all` prints everything.

## 1. Install, check versions and read command syntax

In game: `mobs.tutorial start` or `mobs.tutorial 1`.

This alpha targets Manor Lords 0.8.117 with a compatible UE4SS loader and ConsoleEnablerMod. The original MLConsoleCommands mod is not required. Install the MLConsoleCommandsByMobs folder under ManorLords/Binaries/Win64/ue4ss/Mods, with enabled.txt present. Restart to load changed native helpers. Keep Native/State and custom Commands files when upgrading.

Load a settlement and open your configured console key (F10 in the development setup). Run mobs.version, mobs.ping and mobs. A responding handler proves loading, not that every game action works. Use mobs.help to browse and mobs.find <words> to search.

Angle brackets mean required input; square brackets mean optional input. Pipes separate alternatives. Replace placeholders, omit brackets, and type only one choice. Example: mobs.treasury add 1000. Do not type mobs.treasury <set|add> <amount>.

mobs.advice.pile explains a command without running it. mobs.advice pile is equivalent. mobs.tutorial all prints this entire manual; mobs.tutorial resources opens one chapter. Each guide also links to its wiki page.

Guides: [mobs.advice.version](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-version), [mobs.advice.help](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-help), [mobs.advice.advice](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-advice)

## 2. Choose a region, select buildings and use click tools

In game: `mobs.tutorial targeting` or `mobs.tutorial 2`.

Region commands resolve the pinned target, otherwise selected map region, otherwise current region. Run mobs.regions to list OWNED IDs, mobs.region with an actual listed ID to pin one, then mobs.status to confirm. mobs.region current pins the current region; mobs.region auto clears the pin. IDs are save-specific.

Building commands use actual selection: close the console, click the owned building/field until its information panel is visible, then reopen the console. mobs.building and mobs.inventory inspect a single selected building. A region pin does not select a building. Multi-building actions validate every target before the first write.

Click commands first ARM a tool. Close the console, then click/place the target. They expire after five minutes; mobs.cancel stops pending tools. A preview also needs the click to resolve the target but changes nothing. After a successful preview, enter the real command and click again.

Ownership checks are deliberate. Resources normally require owned ground; bandit_camp instead requires unclaimed ground. A message saying armed does not mean anything was delivered or created yet. Read the later result message.

Guides: [mobs.advice.regions](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-regions), [mobs.advice.region](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-region), [mobs.advice.status](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-status), [mobs.advice.cancel](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-cancel)

## 3. Autocomplete, search, advice and recent commands

In game: `mobs.tutorial discovery` or `mobs.tutorial 3`.

Type mobs. for command names; Tab completes text and Enter executes it. Item variants appear only after a complete item-taking command, so the broad dropdown is not filled by thousands of IDs. Type mobs.pile to reach its item choices.

mobs.autocomplete refresh reloads item/region/card suggestions. Open Development once if card data is not loaded. mobs.autocomplete off disables native suggestions for this session. If native suggestions fail, mobs.complete pile br prints contextual choices and mobs.find supplies ranked typo-tolerant search.

Unknown/ambiguous input is never silently corrected into a gameplay action. Use mobs.advice.<short command> for the target, exact workflow, examples, limits and related commands. mobs.recent 30 prints successful command strings without replaying them. It clears on reload.

Runtime item names may be localized and may differ from internal enum labels. Use mobs.items <search> and copy its numeric ID when a name is ambiguous. Read the wiki item table to discover IDs; verify deliverability in mobs.items.

Guides: [mobs.advice.autocomplete](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-autocomplete), [mobs.advice.complete](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-complete), [mobs.advice.find](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-find), [mobs.advice.recent](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-recent)

## 4. Items, new piles, clicked deliveries and inventories

In game: `mobs.tutorial supplies` or `mobs.tutorial 4`.

Find items: mobs.items bread, mobs.items planks, or mobs.items 17. mobs.pile 17 100 starts native Supplies placement for 100 planks. Close the console and place the preview on owned ground. This makes a new pile and fills it once, after successful placement.

mobs.drop 17 20 arms delivery to clicked owned storage, a pile or a site needing planks. It does not create piles on bare ground. Ineligible clicks leave it armed. mobs.drop with no arguments reads pending status; mobs.cancel cancels.

For already selected buildings, mobs.give 17 20 preview calculates a batch without changing inventory; mobs.give 17 20 applies it. The amount is EACH building, not a shared budget. Production/housing inventories instead use mobs.inventory_add, which can bypass completed-building storage caps.

Construction accepts only its missing materials, accounting for goods already stored and incoming. No generic delivery undo exists. Inspect local goods with mobs.inventory and regional totals with mobs.stock; they are different scopes.

To clean clutter, mobs.clear_empty_piles preview lists confirmed-empty piles in the target region. Run without preview to remove them. mobs.remove_selected_piles preview checks selected Supplies piles; the real command deletes those piles INCLUDING CONTENTS. There is no undo for removal.

Guides: [mobs.advice.items](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-items), [mobs.advice.pile](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-pile), [mobs.advice.drop](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-drop), [mobs.advice.give](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-give), [mobs.advice.inventory_add](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-inventory_add)

## 5. Supply sites, finish work and control new builds

In game: `mobs.tutorial construction` or `mobs.tutorial 5`.

Set the region and check mobs.status. mobs.construction_needs region reports missing material totals. Select one site and run mobs.construction_needs for its detailed bill, including incoming deliveries.

mobs.supply_construction preview supplies a plan for the target region; selected limits the scope to selected owned unfinished/upgrading buildings. Removing preview supplies materials only, not work.

mobs.finish_constructions preview counts unfinished sites. mobs.finish_constructions prepares materials/work through the game. Resume with mobs.speed 1 and let the simulation finalize the sites. Workers can still need to reach them; read per-site failures instead of repeatedly assuming completion.

mobs.construction pause/resume controls unfinished sites in the target region. mobs.instant_build on affects newly placed buildings globally for the session, including materials; switch it off after intended placement. Existing sites use finish_constructions. Demolition uses mobs.demolish selected preview, then the real command with native refund rules and no undo.

Guides: [mobs.advice.construction_needs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-construction_needs), [mobs.advice.supply_construction](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-supply_construction), [mobs.advice.finish_constructions](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-finish_constructions), [mobs.advice.instant_build](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-instant_build)

## 6. Create berries/minerals, understand layers and remove nodes

In game: `mobs.tutorial resources` or `mobs.tutorial 6`.

Berries example: mobs.spawn_resource berries 100 4 preview; close console and click owned ground. This previews FOUR clumps of 100 each, not 100 spread across the group. Repeat without preview and click to create it. Optional rich comes after amount/count: mobs.spawn_resource iron 1000 1 rich.

Kinds are iron, clay, salt, stone, berries, mushrooms, fish and eel. Deer/hares are not supported hunting-node kinds. mobs.resources berries inspects existing clumps in the target region; mobs.refill_resources berries preview refills them to capacity rather than creating new ones.

There are TWO mineral layers: visible finite surface clumps and underground reserves for deep extraction. mobs.resource add iron 100 edits one existing surface clump. mobs.deposit add iron 100 edits an existing underground reserve. A surface icon alone does not prove an underground reserve exists.

New mobs.spawn_deposit iron 1000 rich creates 1000 surface units PLUS 1000 underground units and a ground-facing decal. Rich deep reserves follow native endless/deep-mining rules. The finite amount shown in the resource tooltip comes from the surface clump. Legacy 0.14.0 placements could have only an empty marker, with no finite surface amount. New mineral placement uses a moving native-material preview, centre crosshair and mining-radius ring. Close the console, move to READY owned ground and left-click the exact centre. Blocked clicks stay armed; right-click cancels. Add preview to inspect repeatedly without creating either layer.

To remove surface fish: mobs.resource remove fish preview, close console and click close to the shoal. For eel use eel explicitly; fish never silently selects eel. Remove deletes the whole group; remove_clump deletes one clump. Matching distance is 2500 game units, and ownership still applies.

mobs.remove_deposit iron preview removes underground reserves/decal and colocated EMPTY legacy markers. Real surface clumps stay until mobs.resource remove iron. If an old stripe was already removed but its empty marker remains, mobs.resource remove iron can now remove that marker. Preview first; removals have no undo.

For visible models but missing normal-map icons or paper-map hover details, run mobs.refresh_resource_icons. For older badly scaled land clumps, mobs.resource refresh berries preview repairs size/height/view after a click without changing goods. Do not spawn duplicate nodes to fix an icon.

Spawned fish/eel still need suitable water, worker reachability and native seasonal conditions. The reported eel harvesting/despawn issue remains unconfirmed; do not treat an icon and a full counter as proof that workers can harvest it.

The 0.16 alpha adds mobs.repair_fishing eel preview for an existing shoal: click nearby, inspect the plan, repeat without preview, then check catches and save/reload. It restores native aquatic identity, seasonal behavior and regional availability without refilling goods. Fish use the explicit fish argument. Actual catches and persistence still need gameplay confirmation.

Guides: [mobs.advice.spawn_resource](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-spawn_resource), [mobs.advice.resource](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-resource), [mobs.advice.spawn_deposit New mineral placement uses a moving native-material preview, centre crosshair and mining-radius ring. Close the console, move to READY owned ground and left-click the exact centre. Blocked clicks stay armed; right-click cancels. Add preview to inspect repeatedly without creating either layer.](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-spawn_deposit New mineral placement uses a moving native-material preview, centre crosshair and mining-radius ring. Close the console, move to READY owned ground and left-click the exact centre. Blocked clicks stay armed; right-click cancels. Add preview to inspect repeatedly without creating either layer.), [mobs.advice.deposit](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-deposit), [mobs.advice.remove_deposit](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-remove_deposit), [mobs.advice.refresh_resource_icons](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-refresh_resource_icons), [mobs.advice.spawn_wildlife](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-spawn_wildlife), [mobs.advice.repair_fishing](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-repair_fishing)

## 7. Fishing Ponds, natural fish and eel

In game: `mobs.tutorial fishing` or `mobs.tutorial 7`.

mobs.pond place opens a moving footprint preview with relaxed rules: the actual pond outline, no extra margin, up to 10 metres of height variation and neighbouring regions owned by your lord. Close the console and read green READY or red BLOCKED with the reason. Left-click a valid site for one completed empty pond; blocked clicks keep the tool active. Right-click or mobs.cancel cancels. mobs.pond place preview stays read-only. Add strict to restore the old rectangle, 1-metre margin, 2-metre height limit and single-region rule. No builders are needed; stock fish separately. Existing unfinished ponds are not reinitialized.

Run mobs.pond_fish 500 preview, close the console and click within 1500 game units of the completed owned pond. Repeat without preview to add ONE shoal. Existing fish are rejected rather than duplicated; use mobs.refill_resources fish preview for an existing shoal.

Natural-water groups use mobs.spawn_resource fish or mobs.spawn_resource eel with suitable placement. This differs from putting fish food in a granary or creating a pond building. Fish and eel are different resource kinds; inspect mobs.resources to choose correctly.

If workers ignore a new shoal, record the exact command, month/season, fishing building type, work area, water placement and behavior after reload. Worker usability and save/load of spawned shoals still require live confirmation. Removal of a pond and removal of its resource are separate operations; preview before deleting anything.

Guides: [mobs.advice.pond](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-pond), [mobs.advice.pond_fish](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-pond_fish), [mobs.advice.refill_resources](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-refill_resources), [mobs.advice.resource](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-resource)

## 8. World trees, intermediate stages and forester plantings

In game: `mobs.tutorial forestry` or `mobs.tutorial 8`.

mobs.grow_trees preview finds eligible world-tree growth records, including untracked young/intermediate stages. mobs.grow_trees processes them in batches until native maturity or a reported blocked state. Wait for the completion message.

mobs.grow_saplings targets registered saplings, including those planted by foresters. mobs.grow_stage advances each eligible record once instead of forcing maturity. Add area to limit either tool to ONE selected owned building with an explicit limited work circle.

mobs.replant_trees arms one oak-sapling replant click on cleared owned ground. It is one tree per placement, not a brush that fills a region. mobs.regrow_trees combines the one-tree replant click with region growth.

Decorative bushes are not trees for these tools. Native collision checks and growth transitions can refuse records. mobs.cancel stops future clicks/batches; it does not reverse growth already performed. There is no forestry undo.

Guides: [mobs.advice.grow_trees](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-grow_trees), [mobs.advice.grow_saplings](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-grow_saplings), [mobs.advice.grow_stage](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-grow_stage), [mobs.advice.replant_trees](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-replant_trees), [mobs.advice.regrow_trees](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-regrow_trees)

## 9. Read fertility, edit soil and inspect planted crops

In game: `mobs.tutorial farming` or `mobs.tutorial 9`.

Select an owned field before opening the console. mobs.fertility wheat reads native averages and fertilization counters. mobs.fertilization on selected preview toggles fertilization PERMISSION; it does not restore exhausted soil and does not bypass fertilization prerequisites.

mobs.soil set all 100 selected preview plans actual soil-grid changes for planted cells. Without preview it sets current and baseline fertility. mobs.soil restore all selected instead restores depletion up to the current baseline; a naturally poor baseline remains poor.

For area scope, select an owned building and first define an explicit limited work circle. mobs.soil restore barley area preview targets cells in that work area. Area does not mean the camera view or all fields in the pinned region.

Only wheat, flax and barley channels exist here. Rye shares wheat; oats share barley. Unplanted fields can select zero planted cells, so inspect mobs.plants or use a limited work area. Fertility overlays may update later than stored values.

mobs.undo_soil preview checks the latest batch and refuses newer changed values or changed ownership. mobs.undo_fertilization is a separate permission undo. Neither is a general save rollback.

Guides: [mobs.advice.fertility](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-fertility), [mobs.advice.fertilization](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-fertilization), [mobs.advice.soil](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-soil), [mobs.advice.plants](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-plants), [mobs.advice.undo_soil](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-undo_soil)

## 10. Regional cards, extra cards and respec

In game: `mobs.tutorial perks` or `mobs.tutorial 10`.

These commands edit regional Origins (tier 1) and Rural Foundations (tier 2) cards, not development-tree points. Choose an owned command-target region, open Development once to load data, then mobs.perks list.

Use the listed number or a unique card key: mobs.perks add BambergSmallholders preview, then the same command without preview. This adds an extra card while retaining primary choices. Both bonuses AND penalties apply. Shared effects apply once; primary cards are not duplicated.

The vanilla card screen displays primary choices only; use mobs.perks list to inspect extras. mobs.perks remove BambergSmallholders removes one extra. mobs.perks clear removes all extras in this region while keeping primaries.

mobs.perk_points 2 restores the tier-2 choice by resetting it. mobs.respec_perks all resets normal choices. Resetting tier 1 ALSO resets tier 2 because of their dependency; settlement unlock gates remain.

Extra-card bookkeeping lives in Native/State. Preserve that folder across upgrades and back it up with your mod state. Rebuilding effects and full save/load persistence still need continued live confirmation; keep a separate untouched save.

Guides: [mobs.advice.perks](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-perks), [mobs.advice.perk_add](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-perk_add), [mobs.advice.perk_remove](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-perk_remove), [mobs.advice.perk_points](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-perk_points), [mobs.advice.respec_perks](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-respec_perks)

## 11. Economy, population, livestock and families

In game: `mobs.tutorial settlement` or `mobs.tutorial 11`.

mobs.treasury add 1000 affects your lord. mobs.wealth add 1000 affects the chosen owned region. Use set for an exact final balance. mobs.approval set 80 is bounded to 0..100 and may later be recalculated by the game. mobs.status checks targets and values.

mobs.undo only reverses the latest unchanged economy edit in this mod session. If the simulation or another action changed that value, it refuses. Inventory, spawning, construction and removal are not economy undo actions.

In the 0.16.0-alpha.3, mobs.grow_population 3 means three PEOPLE, not three families or repeated scheduled checks. Use mobs.grow_population status, then mobs.grow_population 3 preview. Apply without preview to create residents now through native family/home registration, bypassing approval and scheduled arrival days. There must be enough completed, active, non-mourning housing; homeless families take priority over new households. The date and approval are not forced, and new people have normal ongoing needs. A native refusal stops and reports the actual count without retrying. livestock_cooldown reset clears only the next-order cooldown; skip_mourning clears mourning timers without reviving residents.

mobs.animal ox 1 preview arms individual animal spawning. livestock_cooldown reset clears the next order cooldown but does not order or spawn an animal. Deer/hare individual spawning does not create registered hunting deposits.

For a person/family, hover or follow an owned unit, inspect mobs.unit, select one completed same-region house and preview mobs.rehouse selected. Capacity checks remain. mobs.skip_mourning clears active building mourning timers; it does not revive residents.

For a real hunting deposit, use mobs.spawn_wildlife deer preview or hare. Close the console and click clear owned ground. Apply without preview and click that spot again: the node and herd home are placed at your click, with animals nearby. Population is the midpoint of native normal/rich settings; rich selects its larger/native rich range. Include that site in a staffed hunting camp work area. Hunting and herd persistence in this alpha need live testing.

Guides: [mobs.advice.treasury](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-treasury), [mobs.advice.wealth](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-wealth), [mobs.advice.approval](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-approval), [mobs.advice.grow_population](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-grow_population), [mobs.advice.animal](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-animal), [mobs.advice.rehouse](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-rehouse)

## 12. Time, weather, claims, units and command files

In game: `mobs.tutorial world` or `mobs.tutorial 12`.

mobs.speed 0 pauses; mobs.speed 1 resumes. mobs.skip_day 1 preview requests native day updates, whose events may run; it is not equivalent to simulating all worker movement.

mobs.weather rain preview starts a normal weather transition when applied; instant requests immediate values. damaging applies only to rain. mobs.weather clear instant clears rain/drought immediately, but later simulation can choose new weather.

mobs.map_regions lists all map IDs. claim start requires a selected/explicit valid region, and claim finish completes a claim already belonging to you. This does not silently turn any foreign region into owned land.

mobs.follow follows a hovered unit, and mobs.follow off stops. mobs.teleport unit preview or squads preview arms a destination click. Existing orders remain active, so relocated units may move again. Hostile raiders/bandit tools create threats, not your own troops.

Command files are local text under Commands/*.txt with one exact Mobs command per line. mobs.run example.txt preview lists up to 100 commands; actual execution stops at the first error and keeps earlier completed changes. Scripts, traversal and recursive run are rejected. A batch of click tools only arms tools; it does not supply missing clicks.

Guides: [mobs.advice.speed](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-speed), [mobs.advice.weather](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-weather), [mobs.advice.claim](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-claim), [mobs.advice.teleport](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-teleport), [mobs.advice.run](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-run)

## 13. Diagnose, report accurately and keep upgrade state

In game: `mobs.tutorial troubleshooting` or `mobs.tutorial 13`.

For a failure include mobs.version, game/UE4SS versions, the exact typed command, target region, selected object, expected result, actual message and whether it persists after save/reload. Attach relevant log excerpts with personal paths removed. A screenshot should include the result message and target.

Wrong target: run mobs.status, clear an unintended pin with mobs.region auto, or explicitly pin a real owned ID. Selection failure: close console and select the actual owned building first; region targeting and building selection are distinct. Native helpers refuse unsupported game layouts.

No matching deposit: surface clumps and underground reserves are separate. Use resource for clumps and deposit for reserves. Fish and eel are distinct. Search operates near the actual world position, not just a distant paper-map icon.

Alpha status is deliberate: source checks, a successful native call, a map icon and a working harvest/save-load cycle are different evidence. The bug tracker marks remaining worker/persistence reports open until reproduced and verified.

Upgrade with the game closed. Back up the old mod folder, merge the new files and retain Native/State plus your Commands files. Restart to load native helpers; Lua hot reload alone can leave an older DLL loaded. Removing the mod does not undo changes already saved. Keep an untouched save for comparison.

Guides: [mobs.advice.version](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-version), [mobs.advice.building](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-building), [mobs.advice.resources](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-resources), [mobs.advice.refresh_resource_icons](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-refresh_resource_icons)
