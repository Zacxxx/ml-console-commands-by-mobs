# mobs.soil

Guide for **0.16.1-alpha.6**, game **0.8.117**.

Set baseline/current soil fertility or restore depletion for selected planted plots or limited work areas; 0..100%, preview and guarded undo.

```text
mobs.soil <set|restore> <wheat|flax|barley|all> [0..100] [selected|area] [preview]
```

## In-game advice

`mobs.advice.soil` or `mobs.advice soil`. These display help without executing the action.

## Target

Select the owned building in the normal game view BEFORE opening the console. A pinned region does not select buildings. Up to 32 buildings only where the command explicitly allows a batch.

## Steps

For selected scope, select planted fields/plots. For area, set an explicit limited work area on each selected owned building. set takes a percentage; restore has no percentage argument. Preview first.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.soil set all 100 selected preview
mobs.soil set wheat 80 selected
mobs.soil restore all selected preview
mobs.soil restore barley area preview
```

## Limits and expected results

set changes baseline AND current fertility. restore removes depletion up to existing baseline, so it does not make poor baseline soil perfect. Rye shares wheat soil; oats share barley. Unplanted plots can select zero cells: use plants to inspect or a limited work area. Overlay may refresh later.

## Related commands

- [mobs.plants](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-plants) — `mobs.advice.plants`
- [mobs.fertility](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-fertility) — `mobs.advice.fertility`
- [mobs.undo_soil](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-undo_soil) — `mobs.advice.undo_soil`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
