# mobs.drop

Guide for **0.15.0-alpha.1**, game **0.8.117**.

Deliver to clicked owned storage or supply needed construction materials. No arguments shows status.

```text
mobs.drop [item|id amount]
```

## In-game advice

`mobs.advice.drop` or `mobs.advice drop`. These display help without executing the action.

## Target

Run the command, close the console, then click the intended location in an owned region. It is a one-shot tool with a five-minute expiry. mobs.cancel disarms it. Preview also requires the click, but changes nothing.

## Steps

Choose a deliverable item and amount, close the console and click owned storage, a Supplies pile or a construction site needing that material. No arguments shows pending status.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.drop 17 20
mobs.drop bread 100
mobs.drop
```

## Limits and expected results

Does not create ground piles. Construction deliveries are capped to missing materials including incoming goods. Ineligible clicks leave delivery armed; check the message. No undo.

## Related commands

- [mobs.pile](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-pile) — `mobs.advice.pile`
- [mobs.give](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-give) — `mobs.advice.give`
- [mobs.construction_needs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-construction_needs) — `mobs.advice.construction_needs`
- [mobs.cancel](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-cancel) — `mobs.advice.cancel`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
