# mobs.inventory

Guide for **0.16.1-alpha.5**, game **0.8.117**.

Show goods stored directly in one selected owned building; optional name or ID filter.

```text
mobs.inventory [search]
```

## In-game advice

`mobs.advice.inventory` or `mobs.advice inventory`. These display help without executing the action.

## Target

Select the owned building in the normal game view BEFORE opening the console. A pinned region does not select buildings. Up to 32 buildings only where the command explicitly allows a batch.

## Steps

Select exactly ONE owned building, reopen the console, then inspect it. inventory optionally filters goods by name or ID.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.inventory
mobs.inventory 17
```

## Limits and expected results

Building inventory is local storage, not the total regional stock. An inventory_add result may not appear in the top resource bar immediately.

## Related commands

- [mobs.stock](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-stock) — `mobs.advice.stock`
- [mobs.give](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-give) — `mobs.advice.give`
- [mobs.construction_needs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-construction_needs) — `mobs.advice.construction_needs`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
