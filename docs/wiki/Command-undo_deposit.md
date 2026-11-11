# mobs.undo_deposit

Guide for **0.16.1-alpha.6**, game **0.8.117**.

Undo the latest unchanged underground deposit edit; holds ten edits until mod/player reload.

```text
mobs.undo_deposit
```

## In-game advice

`mobs.advice.undo_deposit` or `mobs.advice undo_deposit`. These display help without executing the action.

## Target

Latest unchanged underground reserve edit in this session.

## Steps

Undo an add/rich/normal edit after confirming no extraction or later edit changed the target.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.deposit add iron 100
mobs.undo_deposit
```

## Limits and expected results

Ten edits retained until player/mod reload. Does not undo creation/removal or rebuild a deleted deposit.

## Related commands

- [mobs.deposit](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-deposit) — `mobs.advice.deposit`
- [mobs.remove_deposit](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-remove_deposit) — `mobs.advice.remove_deposit`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
