# mobs.deposit

Guide for **0.15.0-alpha.1**, game **0.8.117**.

Click near an existing owned underground iron/clay/salt deposit to add reserves or change its rich flag; preview and guarded undo; does not spawn deposits.

```text
mobs.deposit <add|rich|normal> <iron|clay|salt> [amount for add] [preview]
```

## In-game advice

`mobs.advice.deposit` or `mobs.advice deposit`. These display help without executing the action.

## Target

Run the command, close the console, then click the intended location in an owned region. It is a one-shot tool with a five-minute expiry. mobs.cancel disarms it. Preview also requires the click, but changes nothing.

## Steps

Use add to increase an EXISTING underground reserve, or rich/normal to change its flag. Click within 2500 of the reserve.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.deposit add iron 1000 preview
mobs.deposit add iron 1000
mobs.deposit rich iron
```

## Limits and expected results

Cannot edit a surface-only resource group. A visible icon alone does not prove an underground reserve exists. Use resource add for surface ore; spawn_deposit creates both layers in new versions.

## Related commands

- [mobs.undo_deposit](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-undo_deposit) — `mobs.advice.undo_deposit`
- [mobs.resource](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-resource) — `mobs.advice.resource`
- [mobs.spawn_deposit](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-spawn_deposit) — `mobs.advice.spawn_deposit`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
