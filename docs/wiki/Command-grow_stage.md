# mobs.grow_stage

Guide for **0.16.0-alpha.3**, game **0.8.117**.

Advance each registered growing tree once through native growth; optionally target one limited work area, supports preview.

```text
mobs.grow_stage [area] [preview]
```

## In-game advice

`mobs.advice.grow_stage` or `mobs.advice grow_stage`. These display help without executing the action.

## Target

Your owned command-target region. Run mobs.regions, then mobs.region with a listed ID; confirm mobs.status. mobs.region auto clears the pin. For area, select ONE owned building with an explicitly limited work area.

## Steps

Preview first. grow_saplings matures registered plantings, including forester saplings. grow_stage advances each eligible record one native stage instead of fully maturing it.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.grow_stage area preview
```

## Limits and expected results

The area scope uses the selected building work circle, not the camera viewport. Native transitions can be blocked. Completion may run in batches; cancel stops future batches only. No undo.

## Related commands

- [mobs.grow_trees](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-grow_trees) — `mobs.advice.grow_trees`
- [mobs.plants](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-plants) — `mobs.advice.plants`
- [mobs.cancel](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-cancel) — `mobs.advice.cancel`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
