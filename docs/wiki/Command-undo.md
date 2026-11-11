# mobs.undo

Guide for **0.16.1-alpha.6**, game **0.8.117**.

Undo the last economy edit unless its value has changed since.

```text
mobs.undo
```

## In-game advice

`mobs.advice.undo` or `mobs.advice undo`. These display help without executing the action.

## Target

Latest economy edit in this mod session.

## Steps

Run after treasury, influence, wealth or approval edits to restore the previous value.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.treasury add 100
mobs.undo
```

## Limits and expected results

This is not universal undo. It refuses to overwrite newer simulation changes and does not restore inventory, demolished buildings or spawned resources.

## Related commands

- [mobs.status](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-status) — `mobs.advice.status`
- [mobs.undo_resources](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-undo_resources) — `mobs.advice.undo_resources`
- [mobs.undo_soil](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-undo_soil) — `mobs.advice.undo_soil`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
