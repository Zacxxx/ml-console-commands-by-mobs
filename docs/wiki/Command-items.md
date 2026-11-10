# mobs.items

Guide for **0.16.0-alpha.3**, game **0.8.117**.

List supply item IDs and names from the loaded game's item table; optionally filter.

```text
mobs.items [search]
```

## In-game advice

`mobs.advice.items` or `mobs.advice items`. These display help without executing the action.

## Target

Loaded game item table.

## Steps

Search by display name or numeric ID. Copy a returned ID into pile, give or inventory commands. Names with spaces can be normalized, but an ID avoids ambiguity.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.items bread
mobs.items 17
mobs.items
```

## Limits and expected results

The wiki lists the full EItemType enum, including recipes/internal values. mobs.items lists the deliverable subset. Enum labels are not always localized command-name aliases. Livestock use mobs.animal.

## Related commands

- [mobs.pile](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-pile) — `mobs.advice.pile`
- [mobs.give](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-give) — `mobs.advice.give`
- [mobs.inventory](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-inventory) — `mobs.advice.inventory`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
