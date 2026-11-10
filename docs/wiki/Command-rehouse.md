# mobs.rehouse

Guide for **0.16.1-alpha.5**, game **0.8.117**.

Move a hovered/followed family to one selected completed house in the same owned region; checks capacity, supports preview.

```text
mobs.rehouse selected [preview]
```

## In-game advice

`mobs.advice.rehouse` or `mobs.advice rehouse`. These display help without executing the action.

## Target

Hover the intended living owned unit; follow it before opening the console if hover is lost. rehouse also needs one selected owned completed house.

## Steps

unit inspects; rename_unit accepts a multiword name; undo_unit_name restores a guarded rename. follow tracks the camera; off stops it. rehouse selected moves the hovered/followed family after capacity checks.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.rehouse selected preview
```

## Limits and expected results

Renaming requires an owned home. Rehousing stays in the same region and checks housing capacity; no undo for family moves. Follow can normalize game speed. A region pin does not select a unit.

## Related commands

- [mobs.teleport](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-teleport) — `mobs.advice.teleport`
- [mobs.building](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-building) — `mobs.advice.building`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
