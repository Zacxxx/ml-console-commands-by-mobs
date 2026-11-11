# mobs.is_in_game

Guide for **0.16.1-alpha.6**, game **0.8.117**.

Check whether the local settlement pawn required by gameplay commands is available.

```text
mobs.is_in_game
```

## In-game advice

`mobs.advice.is_in_game` or `mobs.advice is_in_game`. These display help without executing the action.

## Target

Read-only discovery; no settlement required unless loaded game data is being requested.

## Steps

Run without arguments. Read the returned mod/version/context information before reporting a problem.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.is_in_game
```

## Limits and expected results

ping proves the command handler responds. is_in_game/debug_task validate context only. They do not test gameplay features or assign worker jobs.

## Related commands

- [mobs.tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-tutorial) — `mobs.advice.tutorial`
- [mobs.advice](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-advice) — `mobs.advice.advice`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
