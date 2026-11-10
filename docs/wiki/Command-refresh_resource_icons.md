# mobs.refresh_resource_icons

Guide for **0.15.0-alpha.1**, game **0.8.117**.

Refresh the game HUD resource-node list for normal-map icons and paper-map hover details. No click required; resource quantities unchanged; preview available.

```text
mobs.refresh_resource_icons [preview]
```

## In-game advice

`mobs.advice.refresh_resource_icons` or `mobs.advice refresh_resource_icons`. These display help without executing the action.

## Target

Current game HUD; no click or building selection.

## Steps

Run preview to compare authoritative/displayed node counts, then run normally. Let the HUD tick and reopen the map if needed.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.refresh_resource_icons preview
mobs.refresh_resource_icons
```

## Limits and expected results

Repairs the separate normal-map icon/paper-map hover list after spawned/removed resources. It does not create clumps, alter amounts, resolve worker reachability or repair old underground orientation.

## Related commands

- [mobs.resource](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-resource) — `mobs.advice.resource`
- [mobs.spawn_resource](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-spawn_resource) — `mobs.advice.spawn_resource`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
