# mobs.approval

Guide for **0.15.0-alpha.1**, game **0.8.117**.

Set/add current approval (0..100); game may recalculate it. Records an undo step.

```text
mobs.approval <set|add> <amount>
```

## In-game advice

`mobs.advice.approval` or `mobs.advice approval`. These display help without executing the action.

## Target

Your owned command-target region. Run mobs.regions, then mobs.region with a listed ID; confirm mobs.status. mobs.region auto clears the pin.

## Steps

Use add for a relative change or set for an exact final value. Read the result and mobs.status afterwards.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.approval add 5
mobs.approval set 80
```

## Limits and expected results

Approval must end between 0 and 100 and the game may recalculate it. mobs.undo restores the latest economy edit only while the value and player are unchanged.

## Related commands

- [mobs.undo](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-undo) — `mobs.advice.undo`
- [mobs.status](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-status) — `mobs.advice.status`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
