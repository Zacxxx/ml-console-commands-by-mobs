# mobs.pile

Guide for **0.16.1-alpha.5**, game **0.8.117**.

Experimental: enter native Supplies placement and fill the newly placed pile; owned region only.

```text
mobs.pile <item|id> <amount>
```

## In-game advice

`mobs.advice.pile` or `mobs.advice pile`. These display help without executing the action.

## Target

Run the command, close the console, then click the intended location in an owned region. It is a one-shot tool with a five-minute expiry. mobs.cancel disarms it. Preview also requires the click, but changes nothing.

## Steps

Find an item with mobs.items. Run pile with its name or ID and an amount. Close the console and place the native Supplies preview. Read the delivery result.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.pile 17 100
mobs.pile bread 100
```

## Limits and expected results

Creates a NEW pile. Inventory changes only after placement succeeds. Amount is 1..10000. No preview argument or undo. Use drop to fill an existing target.

## Related commands

- [mobs.drop](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-drop) — `mobs.advice.drop`
- [mobs.clear_empty_piles](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-clear_empty_piles) — `mobs.advice.clear_empty_piles`
- [mobs.remove_selected_piles](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-remove_selected_piles) — `mobs.advice.remove_selected_piles`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
