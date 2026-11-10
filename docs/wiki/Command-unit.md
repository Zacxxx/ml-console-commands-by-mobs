# mobs.unit

Guide for **0.15.0-alpha.1**, game **0.8.117**.

Inspect the hovered unit, or currently followed unit when none is hovered; changes nothing.

```text
mobs.unit
```

## In-game advice

`mobs.advice.unit` or `mobs.advice unit`. These display help without executing the action.

## Target

Hover the intended living owned unit; follow it before opening the console if hover is lost. rehouse also needs one selected owned completed house.

## Steps

unit inspects; rename_unit accepts a multiword name; undo_unit_name restores a guarded rename. follow tracks the camera; off stops it. rehouse selected moves the hovered/followed family after capacity checks.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.unit
```

## Limits and expected results

Renaming requires an owned home. Rehousing stays in the same region and checks housing capacity; no undo for family moves. Follow can normalize game speed. A region pin does not select a unit.

## Related commands

- [mobs.teleport](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-teleport) — `mobs.advice.teleport`
- [mobs.building](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-building) — `mobs.advice.building`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
