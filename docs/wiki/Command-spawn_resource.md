# mobs.spawn_resource

Guide for **0.15.0-alpha.1**, game **0.8.117**.

Click to create a registered surface resource group; amount is per clump, defaults to native capacity. Fish/eel require water; preview available.

```text
mobs.spawn_resource <kind> [amount per clump] [1..64 clumps] [rich] [preview]
```

## In-game advice

`mobs.advice.spawn_resource` or `mobs.advice spawn_resource`. These display help without executing the action.

## Target

Run the command, close the console, then click the intended location in an owned region. It is a one-shot tool with a five-minute expiry. mobs.cancel disarms it. Preview also requires the click, but changes nothing.

## Steps

Choose a supported kind. Optionally give amount PER clump and a clump count, then rich. Preview uses the same click workflow; run again without preview to place.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.spawn_resource berries 100 4 preview
mobs.spawn_resource berries 100 4
mobs.spawn_resource iron 1000 1 rich
mobs.spawn_resource eel 400 1
```

## Limits and expected results

Kinds: iron, clay, salt, stone, berries, mushrooms, fish, eel. Count 1..64; amount 1..1000000 per clump. Fish/eel need suitable reachable water; spawned eel harvesting/despawn remains an open report. Deer/hares are not accepted here. No undo.

## Related commands

- [mobs.resource](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-resource) — `mobs.advice.resource`
- [mobs.refresh_resource_icons](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-refresh_resource_icons) — `mobs.advice.refresh_resource_icons`
- [mobs.pond_fish](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-pond_fish) — `mobs.advice.pond_fish`
- [mobs.animal](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-animal) — `mobs.advice.animal`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
