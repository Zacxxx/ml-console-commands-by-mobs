# ML Console Commands by Mobs

Version 0.16.1-alpha.5 · alpha · Manor Lords 0.8.117 (Steam, pre_release branch)

Console tools for your settlement: construction, supplies and new piles,
resources, forestry, regional perk cards, economy, weather and time, with
searchable help and contextual command suggestions.

## Requirements

- Manor Lords **0.8.117**, Windows x64 game executable. Other game builds are not supported.
- A working **UE4SS 3.0.1** installation compatible with that game build.
  Development used UE4SS 3.0.1 beta, Git SHA e3ba1016; other loader builds are unverified.
- The loader's **ConsoleEnablerMod**, enabled and configured to open the console.
  F10 is the configured key in the development setup; some loader setups use tilde.

The loader is a separate dependency. It is not bundled here. Its Nexus page is
https://www.nexusmods.com/manorlords/mods/229 — check that the file you choose
supports your game build; its displayed compatibility may differ from 0.8.117.
An existing working loader does not need to be replaced just to install this mod.

The original MLConsoleCommandsMod is not required and is not included. Disable it
when trying this mod to keep troubleshooting straightforward.

## Install manually

1. Close the game and back up the save you intend to use.
2. Extract the **MLConsoleCommandsByMobs** folder into:
   `ManorLords/Binaries/Win64/ue4ss/Mods/`
3. Check the resulting path:
   `ManorLords/Binaries/Win64/ue4ss/Mods/MLConsoleCommandsByMobs/Scripts/main.lua`
4. Keep `MLConsoleCommandsByMobs/enabled.txt` present. With a working UE4SS loader,
   this marker enables the mod; it does not replace installing the loader itself.
5. Start the game, load your settlement, and open the console with your configured key.
6. Enter `mobs.version`, then `mobs` or `mobs.help`.

Do not place this archive in Content/Paks or ~mods. Do not copy the mod's native
helpers beside the game executable; keep the supplied Native folder inside this mod.
Manual installation is the documented method; Vortex deployment has not been tested.

## First commands

- `mobs` — show the quick-start dashboard.
- `mobs.find construction` — search command names and descriptions.
- `mobs.usage pile` — explain syntax and targeting for a command.
- `mobs.help region` — list region commands; also try lord, army or misc.
- `mobs.regions`, then `mobs.region <id>` — pin an owned region.
- `mobs.status` — inspect balances and the current region target.
- `mobs.finish_constructions preview` — inspect unfinished construction in that region.
- `mobs.pile bread 100` — start native Supplies placement, then close the console and place it.
- `mobs.cancel` — stop pending click tools.

Replace placeholders such as <id> with a value and omit the brackets. Not every
command has preview or undo; read its help before running it. Most commands need
a loaded settlement. Regions/buildings must generally belong to your lord.

For native completion, type `mobs.` and use Tab. Fixed choices, item names/IDs,
owned region IDs and loaded regional cards are suggested. Use
`mobs.autocomplete refresh` after opening Development if cards are missing, or
`mobs.autocomplete off` to disable our dropdown entries. The text alternative is
`mobs.complete give br`. Completing text does not execute it; Enter does.
Native dropdown rendering and Tab cycling await broader in-game confirmation.

Construction completion supplies missing materials and prepares work; the game
still finalizes buildings through normal simulation. Resume the simulation if paused;
workers may need to reach a site. Forestry commands operate in batches; read their
reported result and use `mobs.cancel` to cancel further batches.

See COMMANDS.md for the complete registry and KNOWN_ISSUES.md for limitations.

## Updating

With the game closed, back up your existing MLConsoleCommandsByMobs folder. Extract
the update over it, preserving `Native/State/` and custom files in `Commands/`.
Do not delete Native/State when retaining extra regional cards. If you changed the
bundled example.txt, keep your copy. A full game restart is the simplest way to
load an update. Ctrl+R reload requires UE4SS hot reload to be explicitly enabled;
this mod does not enable that global loader setting for you.

