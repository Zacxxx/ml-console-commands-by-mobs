# mobs.spawn_deposit

Guide for **0.16.1-alpha.5**, game **0.8.117**.

Preview native iron/clay/salt ground material, mining-radius ring and exact centre; left-click READY terrain to create one surface clump plus equal underground reserves. Blocked clicks keep preview; right-click cancels. Optional read-only preview; maximum one million per layer; no undo.

```text
mobs.spawn_deposit <iron|clay|salt> <amount> [rich] [preview]
```

## In-game advice

`mobs.advice.spawn_deposit` or `mobs.advice spawn_deposit`. These display help without executing the action.

## Target

Run the command, close the console and move the cursor over owned land. A native ground-material preview, centre crosshair and mining-radius ring follow the cursor. Read green READY / red BLOCKED, then left-click the centre you want. Right-click or mobs.cancel cancels; five-minute expiry. Add preview for a read-only tool that stays active across clicks.

## Steps

Choose iron, clay or salt, an amount and optional rich. The tool uses the game native mineral Blueprint classes and underground-deposit factory; it keeps your click X/Y and snaps only height to terrain. The ring uses the native mining radius: 20m normal or 25m rich on the supported build. A valid click creates one finite surface clump, an equal underground reserve, registered map node and hidden data-only reserve actor. Blocked clicks keep the preview active so you can move and try again. The click is rechecked immediately before allocation. Preview-only clicks report the plan and never allocate a reserve, clump or node.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.spawn_deposit iron 1000 preview
mobs.spawn_deposit iron 1000
mobs.spawn_deposit clay 2000 rich preview
mobs.spawn_deposit clay 2000 rich
mobs.spawn_deposit salt 1500
mobs.cancel
```

## Limits and expected results

The screenshot error Mineral resource template or native size unavailable came from reading generic ResourceTemplate fields that are NULL for minerals on 0.8.117; the native engine owns separate Iron/Clay/Salt classes. This release uses those classes and native scale instead. 1000 means 1000 surface units plus 1000 underground units. Rich reserves follow native deep-mining rules and may display as endless. The ring indicates mining range, not a strict empty clearance circle. The centre must be on valid owned terrain and outside native blockers; centres within 1m of an existing underground deposit are refused to prevent accidental duplicates. This does not guarantee mine access on cliffs or awkward terrain. No random map-generator relocation or new custom game assets. Placement has no undo; partial native failure stops the tool. Remove underground and surface layers separately when cleaning up. User testing confirmed placement and mineral-imprint cleanup. Extended mining and save/reload checks remain open; offline checks are not gameplay proof. The placed iron/clay/salt deposit has no terrain artwork or extra ore model, matching natural deposits; only its map icon/tooltip remain. The ground material, radius and crosshair are temporary placement guides. Earlier Mobs paper-map imprints are hidden automatically after load or by refresh_resource_icons, without deleting reserves. Surface stones remain visible.

## Related commands

- [mobs.remove_deposit](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-remove_deposit) — `mobs.advice.remove_deposit`
- [mobs.resource](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-resource) — `mobs.advice.resource`
- [mobs.deposit](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-deposit) — `mobs.advice.deposit`
- [mobs.cancel](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-cancel) — `mobs.advice.cancel`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
