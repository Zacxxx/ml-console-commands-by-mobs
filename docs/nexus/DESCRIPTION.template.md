# ML Console Commands by Mobs

A practical console toolkit for Manor Lords: finish construction, place and clean up
Supplies piles, manage resources and trees, customize regional cards, and find the
right command without memorizing everything.

**Version {{VERSION}} — alpha release for Manor Lords 0.8.117.**

[Complete wiki and tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki) ·
[Every command, advice and examples](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) ·
[All item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs) ·
[Bug report status](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Bug-report-status)

## New in 0.15

- `mobs.advice.pile`, `mobs.advice.spawn_resource`, `mobs.advice.soil` and a detailed
  guide for every base command; `mobs.advice <command>` is equivalent.
- `mobs.tutorial` lists 13 chapters; `mobs.tutorial resources` opens one;
  `mobs.tutorial all` prints the full manual. Reading guidance never executes examples.
- Contextual autocomplete: broad prefixes show commands, while item variants appear
  only after the full item-taking command. Windows response parsing is corrected.
- Selected-building tools read the pawn-owned live selection instead of a temporary
  returned array. This addresses reported invalid-selection failures.
- New mineral deposits use a ground-facing decal and a real finite surface clump,
  plus separate underground reserves. Legacy empty markers can be removed.
- Includes earlier resource size/view and HUD icon/hover-list fixes that were not in 0.14.0.

These changes pass offline checks and exact-build guards. Fresh visuals, mining,
worker harvesting and save/load tests are still needed. The spawned-eel harvesting/
despawn report remains open. Registered huntable deer/hare-node spawning is not
implemented; `mobs.animal` creates individuals only.

## What is included?

- **Construction:** inspect missing materials, supply sites, prepare work for completion,
  pause/resume construction and enable instant completion for new placement.
- **Supplies and piles:** deliver goods to clicked or selected owned buildings, create
  new Supplies piles, clear empty piles and remove selected bugged piles.
- **Forestry:** grow existing world trees, replant/regrow cleared trees and use separate
  forester-sapling and growth-stage tools.
- **Resources:** inspect, refill, create, enrich or remove surface resources and
  underground deposits, and add fish to completed Fishing Ponds.
- **Regional perks:** unlock tier choices, respec, and apply multiple regional card
  effects. Extra cards include their penalties as well as bonuses.
- **Economy and settlement:** treasury, influence, regional wealth, approval,
  population/livestock utilities, building inventories and owned-region targeting.
- **World and farming tools:** weather, time, soil/fertilization, claims, unit/camera
  utilities, and local command files.
- **Command discovery:** {{COMMAND_COUNT}} base command names/aliases, plus dotted advice shortcuts, with live help,
  fixed and game-data completion choices, typo-tolerant search, usage guidance,
  recent successful commands and clearer errors.

This is an independent implementation. The original command mod is not required.
Original k.* aliases are not registered; these commands use mobs.*.

## Requirements and compatibility

- Manor Lords **0.8.117**, Steam pre_release branch, Windows x64 executable.
- A working **UE4SS 3.0.1** loader compatible with your game build.
- The loader's **ConsoleEnablerMod** enabled/configured.

The development loader was UE4SS 3.0.1 beta, Git SHA e3ba1016. Other game builds,
loader builds, and automated mod-manager deployment are unverified. Native helpers
check their supported executable layout and refuse unsupported versions.

