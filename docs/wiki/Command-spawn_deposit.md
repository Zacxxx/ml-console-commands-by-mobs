# mobs.spawn_deposit

Guide for **0.16.0-alpha.3**, game **0.8.117**.

Click to create iron/clay/salt with the requested amount in one surface clump PLUS the same underground reserves; ground-facing decal and map node; maximum one million per layer; no undo.

```text
mobs.spawn_deposit <iron|clay|salt> <amount> [rich] [preview]
```

## In-game advice

`mobs.advice.spawn_deposit` or `mobs.advice spawn_deposit`. These display help without executing the action.

## Target

Run the command, close the console, then click the intended location in an owned region. It is a one-shot tool with a five-minute expiry. mobs.cancel disarms it. Preview also requires the click, but changes nothing.

## Steps

Choose iron, clay or salt, a quantity, and optional rich. Preview, then place clear owned ground. New versions create a finite surface clump AND a separate underground reserve with that quantity.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.spawn_deposit iron 1000 rich preview
mobs.spawn_deposit iron 1000 rich
```

## Limits and expected results

1000 means 1000 surface units plus 1000 underground units. Rich reserves follow the native deep-mining rules and can be displayed as endless; the surface clump supplies the finite tooltip amount. Old empty markers need removal/recreation. No undo.

## Related commands

- [mobs.remove_deposit](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-remove_deposit) — `mobs.advice.remove_deposit`
- [mobs.resource](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-resource) — `mobs.advice.resource`
- [mobs.deposit](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-deposit) — `mobs.advice.deposit`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
