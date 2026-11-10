# mobs.remove_selected_piles

Guide for **0.16.1-alpha.5**, game **0.8.117**.

Remove selected owned Supplies piles INCLUDING CONTENTS, even unfinished/bugged ones; supports preview. Ignores region pin; no undo.

```text
mobs.remove_selected_piles [preview]
```

## In-game advice

`mobs.advice.remove_selected_piles` or `mobs.advice remove_selected_piles`. These display help without executing the action.

## Target

Select the owned building in the normal game view BEFORE opening the console. A pinned region does not select buildings. Up to 32 buildings only where the command explicitly allows a batch.

## Steps

Select the bugged Supplies pile(s), preview, then remove preview to delete those selected piles.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.remove_selected_piles preview
mobs.remove_selected_piles
```

## Limits and expected results

Deletes CONTENTS as well as the pile, including unfinished/bugged piles. It ignores the region pin and rejects foreign targets. There is no undo.

## Related commands

- [mobs.clear_empty_piles](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-clear_empty_piles) — `mobs.advice.clear_empty_piles`
- [mobs.pile](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-pile) — `mobs.advice.pile`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
