# mobs.boop

Guide for **0.16.0-alpha.3**, game **0.8.117**.

Toggle the game debug Boop mode, explicitly enable/disable it or read status; uses the native pawn setting and refresh.

```text
mobs.boop [on|off|status]
```

## In-game advice

`mobs.advice.boop` or `mobs.advice boop`. These display help without executing the action.

## Target

Player native debug mode.

## Steps

Read status or explicitly turn the setting on/off. With no argument the current mode toggles.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.boop status
mobs.boop on
mobs.boop off
```

## Limits and expected results

This exposes the native debug Boop setting, not a documented task-assignment API. Use only when you want that native mode; not required for normal commands.

## Related commands

- [mobs.debug_task](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-debug_task) — `mobs.advice.debug_task`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