## Disabling and removal

Close the game. Remove enabled.txt to disable, or move the whole mod folder outside
ue4ss/Mods to remove it. Keep a backup of Native/State if you may reinstall.
Disabling the mod does not reverse edits already saved in a settlement. Keep an
untouched save to return to. Use `mobs.instant_build off` before disabling if you
enabled it and are continuing the same game session; it is a session-global toggle.
Extra card bookkeeping is stored in Native/State, outside the game save. Those
records are needed to restore stacked extra effects while the mod is active.

## Compatibility and status

This is an alpha release. It has focused user confirmations for construction,
Supplies placement/cleanup and regional perk tools, plus offline checks. Newer
world, weather, forestry, soil and console-UX variants still need gameplay and
save/reload confirmation. No universal compatibility or crash-free guarantee is made.
Native helpers check the target executable and refuse unsupported layouts.
The development environment used the Windows game via Steam Proton on Linux;
a separate native-Windows end-to-end release test is not recorded.

## Source and issue tracker

Source: https://github.com/Zacxxx/ml-console-commands-by-mobs
Releases: https://github.com/Zacxxx/ml-console-commands-by-mobs/releases
Issues: https://github.com/Zacxxx/ml-console-commands-by-mobs/issues

## Credits and permissions

Mobs: project direction, feature design and gameplay feedback/testing.
Code and release text were developed using generative AI under Mobs' direction.
Psiae's MLConsoleCommandsMod informed feature research. Its code, DLL/PAK and
assets are not included or required. The UE4SS team provides the separate loader.
This is an independent implementation, not an official update to the original mod.

Original Mobs source is licensed under MIT; keep the copyright/license notice.
Manor Lords and third-party content are not relicensed by this package.

## Repair an existing invisible resource group

For the 0.14.1-alpha.1 development patch, restart the game and enter
`mobs.resource refresh berries preview`. Close the console and click near the
existing berry group in your owned region. Repeat with
`mobs.resource refresh berries` to apply. This refreshes ground height, the
resource-specific size and current-view visibility; it keeps the group, berry
amount, capacity and richness. Fish/eel and building-attached resources are
excluded. New placement keeps the same `mobs.spawn_resource` syntax. Visual
confirmation of this patch remains pending.

## Repair missing resource icons or map hover details

In the 0.14.2-alpha.1 development patch, reload the mod (Ctrl+R when UE4SS hot
reload is enabled), or restart the game, then run:

`mobs.refresh_resource_icons preview`

`mobs.refresh_resource_icons`

No click is required. This synchronizes the HUD's cached node list with the
world registry. Resources, their positions, quantities, capacity and richness
are unchanged. New spawns and removals synchronize the list automatically.
Visual confirmation of this HUD patch is still pending.

## Detailed guides and wiki

`mobs.advice.pile` (or `mobs.advice pile`) explains a complete workflow without
running it. Every base command has a guide. `mobs.tutorial` lists 13 chapters;
`mobs.tutorial resources` reads one and `mobs.tutorial all` prints the full manual.

[Wiki](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki) ·
[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) ·
[Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs) ·
[Report status](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Bug-report-status).

The package also includes TUTORIAL.md and ITEM_IDS.csv for offline reading.
Restart the game when upgrading native helpers; Lua hot reload alone can keep an
older DLL loaded. Preserve Native/State and custom Commands files.


## Eel repair and huntable wildlife

After restarting, check `mobs.version` reports 0.16.1-alpha.5.

- Existing eel shoal: `mobs.repair_fishing eel preview`, then repeat without
  preview. Close the console and click near the same owned shoal after each line.
  Amounts/capacity/richness stay intact; native identity, seasonal behavior and
  regional availability are repaired. Use `fish` explicitly for fish. Ponds excluded.
