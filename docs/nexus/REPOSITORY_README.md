# ML Console Commands by Mobs

![ML Console Commands by Mobs](assets/nexus/cover-1600x900.png)

Console tools for **Manor Lords 0.8.117**: construction, Supplies piles, resources,
trees, regional perk cards and settlement management, with searchable command help.

**{{VERSION}} · alpha · {{COMMAND_COUNT}} registered command names/aliases · MIT**

[Download the alpha release]({{RELEASE_URL}}) ·
[Installation](docs/INSTALL.md) · [Command reference](docs/COMMANDS.md) ·
[Known limits](docs/KNOWN_ISSUES.md) · [Report a bug]({{ISSUES_URL}})

## Play

Download the **-Nexus.zip** runtime file from Releases. This repository's automatic
“Source code” ZIP is for development and does not contain the compiled helpers.

Install a working UE4SS 3.0.1 loader compatible with game 0.8.117 and enable its
ConsoleEnablerMod. Extract MLConsoleCommandsByMobs into
`ManorLords/Binaries/Win64/ue4ss/Mods/`. Keep enabled.txt inside the mod folder.
Load a settlement, open the configured console key (F10 in the development setup),
and run `mobs.version`, then `mobs`.

```text
mobs.find construction
mobs.usage pile
mobs.regions
mobs.region <id>
mobs.finish_constructions preview
mobs.pile bread 100
mobs.cancel
```

Use an actual owned region ID in place of <id>. Read help and previews before edits.

## Included tools

- Construction reports, missing-material supply, completion preparation, pause/resume
  and a session-global instant-build switch for new placements.
- Click/selected-building deliveries, new Supplies piles and empty/selected pile cleanup.
- Natural resources, deposits, forestry, forester saplings and growth stages.
- Regional perk tier choices, respec and additional card effects.
- Economy, inventories, population/livestock, weather/time, soil/farming and units.
- Native prefix suggestions, fixed/game-data choices, typo-tolerant search,
  exact syntax help and recent successful commands. Native UI interaction is still
  awaiting broader in-game confirmation; use mobs.complete for text suggestions.

This is an independent implementation. No original-mod DLL/PAK, implementation
source, game assets, saves or UE4SS loader binaries are included. The original
k.* aliases are not registered.

## Status

The reference checklist has scoped practical counterparts for all 74 identifiers
in the supplied 1.0.4-a.4 inventory. This measures coverage, not identical behavior
or gameplay validation of every variant. Focused user confirmations cover construction,
Supplies placement/cleanup and regional perks. Recent variants, native autocomplete
and full save/load persistence still need broader confirmation.

Native helpers target the verified 0.8.117 executable and refuse unsupported
layouts. Other game/loader builds and separate native-Windows testing are unverified.
Changes already saved are not reverted by uninstalling. Keep a separate untouched save.

## Build and contribute

See [the build guide](docs/BUILD.md). Build all five original helper DLLs before
running `bash scripts/test.sh`; then `python3 scripts/prepare_nexus.py --out ./release`
generates clean runtime/source downloads and Nexus page materials.

GitHub Actions rebuilds helpers and runs offline checks. Passing these checks does
not prove live gameplay or save persistence. Bug reports should give exact versions,
commands, targets and relevant sanitized log excerpts.

## Credits and transparency

Mobs directs the project and supplies feature requests and gameplay feedback/testing.
Code and release material were developed using generative AI under that direction.
Psiae's MLConsoleCommandsMod informed feature research; its implementation and assets
are not redistributed. The UE4SS team provides the separate loader and modding API.

Original project source and promotional graphics are available under [MIT](LICENSE).
Third-party game/mod/loader content is not licensed by this repository.
