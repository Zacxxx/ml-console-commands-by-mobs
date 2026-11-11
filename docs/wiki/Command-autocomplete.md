# mobs.autocomplete

Guide for **0.16.1-alpha.6**, game **0.8.117**.

Refresh game-data suggestions, inspect status, or enable/disable only our native console suggestions.

```text
mobs.autocomplete [status|refresh|on|off]
```

## In-game advice

`mobs.advice.autocomplete` or `mobs.advice autocomplete`. These display help without executing the action.

## Target

Read-only discovery; no settlement required unless loaded game data is being requested.

## Steps

Load a settlement, open the console and refresh. Type mobs. and use Tab. Fully enter an item-taking command to see item variants. Enter runs the typed command.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.autocomplete refresh
mobs.autocomplete off
mobs.autocomplete status
```

## Limits and expected results

Opening Development once loads card names for completion. Native dropdown support targets 0.8.117; mobs.complete remains available if native refresh fails. Off lasts until the mod reloads.

## Related commands

- [mobs.complete](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-complete) — `mobs.advice.complete`
- [mobs.find](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-find) — `mobs.advice.find`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
