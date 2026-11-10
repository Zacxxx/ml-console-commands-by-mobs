# mobs.debug_task

Guide for **0.15.0-alpha.1**, game **0.8.117**.

Diagnostic counterpart for the original developer placeholder: validate the loaded player context and report; no gameplay mutation.

```text
mobs.debug_task
```

## In-game advice

`mobs.advice.debug_task` or `mobs.advice debug_task`. These display help without executing the action.

## Target

Read-only discovery; no settlement required unless loaded game data is being requested.

## Steps

Run without arguments. Read the returned mod/version/context information before reporting a problem.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.debug_task
```

## Limits and expected results

ping proves the command handler responds. is_in_game/debug_task validate context only. They do not test gameplay features or assign worker jobs.

## Related commands

- [mobs.tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-tutorial) — `mobs.advice.tutorial`
- [mobs.advice](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-advice) — `mobs.advice.advice`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
