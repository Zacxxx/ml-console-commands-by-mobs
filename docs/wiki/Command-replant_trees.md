# mobs.replant_trees

Guide for **0.16.0-alpha.3**, game **0.8.117**.

Click cleared ground to replant one oak sapling in the target owned region; native collision checks; supports preview.

```text
mobs.replant_trees [preview]
```

## In-game advice

`mobs.advice.replant_trees` or `mobs.advice replant_trees`. These display help without executing the action.

## Target

Run the command, close the console, then click the intended location in an owned region. It is a one-shot tool with a five-minute expiry. mobs.cancel disarms it. Preview also requires the click, but changes nothing. The command-target region must also match the intended owned ground.

## Steps

replant_trees places ONE oak sapling on cleared ground. regrow_trees combines that single replant click with maturation of eligible native trees in the target region.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.replant_trees preview
mobs.replant_trees
```

## Limits and expected results

This is one sapling per click, not a forest brush. Native collision checks still apply. Existing saplings and world trees can instead be matured without planting by grow_saplings/grow_trees. No undo.

## Related commands

- [mobs.grow_trees](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-grow_trees) — `mobs.advice.grow_trees`
- [mobs.grow_saplings](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-grow_saplings) — `mobs.advice.grow_saplings`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
