# mobs.teleport

Guide for **0.16.1-alpha.6**, game **0.8.117**.

Click to relocate an owned unit or selected squads, preserving formation offsets; preview supported; existing orders remain active.

```text
mobs.teleport <unit|squads> [preview]
```

## In-game advice

`mobs.advice.teleport` or `mobs.advice teleport`. These display help without executing the action.

## Target

Run the command, close the console, then click the intended location in an owned region. It is a one-shot tool with a five-minute expiry. mobs.cancel disarms it. Preview also requires the click, but changes nothing. unit uses your hovered/followed owned unit; squads uses selected owned squads.

## Steps

Select/follow the targets first, run unit or squads with preview, then close the console and click the destination.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.teleport unit preview
mobs.teleport squads preview
```

## Limits and expected results

Formation offsets are preserved for squads. Existing orders remain active, so units may move again immediately. No undo.

## Related commands

- [mobs.unit](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-unit) — `mobs.advice.unit`
- [mobs.follow](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-follow) — `mobs.advice.follow`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
