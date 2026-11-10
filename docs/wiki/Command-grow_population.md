# mobs.grow_population

Guide for **0.15.0-alpha.1**, game **0.8.117**.

Request native population growth in the target settlement, up to ten attempts; reports actual resident counts.

```text
mobs.grow_population [attempts]
```

## In-game advice

`mobs.advice.grow_population` or `mobs.advice grow_population`. These display help without executing the action.

## Target

Your owned command-target region. Run mobs.regions, then mobs.region with a listed ID; confirm mobs.status. mobs.region auto clears the pin.

## Steps

Use 1..10 native growth ATTEMPTS and read the before/after human resident counts. Leave simulation time for arrivals and check housing/approval.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.grow_population 1
mobs.grow_population 10
```

## Limits and expected results

10 does not mean ten instant people or families. Native housing, migration, settlement and timing conditions apply. Zero change is reported honestly; repeating cannot guarantee arrival. No undo.

## Related commands

- [mobs.approval](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-approval) — `mobs.advice.approval`
- [mobs.rehouse](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-rehouse) — `mobs.advice.rehouse`
- [mobs.skip_day](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-skip_day) — `mobs.advice.skip_day`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
