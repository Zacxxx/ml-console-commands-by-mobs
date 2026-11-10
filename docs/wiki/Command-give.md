# mobs.give

Guide for **0.16.1-alpha.5**, game **0.8.117**.

Deliver up to this amount to EACH selected owned storage building or construction site (max 32); supports preview.

```text
mobs.give <item|id> <amount> [preview]
```

## In-game advice

`mobs.advice.give` or `mobs.advice give`. These display help without executing the action.

## Target

Select the owned building in the normal game view BEFORE opening the console. A pinned region does not select buildings. Up to 32 buildings only where the command explicitly allows a batch.

## Steps

Run with an item ID/name and per-building amount. Preview the exact selection first; remove preview to apply. Every target is checked before the first write.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.give 17 20 preview
mobs.give 17 20
```

## Limits and expected results

Amount is per selected building, not a shared total. give accepts storage/piles/sites. inventory_add also accepts production/housing and bypasses completed-building storage caps. Construction receives only needed materials. No undo.

## Related commands

- [mobs.drop](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-drop) — `mobs.advice.drop`
- [mobs.items](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-items) — `mobs.advice.items`
- [mobs.inventory](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-inventory) — `mobs.advice.inventory`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
