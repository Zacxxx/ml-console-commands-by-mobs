# mobs.treasury

Guide for **0.16.0-alpha.3**, game **0.8.117**.

Change treasury; records an economy undo step.

```text
mobs.treasury <set|add> <amount>
```

## In-game advice

`mobs.advice.treasury` or `mobs.advice treasury`. These display help without executing the action.

## Target

Your player lord; no building selection required.

## Steps

Use add for a relative change or set for an exact final value. Read the result and mobs.status afterwards.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.treasury add 1000
mobs.treasury set 5000
```

## Limits and expected results

mobs.undo restores the latest economy edit only while the value and player are unchanged.

## Related commands

- [mobs.undo](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-undo) — `mobs.advice.undo`
- [mobs.status](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-status) — `mobs.advice.status`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
