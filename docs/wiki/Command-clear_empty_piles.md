# mobs.clear_empty_piles

Guide for **0.16.0-alpha.3**, game **0.8.117**.

Remove empty owned Supplies piles in the target region; supports preview. Non-empty/unreadable piles are kept.

```text
mobs.clear_empty_piles [preview]
```

## In-game advice

`mobs.advice.clear_empty_piles` or `mobs.advice clear_empty_piles`. These display help without executing the action.

## Target

Your owned command-target region. Run mobs.regions, then mobs.region with a listed ID; confirm mobs.status. mobs.region auto clears the pin.

## Steps

Preview the count, then run without preview to remove only confirmed-empty owned Supplies piles in the target region.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.clear_empty_piles preview
mobs.clear_empty_piles
```

## Limits and expected results

Non-empty and unreadable piles are retained. Other regions and buildings are untouched. Removal has no undo.

## Related commands

- [mobs.remove_selected_piles](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-remove_selected_piles) — `mobs.advice.remove_selected_piles`
- [mobs.pile](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-pile) — `mobs.advice.pile`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