- Huntable herd: `mobs.spawn_wildlife deer preview`, then repeat without preview.
  Close the console and click clear owned ground after each line. The node is
  placed there with animals nearby. `hare` and optional `rich`
  are supported. Locate the new node and include it in a staffed camp work area.
- Detailed help: `mobs.advice.repair_fishing` and `mobs.advice.spawn_wildlife`.

Use a separate test save. Resume simulation, confirm actual fishing/hunting catches,
then save separately and reload to check persistence. These game-session results
remain unverified; a visible node alone is not proof. No spawn/delete undo.
The wiki and release include these 0.16 alpha commands; harvesting and persistence still need live confirmation.


## Immediate population creation

`mobs.grow_population status` shows housing places, homeless families, approval and
natural monthly growth. `mobs.grow_population 3 preview` checks a request for three
people; run without preview to add them immediately through native family/home
creation. The number now means PEOPLE, not growth attempts or families (1..10,
default 1). No click or wait for a scheduled arrival day is required. The command
does not force approval or advance the calendar. Enough completed, active,
non-mourning housing is required for the whole request. Native failures stop and
report actual changes without retrying; there is no undo. Live/save-load testing
of this alpha is pending.

## Prebuilt Fishing Ponds

`mobs.pond place preview` opens a moving, read-only footprint guide. Close the
console and move over owned terrain; click to report, right-click to cancel. Run
`mobs.pond place` to use the same guide and left-click a READY site to create
one completed empty pond without builders. Then use `mobs.pond_fish 500 preview` / `mobs.pond_fish 500`, each
followed by its own click near the pond. Fish now use native pond anchors.

Existing unfinished ponds are not automatically completed or reinitialized.
Placement, water appearance, actual catches and save/load still need gameplay
confirmation. Pond placement has received successful user testing; restart after upgrading.


## Moving pond placement preview

`mobs.pond place` now displays the actual pond footprint with relaxed rules: no
extra margin, up to 10m of height variation and neighbouring owned regions. Add
`strict` for the previous clearance rectangle, 2m limit and single-region rule. Close
the console and move over terrain: green READY means the current check passes;
red BLOCKED includes the reason. Left-click a valid site to create one completed
empty pond. A blocked click keeps the preview active. Right-click or `mobs.cancel`
cancels. `mobs.pond place preview` stays read-only for repeated checks.

The outline previews size, not the final terrain/water deformation.
The coloured label is always available; outline tint depends on the engine material.
Stock the finished pond separately with `mobs.pond_fish 500`. Restart after updating;
pond placement has received successful user testing; extended harvesting and persistence checks remain open.


## Place deposits where you click

Run `mobs.spawn_deposit iron 1000`, close the console and move the mouse. The
preview shows the game's native deposit ground material, a centre crosshair and
a mining-radius ring, with a green READY or red BLOCKED label. Left-click a READY
location to create one mineral group at that centre. Native terrain snapping only
changes height. Blocked clicks keep the tool active; right-click or `mobs.cancel`
cancels. `mobs.spawn_deposit clay 2000 rich` and salt work the same way.

Add `preview` to inspect repeatedly without creating anything. The native ring is
20m normal / 25m rich on this build; it shows mining range, not an empty-clearance
requirement. Each amount goes to both surface and underground layers. The screenshot
error about an unavailable mineral template is fixed by using the native engine's
mineral classes. Restart after updating the native helper. Placement has received successful user testing; extended mining and persistence
checks remain open.


## Remove leaked mineral terrain artwork

Placed iron/clay/salt deposits now match the natural terrain appearance: no giant
paper-map imprint or extra ore model. The separate HUD/paper-map icons and tooltip
remain. Surface stones stay visible. Amounts, richness and mining data are retained.

Existing Mobs deposits receive a visual-only repair shortly after loading. Run
`mobs.refresh_resource_icons` to apply it immediately, or append `preview` for a
read-only count. Restart after updating the native helper. There is no need to
delete/recreate existing deposits. User testing confirmed the visual repair. Extended mining and persistence checks remain open.
