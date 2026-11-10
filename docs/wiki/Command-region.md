# mobs.region

Guide for **0.15.0-alpha.1**, game **0.8.117**.

Choose a region for wealth and regional construction commands; does not move the camera or alter map selection.

```text
mobs.region [id|current|selected|auto]
```

## In-game advice

`mobs.advice.region` or `mobs.advice region`. These display help without executing the action.

## Target

Your owned command-target region. Run mobs.regions, then mobs.region with a listed ID; confirm mobs.status. mobs.region auto clears the pin.

## Steps

Use a real ID from mobs.regions. current pins the camera region; selected pins the selected map region; auto clears a pin. No argument reports the target.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.region current
mobs.region selected
mobs.region auto
mobs.region
```

## Limits and expected results

A pin changes command targeting, not map ownership, camera position or building selection. Numeric IDs must come from your own save.

## Related commands

- [mobs.regions](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-regions) — `mobs.advice.regions`
- [mobs.status](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-status) — `mobs.advice.status`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
