# mobs.grow_trees

Guide for **0.16.0-alpha.3**, game **0.8.117**.

Grow registered trees and untracked native young-tree stages to maturity in batches; excludes decorative bushes. Supports preview.

```text
mobs.grow_trees [preview]
```

## In-game advice

`mobs.advice.grow_trees` or `mobs.advice grow_trees`. These display help without executing the action.

## Target

Your owned command-target region. Run mobs.regions, then mobs.region with a listed ID; confirm mobs.status. mobs.region auto clears the pin.

## Steps

Preview the eligible world-tree records, run normally, and wait for the completion notification. Work runs in bounded batches.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.grow_trees preview
mobs.grow_trees
```

## Limits and expected results

Grows native young and intermediate world-tree stages to maturity, including previously untracked stages; decorative bushes are excluded. Blocked transitions are reported rather than counted as successful. Does not plant an entire new forest. No undo.

## Related commands

- [mobs.grow_saplings](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-grow_saplings) — `mobs.advice.grow_saplings`
- [mobs.grow_stage](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-grow_stage) — `mobs.advice.grow_stage`
- [mobs.replant_trees](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-replant_trees) — `mobs.advice.replant_trees`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