[ML-UE4SS loader reference](https://www.nexusmods.com/manorlords/mods/229): choose a
loader file that supports your game build. The current page's stated compatibility
may differ from 0.8.117. The loader and ConsoleEnablerMod are separate dependencies,
not bundled files. Keep an already working loader if you have one.

## Manual installation

1. Close the game and back up your save.
2. Download the main file and extract its **MLConsoleCommandsByMobs** folder into
   `ManorLords/Binaries/Win64/ue4ss/Mods/`.
3. Confirm this path exists:
   `ManorLords/Binaries/Win64/ue4ss/Mods/MLConsoleCommandsByMobs/Scripts/main.lua`.
4. Keep `enabled.txt` inside the mod folder.
5. Start the game, load a settlement, open the configured console key, and run
   `mobs.version`, then `mobs`.

F10 is configured in the development setup. Depending on your console-enabler
configuration, your key may differ. This is a UE4SS mod, not a PAK: do not put it
in Content/Paks/~mods. Manual installation is the documented method.

## Start here

`mobs` — quick-start dashboard.
`mobs.help` — list every registered command.
`mobs.find construction` — search names/descriptions.
`mobs.advice.pile` — detailed steps, targeting, examples and limits.
`mobs.tutorial` — chapter list; use `mobs.tutorial all` for the full tutorial.
`mobs.regions` — list your owned region IDs.
`mobs.region <id>` — pin the owned region to use.
`mobs.status` — check the current command target.
`mobs.finish_constructions preview` — inspect unfinished sites before changing them.
`mobs.pile bread 100` — arm new Supplies placement, then close the console and place it.
`mobs.clear_empty_piles preview` — inspect empty-pile cleanup.
`mobs.cancel` — cancel a pending click tool.

Replace placeholders such as <id> with a value and omit the brackets. Many commands
have preview/guarded undo, but not every action does. Selected-building commands
use buildings you selected before opening the console. Regional targets must
usually belong to your lord.

Type `mobs.` for native prefix completion and use Tab. The description beside a
suggestion shows its syntax. Enter runs the typed command; selecting/completing
text alone does not. Use `mobs.autocomplete refresh` to refresh loaded items,
regions and cards; open Development first if card data is absent. The text fallback
is `mobs.complete give br`. Use `mobs.find` for typo-tolerant discovery.

## Common examples from player questions

`mobs.spawn_resource berries 100 4 preview` — close the console and click owned
land to preview four berry clumps of 100 each. Repeat without preview to create.

`mobs.pond_fish 500` — close the console and click near a completed owned Fishing
Pond. An unfinished pond is rejected; existing shoals use `mobs.refill_resources fish`.

`mobs.spawn_deposit iron 1000 rich` — creates 1000 surface units PLUS 1000
underground units. Rich deep reserves still follow the native endless-mining rules.
`mobs.resource` edits/removes surface clumps; `mobs.deposit` edits underground
reserves; `mobs.remove_deposit` removes the reserve/decal. Real surface clumps
require their own explicit `mobs.resource remove iron` action. Preview first.

`mobs.soil restore all selected preview` — select a planted owned field before
opening the console. Restore removes depletion to the existing baseline;
`mobs.soil set all 100 selected preview` instead sets baseline/current fertility.

`mobs.grow_population 10` — ten native growth attempts, not ten guaranteed people.
Housing, approval/migration and simulation timing still apply. Read the actual counts.

[Read the complete report audit](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Bug-report-status)
for fixed-in-source issues, old-save cleanup and reports that remain open.

## Release status and limits

This is an **alpha release**, not a claim that every variant is gameplay-tested.
Focused user tests confirmed construction, Supplies/pile placement and cleanup,
and regional perk tools. Recent world/weather/soil/forestry variants, native Tab
completion and full save/load persistence still need broader confirmation.
Offline checks pass; they do not replace testing every feature in a live save.

Construction prepares materials/work, then lets the normal simulation finalize
sites. Resume the simulation if paused; workers may still need to reach a site.
The vanilla perk screen displays primary cards only. Extra-card state is stored
in Native/State; preserve that folder when updating.

Remove_selected_piles deletes contents along with selected Supplies piles. Other
demolition/removal commands can also be irreversible. Read usage and preview
when offered. Edits already saved are not reverted when disabling the mod.
Keep a separate untouched save.

## Updating or removing

Update with the game closed. Back up the old mod folder, then merge the new one,
retaining Native/State and your custom Commands files. A full restart loads the
update. Ctrl+R hot reload works only when enabled in your UE4SS configuration.

To disable, close the game and remove enabled.txt, or move the whole mod folder
outside ue4ss/Mods. Keep Native/State if you intend to reinstall. Uninstalling
does not roll back changes already saved in your settlement.

## Reporting bugs

Include game/UE4SS/mod versions, the exact command, target/selection, expected and
actual results, and the relevant UE4SS.log excerpt with personal details removed.
For crashes, include the timestamp and preceding log messages. State whether other
optional mods were disabled for the reproduction.

## Source code and bug reports

[Public GitHub repository]({{REPOSITORY_URL}})
[GitHub releases and downloads]({{RELEASE_URL}})
[Issue tracker]({{ISSUES_URL}})

The public repository contains the independently written source, build tools,
command reference and offline checks. Release downloads include the compiled runtime.

## Credits, source and permissions

Mobs: project direction, feature requests and gameplay feedback/testing.
The UE4SS team: the separate loader and modding API.
Psiae's MLConsoleCommandsMod: feature-reference research. No original DLL/PAK,
implementation source, game assets or saves are redistributed here.

The optional **Source** download contains the original Lua/C source, tests and
build/release tools under the MIT license. Keep its copyright/license notice
when reusing it. It is not needed to play.

Code was developed with generative AI under Mobs' direction. AI also helped
produce this page and its original promotional title card. No generated in-game
art, voices or game assets are included.
