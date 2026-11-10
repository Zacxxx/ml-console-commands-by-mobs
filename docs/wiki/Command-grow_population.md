# mobs.grow_population

Guide for **0.16.1-alpha.5**, game **0.8.117**.

Add 1..10 human residents immediately through native family/housing creation; bypasses natural approval/arrival-day gates. Requires usable housing; status explains capacity; preview available; no undo.

```text
mobs.grow_population [1..10|status] [preview]
```

## In-game advice

`mobs.advice.grow_population` or `mobs.advice grow_population`. These display help without executing the action.

## Target

Your owned command-target region. Run mobs.regions, then mobs.region with a listed ID; confirm mobs.status. mobs.region auto clears the pin.

## Steps

Run status to inspect approval, the game natural monthly growth result, usable housing places and homeless families. Preview the requested 1..10 PEOPLE, then run without preview to create them now through the native resident/family/home path. Existing incomplete eligible families are filled first; new families use vacant completed housing. No click is needed.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.grow_population status
mobs.grow_population 3 preview
mobs.grow_population 3
mobs.grow_population 10 preview
```

## Limits and expected results

0.16.0-alpha.3 changes the number from repeated growth attempts to actual people, not families. Default 1; maximum 10 per call. Explicit creation bypasses the natural approval/arrival-day gates without changing the date or forcing approval. All planned home entrances are preflighted before creation; enough housing is required for the whole request. Sleeping/unfinished/mourning homes are excluded. Existing homeless families take priority over new households. Native failures stop and report actual population change without retrying or rolling back earlier arrivals. New population has ordinary needs and can later leave under normal game rules. Live/save-load confirmation remains pending. No undo.

## Related commands

- [mobs.approval](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-approval) — `mobs.advice.approval`
- [mobs.rehouse](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-rehouse) — `mobs.advice.rehouse`
- [mobs.regions](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-regions) — `mobs.advice.regions`
- [mobs.status](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-status) — `mobs.advice.status`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
