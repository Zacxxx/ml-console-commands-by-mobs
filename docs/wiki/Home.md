# ML Console Commands by Mobs wiki

Documentation for **0.16.1-alpha.6**, targeting **Manor Lords 0.8.117**. This is an alpha; read the [report status](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Bug-report-status) for what is fixed in source and what still needs gameplay confirmation.

- [Start-to-finish tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) — installation, syntax, selection, regions, click placement, construction, piles, resources, fishing, forestry, farming, perks and troubleshooting.
- [All 96 base commands and aliases](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) — every entry links to detailed advice, steps and copyable examples.
- [All 212 item enum IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs) — names, delivery caveats, resource kinds, JSON and CSV.
- [Public bug-report audit](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Bug-report-status) — Nexus reports and remaining validation.
- [Downloads](https://github.com/Zacxxx/ml-console-commands-by-mobs/releases) · [Source](https://github.com/Zacxxx/ml-console-commands-by-mobs) · [Report an issue](https://github.com/Zacxxx/ml-console-commands-by-mobs/issues) · [Nexus page](https://www.nexusmods.com/manorlords/mods/433).

## Fast examples

```text
mobs.version
mobs.regions
mobs.region current
mobs.status
mobs.advice.pile
mobs.advice.spawn_resource
mobs.tutorial resources
mobs.tutorial all
```

Region IDs vary per save. Select actual owned buildings before opening the console for selection commands. Click tools require closing the console and placing/clicking after the command arms. Previews change nothing; run the real command and click again to apply it.

## Common questions

- **Berries:** `mobs.spawn_resource berries 100 4`, close console, click owned ground. This creates four clumps of 100 each. [Guide](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-spawn_resource).
- **Pond fish:** `mobs.pond place` creates a completed empty pond at your click; then `mobs.pond_fish 500` and click near it. [Guide](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-pond_fish).
- **Remove rich fish/eel:** `mobs.resource remove fish preview` (or eel). Close console and click near the actual shoal; repeat without preview to apply. Exact kind and ownership matter. [Guide](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-resource).
- **Underground vs surface:** `deposit` edits reserves; `resource` edits visible clumps. [Full explanation](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial#6-create-berriesminerals-understand-layers-and-remove-nodes).
- **Wild animals:** `mobs.spawn_wildlife deer` or `hare` creates a native herd/node at your clicked location. Hunting/save-load checks are pending. `mobs.animal` creates individuals separately. [Guide](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-spawn_wildlife).

The runtime guides and this wiki are generated from the same maintained data. Source/static checks do not establish harvesting, visual or save/load success for every command variant.
