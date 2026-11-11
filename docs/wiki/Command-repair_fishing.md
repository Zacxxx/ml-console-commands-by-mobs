# mobs.repair_fishing

Guide for **0.16.1-alpha.6**, game **0.8.117**.

Click near an owned eel/fish shoal to restore native template identity, seasonal flag, height and registration. Preserves amounts/capacity; excludes ponds. Default eel; range 2500; preview available. Candidate: worker/save-load validation pending.

```text
mobs.repair_fishing [eel|fish] [preview]
```

## In-game advice

`mobs.advice.repair_fishing` or `mobs.advice repair_fishing`. These display help without executing the action.

## Target

Run the command, close the console, then click the intended location in an owned region. It is a one-shot tool with a five-minute expiry. mobs.cancel disarms it. Preview also requires the click, but changes nothing.

## Steps

Default kind is eel. Run preview, close the console and click near the actual shoal, within 2500 game units. Read the planned identity, regional registration and availability-tag counts. Repeat without preview and click the SAME shoal. Resume simulation; ensure a staffed fishing workplace has access to appropriate water. Check actual catches, then save separately and reload.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.repair_fishing preview
mobs.repair_fishing eel
mobs.repair_fishing fish preview
mobs.repair_fishing fish
```

## Limits and expected results

Candidate repair for existing eel/fish nodes; worker harvesting and persistence are not yet verified. Restores the live game template identity/seasonal flag, native placement height, region resource registration, availability tag and map view/HUD. Amounts, capacity and richness remain unchanged. Rejects unavailable template defaults, other resource kinds and building-attached pond fish. Fish and eel never substitute for each other. Does not create a missing/deleted shoal, fix every shoreline/reachability problem, or undo earlier depletion. No undo.

## Related commands

- [mobs.spawn_resource](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-spawn_resource) — `mobs.advice.spawn_resource`
- [mobs.resource](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-resource) — `mobs.advice.resource`
- [mobs.pond_fish](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-pond_fish) — `mobs.advice.pond_fish`
- [mobs.refresh_resource_icons](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-refresh_resource_icons) — `mobs.advice.refresh_resource_icons`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
