# mobs.weather

Guide for **0.16.1-alpha.6**, game **0.8.117**.

Start/end rain or drought; optional immediate transition and damaging rain. Supports preview.

```text
mobs.weather <rain|drought|clear|end_rain|end_drought> [instant] [damaging] [preview]
```

## In-game advice

`mobs.advice.weather` or `mobs.advice weather`. These display help without executing the action.

## Target

Whole map weather simulation.

## Steps

Choose rain, drought, clear, end_rain or end_drought. instant requests immediate transition; damaging applies only to rain. Preview first.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.weather rain preview
mobs.weather clear instant
mobs.weather drought instant preview
```

## Limits and expected results

The simulation can later choose new weather. clear ends rain and drought; end_rain/end_drought affect the chosen condition. No undo.

## Related commands

- [mobs.speed](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-speed) — `mobs.advice.speed`
- [mobs.skip_day](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-skip_day) — `mobs.advice.skip_day`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
