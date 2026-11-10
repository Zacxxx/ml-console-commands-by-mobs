# mobs.finish_constructions

Guide for **0.16.0-alpha.3**, game **0.8.117**.

Finish construction work in the selected/current owned region and let the game finalize sites during simulation; preview lists the count.

```text
mobs.finish_constructions [preview]
```

## In-game advice

`mobs.advice.finish_constructions` or `mobs.advice finish_constructions`. These display help without executing the action.

## Target

Your owned command-target region. Run mobs.regions, then mobs.region with a listed ID; confirm mobs.status. mobs.region auto clears the pin.

## Steps

Preview unfinished sites, run without preview, then resume simulation. Watch sites finalize; workers may still need to reach them.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.finish_constructions preview
mobs.finish_constructions
mobs.speed 1
```

## Limits and expected results

Prepares native construction work and supplies missing materials. It does not forcibly replace actors or guarantee instant simulation finalization. No undo; inspect failures in the result.

## Related commands

- [mobs.construction_needs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-construction_needs) — `mobs.advice.construction_needs`
- [mobs.supply_construction](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-supply_construction) — `mobs.advice.supply_construction`
- [mobs.instant_build](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-instant_build) — `mobs.advice.instant_build`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
