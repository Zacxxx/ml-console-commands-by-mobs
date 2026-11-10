# mobs.respec_perks

Guide for **0.16.1-alpha.5**, game **0.8.117**.

Reset regional perk cards and rebuild active effects. Default both tiers; resetting Origins also resets Rural Foundations.

```text
mobs.respec_perks [1|2|all] [preview]
```

## In-game advice

`mobs.advice.respec_perks` or `mobs.advice respec_perks`. These display help without executing the action.

## Target

Your owned command-target region. Run mobs.regions, then mobs.region with a listed ID; confirm mobs.status. mobs.region auto clears the pin.

## Steps

perk_points restores a tier choice by resetting that tier. respec_perks clears the specified primary choice(s) and rebuilds effects; default is both. Preview first.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.respec_perks all preview
```

## Limits and expected results

Not a numeric currency editor and not development-tree points. Resetting tier 1 ALSO resets tier 2 because of the dependency. Settlement unlock gates remain.

## Related commands

- [mobs.perks](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-perks) — `mobs.advice.perks`
- [mobs.perk_add](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-perk_add) — `mobs.advice.perk_add`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
