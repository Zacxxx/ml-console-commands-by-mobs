# mobs.refresh_resource_icons

Guide for **0.16.1-alpha.6**, game **0.8.117**.

Refresh normal-map icons and paper-map hover data, and hide leaked owned mineral terrain artwork while retaining reserves and surface stones. No click; quantities unchanged; preview available.

```text
mobs.refresh_resource_icons [preview]
```

## In-game advice

`mobs.advice.refresh_resource_icons` or `mobs.advice refresh_resource_icons`. These display help without executing the action.

## Target

Current game HUD; no click or building selection.

## Steps

Run preview to compare node counts and count owned mineral render actors that would be hidden, then run normally. This synchronizes HUD icons/hover data and suppresses leaked underground paper-map projections and extra mineral meshes. No click required. An automatic visual repair also runs shortly after loading a settlement.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.refresh_resource_icons preview
mobs.refresh_resource_icons
```

## Limits and expected results

Keeps the separate normal-map icons, paper-map icons and tooltips. Only rendering of owned iron/clay/salt reserve/data actors is hidden: amounts, richness, capacity, node membership and collision/mining data are unchanged. Surface stones and foreign deposits are untouched. Preview changes nothing. It does not repair worker reachability. The manual repair and automatic reload pass cover deposits made by older Mobs candidates.

## Related commands

- [mobs.spawn_deposit](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-spawn_deposit) — `mobs.advice.spawn_deposit`
- [mobs.resource](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-resource) — `mobs.advice.resource`
- [mobs.remove_deposit](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-remove_deposit) — `mobs.advice.remove_deposit`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
