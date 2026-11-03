# ML Console Commands by Mobs

Version 0.14.0-alpha.1 · Manor Lords 0.8.117 (Steam, pre_release branch)

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
