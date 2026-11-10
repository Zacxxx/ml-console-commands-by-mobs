# mobs.supply_construction

Guide for **0.15.0-alpha.1**, game **0.8.117**.

Supply missing construction materials in the target region or selected sites; supports preview. Does not complete work.

```text
mobs.supply_construction [selected] [preview]
```

## In-game advice

`mobs.advice.supply_construction` or `mobs.advice supply_construction`. These display help without executing the action.

## Target

Your owned command-target region. Run mobs.regions, then mobs.region with a listed ID; confirm mobs.status. mobs.region auto clears the pin. Use selected explicitly to operate on selected owned sites instead.

## Steps

Preview first. The default supplies missing materials across the target region; selected limits it to selected unfinished/upgrading buildings.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.supply_construction preview
mobs.supply_construction selected preview
mobs.supply_construction selected
```

## Limits and expected results

Supplies materials only; it does not finish work. All selected targets must be valid sites. No undo.

## Related commands

- [mobs.finish_constructions](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-finish_constructions) — `mobs.advice.finish_constructions`
- [mobs.construction_needs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-construction_needs) — `mobs.advice.construction_needs`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
