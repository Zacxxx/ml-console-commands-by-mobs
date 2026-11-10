# mobs.fertility

Guide for **0.16.0-alpha.3**, game **0.8.117**.

Read crop fertility and fertilization counters for selected owned fields; does not restore or set soil fertility.

```text
mobs.fertility [wheat|flax|barley|rye|oats]
```

## In-game advice

`mobs.advice.fertility` or `mobs.advice fertility`. These display help without executing the action.

## Target

Select the owned building in the normal game view BEFORE opening the console. A pinned region does not select buildings. Up to 32 buildings only where the command explicitly allows a batch. fertilization region explicitly uses the owned command-target region instead.

## Steps

fertility reads existing crop fertility and fertilization counters. fertilization toggles permission, with selected/region scope and optional preview.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.fertility wheat
```

## Limits and expected results

Permission does not add soil fertility or bypass game prerequisites. Use soil for actual grid edits. Rye and oats are included in fertility inspection.

## Related commands

- [mobs.soil](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-soil) — `mobs.advice.soil`
- [mobs.undo_fertilization](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-undo_fertilization) — `mobs.advice.undo_fertilization`
- [mobs.plants](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-plants) — `mobs.advice.plants`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
