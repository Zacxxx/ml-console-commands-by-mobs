# mobs.remove_deposit

Guide for **0.16.0-alpha.3**, game **0.8.117**.

Click near owned underground reserves to remove their decal and colocated empty legacy markers; real surface clumps remain (mobs.resource remove); no undo.

```text
mobs.remove_deposit [iron|clay|salt|all] [preview]
```

## In-game advice

`mobs.advice.remove_deposit` or `mobs.advice remove_deposit`. These display help without executing the action.

## Target

Run the command, close the console, then click the intended location in an owned region. It is a one-shot tool with a five-minute expiry. mobs.cancel disarms it. Preview also requires the click, but changes nothing.

## Steps

Choose iron, clay, salt or all, close the console and click near the underground reserve. Preview first.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.remove_deposit iron preview
mobs.remove_deposit iron
mobs.resource remove iron preview
```

## Limits and expected results

Removes underground reserves/decal and colocated empty legacy markers. Real surface clumps remain deliberately: remove them separately using resource remove. all means nearest matching kind, not every deposit on the map. No undo.

## Related commands

- [mobs.resource](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-resource) — `mobs.advice.resource`
- [mobs.deposit](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-deposit) — `mobs.advice.deposit`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
