# mobs.instant_build

Guide for **0.15.0-alpha.1**, game **0.8.117**.

Use the game native instaBuild setting for newly placed buildings, including materials. Applies globally this session until off; existing sites use finish_constructions.

```text
mobs.instant_build <on|off|status> [preview]
```

## In-game advice

`mobs.advice.instant_build` or `mobs.advice instant_build`. These display help without executing the action.

## Target

Global native setting for this session, affecting newly placed buildings.

## Steps

Read status, switch on, place the intended new building, then switch off when finished.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.instant_build status
mobs.instant_build on preview
mobs.instant_build on
mobs.instant_build off
```

## Limits and expected results

Applies globally until disabled, not just in a pinned region. Existing unfinished sites use finish_constructions instead. A restart resets session-only behavior.

## Related commands

- [mobs.finish_constructions](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-finish_constructions) — `mobs.advice.finish_constructions`
- [mobs.construction](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-construction) — `mobs.advice.construction`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
