# mobs.resource

Guide for **0.16.1-alpha.5**, game **0.8.117**.

Click near an owned resource to add, change richness, refresh ground height/size/visibility without changing goods, or remove a group/clump. Refresh excludes fish/eel and attached clumps. Maximum distance 2500; no undo.

```text
mobs.resource <add|rich|normal|refresh|remove|remove_clump> [kind|all] [amount for add] [preview]
```

## In-game advice

`mobs.advice.resource` or `mobs.advice resource`. These display help without executing the action.

## Target

Run the command, close the console, then click the intended location in an owned region. It is a one-shot tool with a five-minute expiry. mobs.cancel disarms it. Preview also requires the click, but changes nothing.

## Steps

Choose an action, kind and an amount only for add. Click near the actual clump/node within 2500 game units. Preview each placement/removal/edit before applying.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.resource add berries 100 preview
mobs.resource rich iron
mobs.resource refresh berries preview
mobs.resource remove eel preview
mobs.resource remove eel
```

## Limits and expected results

remove deletes a whole surface group; remove_clump only one clump. Exact kind is required: fish and eel differ. refresh repairs land clump size/height/visibility, not amounts. Real underground reserves use remove_deposit; empty clumpless non-wildlife nodes are removable here. No undo.

## Related commands

- [mobs.resources](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-resources) — `mobs.advice.resources`
- [mobs.remove_deposit](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-remove_deposit) — `mobs.advice.remove_deposit`
- [mobs.refresh_resource_icons](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-refresh_resource_icons) — `mobs.advice.refresh_resource_icons`
- [mobs.repair_fishing](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-repair_fishing) — `mobs.advice.repair_fishing`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
