# mobs.undo_soil

Guide for **0.16.1-alpha.6**, game **0.8.117**.

Undo the latest soil batch only if all edited values and ownership are unchanged; supports preview.

```text
mobs.undo_soil [preview]
```

## In-game advice

`mobs.advice.undo_soil` or `mobs.advice undo_soil`. These display help without executing the action.

## Target

Latest unchanged soil batch in the same loaded settlement.

## Steps

Preview the restoration, then run without preview.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.undo_soil preview
mobs.undo_soil
```

## Limits and expected results

Refuses if edited values or ownership changed, rather than overwriting newer simulation changes. Only the latest native soil batch is retained.

## Related commands

- [mobs.soil](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-soil) — `mobs.advice.soil`
- [mobs.fertility](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-fertility) — `mobs.advice.fertility`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
