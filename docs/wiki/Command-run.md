# mobs.run

Guide for **0.16.0-alpha.3**, game **0.8.117**.

Run up to 100 Mobs commands from a local Commands/*.txt file; no scripts, traversal or recursion; preview lists commands; stop on first error.

```text
mobs.run <filename.txt> [preview]
```

## In-game advice

`mobs.advice.run` or `mobs.advice run`. These display help without executing the action.

## Target

Local text files inside this mod Commands folder.

## Steps

Write one exact Mobs command per line in a .txt file. Preview displays the commands; remove preview to run them in order.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.run example.txt preview
```

## Limits and expected results

Only up to 100 lines/64 KiB. No scripts, path traversal or recursive run. Stops at first error; prior successful mutations remain. Do not put several click placements in one file: each arms a pending tool rather than completing a click.

## Related commands

- [mobs.recent](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-recent) — `mobs.advice.recent`
- [mobs.cancel](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-cancel) — `mobs.advice.cancel`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
