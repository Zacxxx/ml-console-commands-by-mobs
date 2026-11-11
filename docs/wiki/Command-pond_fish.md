# mobs.pond_fish

Guide for **0.16.1-alpha.6**, game **0.8.117**.

Add one fish shoal to the nearest completed owned Fishing Pond; rejects ponds already containing fish. Use refill_resources for existing shoals.

```text
mobs.pond_fish [amount] [rich] [preview]
```

## In-game advice

`mobs.advice.pond_fish` or `mobs.advice pond_fish`. These display help without executing the action.

## Target

Run the command, close the console, then click the intended location in an owned region. It is a one-shot tool with a five-minute expiry. mobs.cancel disarms it. Preview also requires the click, but changes nothing.

## Steps

Run the command, close the console and click near a completed owned Fishing Pond (within 1500 game units). New mobs.pond place ponds are already complete. Fish use a native pond placement transform rather than the building origin.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.pond_fish 500 preview
mobs.pond_fish 500
mobs.refill_resources fish preview
```

## Limits and expected results

Adds one shoal to the nearest completed owned Fishing Pond. Existing shoals are rejected to prevent duplicates; refill existing fish instead. Worker harvesting and save/load need live confirmation. No undo. 0.16.1 checks the native constructed state again at apply and uses the pond's generated fish anchor; missing anchors produce an explicit refusal.

## Related commands

- [mobs.pond](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-pond) — `mobs.advice.pond`
- [mobs.resources](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-resources) — `mobs.advice.resources`
- [mobs.refill_resources](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-refill_resources) — `mobs.advice.refill_resources`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
