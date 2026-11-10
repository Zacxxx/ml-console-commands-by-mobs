# mobs.pond

Guide for **0.16.1-alpha.5**, game **0.8.117**.

Preview the pond footprint and clearance with a moving READY/BLOCKED label, then click to create a completed empty pond; right-click cancels. Stock with pond_fish. Relaxed by default: actual outline, 10m height spread and neighbouring owned land; strict restores the old rectangle/2m rule. Read-only preview and owned pond removal supported.

```text
mobs.pond <place|remove> [strict] [preview]
```

## In-game advice

`mobs.advice.pond` or `mobs.advice pond`. These display help without executing the action.

## Target

place opens a moving pond-footprint preview on owned terrain. Close the console, move the cursor and read green READY or red BLOCKED. Left-click confirms only a valid site; right-click or mobs.cancel cancels. The tool expires after five minutes. Relaxed placement is the default; add strict only to restore the old restrictive rules. remove uses a separate one-shot click.

## Steps

Run mobs.pond place for relaxed placement: check the actual pond polygon, without a surrounding clearance rectangle or extra margin. Allow up to 10 metres of height variation across the footprint and crossing into neighbouring regions owned by the same lord. Valid terrain and native navigation/building blocker checks still apply. Left-click a READY site to create one completed empty pond, then stock it with pond_fish. Blocked clicks keep the tool active. mobs.pond place strict restores the full rectangle plus 1 metre, a 2-metre height limit and a single-region requirement. Add preview to either mode for repeated read-only checks; no pond is created.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.pond place
mobs.pond place preview
mobs.pond place strict preview
mobs.pond_fish 500
mobs.pond remove preview
```

## Limits and expected results

The pond size is unchanged; relaxed placement stops rejecting unused corners of its bounding rectangle. Its ghost shows only the actual outline, while strict also shows the old outer clearance rectangle. The coloured READY/BLOCKED label includes specific reasons for terrain, ownership or native blockers. The outline is a footprint guide, not the final water/terrain deformation. More uneven terrain may produce rougher banks; the 10-metre limit is a placement policy, not a proven guarantee of attractive or usable shores. Both preview and apply use the same native plan and recheck the exact click. Existing unfinished ponds are not reinitialized; stock fish separately. User testing confirmed improved pond placement. Actual catches and extended persistence checks remain open.

## Related commands

- [mobs.pond_fish](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-pond_fish) — `mobs.advice.pond_fish`
- [mobs.finish_constructions](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-finish_constructions) — `mobs.advice.finish_constructions`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
