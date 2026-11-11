# mobs.undo_fertilization

Guide for **0.16.1-alpha.6**, game **0.8.117**.

Undo the latest fertilization permission batch when fields are unchanged; holds five batches until reload.

```text
mobs.undo_fertilization
```

## In-game advice

`mobs.advice.undo_fertilization` or `mobs.advice undo_fertilization`. These display help without executing the action.

## Target

Latest unchanged fertilization-permission batch.

## Steps

Run after a permission toggle to restore previous permissions.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.fertilization on selected
mobs.undo_fertilization
```

## Limits and expected results

Five batches retained until reload. Changed ownership or permission values cause refusal. This does not restore soil fertility.

## Related commands

- [mobs.fertilization](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-fertilization) — `mobs.advice.fertilization`
- [mobs.soil](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-soil) — `mobs.advice.soil`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
