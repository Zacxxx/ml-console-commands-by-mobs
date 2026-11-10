# mobs.complete

Guide for **0.16.0-alpha.3**, game **0.8.117**.

Show contextual completion choices in text; useful if the native dropdown is unavailable.

```text
mobs.complete <partial text...>
```

## In-game advice

`mobs.advice.complete` or `mobs.advice complete`. These display help without executing the action.

## Target

Read-only discovery; no settlement required unless loaded game data is being requested.

## Steps

Supply a partial command or a full command followed by a partial argument. The result is text you can copy; it does not run it.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.complete mobs.sp
mobs.complete pile br
mobs.complete give 17 20 p
```

## Limits and expected results

Broad prefixes show command names. Item IDs/names appear after a complete item-taking command. Suggestions are capped in the printed result.

## Related commands

- [mobs.autocomplete](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-autocomplete) — `mobs.advice.autocomplete`
- [mobs.find](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-find) — `mobs.advice.find`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
