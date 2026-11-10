# mobs.undo_resources

Guide for **0.16.0-alpha.3**, game **0.8.117**.

Undo the latest resource refill if no affected deposit has changed; holds five refills and clears on reload.

```text
mobs.undo_resources
```

## In-game advice

`mobs.advice.undo_resources` or `mobs.advice undo_resources`. These display help without executing the action.

## Target

Latest unchanged resource refill/empty batch in this session.

## Steps

Run after a refill/empty batch to restore its previous clump amounts.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.refill_resources berries
mobs.undo_resources
```

## Limits and expected results

Up to five batches retained. If harvesting or another edit changed any target, undo refuses to overwrite it. It cannot undo spawning/removal.

## Related commands

- [mobs.refill_resources](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-refill_resources) — `mobs.advice.refill_resources`
- [mobs.empty_resources](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-empty_resources) — `mobs.advice.empty_resources`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
