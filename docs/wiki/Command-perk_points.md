# mobs.perk_points

Guide for **0.16.1-alpha.5**, game **0.8.117**.

Restore a regional card choice by resetting that tier; tier 1 also resets tier 2. One card per tier; settlement gates remain.

```text
mobs.perk_points <1|2|both> [preview]
```

## In-game advice

`mobs.advice.perk_points` or `mobs.advice perk_points`. These display help without executing the action.

## Target

Your owned command-target region. Run mobs.regions, then mobs.region with a listed ID; confirm mobs.status. mobs.region auto clears the pin.

## Steps

perk_points restores a tier choice by resetting that tier. respec_perks clears the specified primary choice(s) and rebuilds effects; default is both. Preview first.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.perk_points 2 preview
mobs.perk_points both
```

## Limits and expected results

Not a numeric currency editor and not development-tree points. Resetting tier 1 ALSO resets tier 2 because of the dependency. Settlement unlock gates remain.

## Related commands

- [mobs.perks](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-perks) — `mobs.advice.perks`
- [mobs.perk_add](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-perk_add) — `mobs.advice.perk_add`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
