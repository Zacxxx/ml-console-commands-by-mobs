# Aquatic and wildlife checks — 0.16.0-alpha.3

Alpha release for **Manor Lords 0.8.117**. Offline checks pass; actual harvesting, hunting and
save/reload results await your test. Restart the game to load the new native DLL,
then check `mobs.version`. Use a separate save so you can discard test placements.

## Repair an existing eel shoal

```text
mobs.repair_fishing eel preview
```

Close the console and click near the actual shoal in owned water, within 2500 game
units. The preview reports identity/seasonal changes, missing region registrations
and the availability tag. It changes no resource amounts.

```text
mobs.repair_fishing eel
```

Close the console and click the same shoal again. Resume the simulation, use the
appropriate staffed fishing workplace with access to the shoal, and check that
workers actually catch eels. Quantities and capacity should stay unchanged by the
repair itself; ordinary harvesting and seasonal updates can change them afterward.
`mobs.repair_fishing fish` handles fish explicitly; it never substitutes eel for
fish. Building-attached pond shoals are excluded from this repair.

To create a new test shoal instead:

```text
mobs.spawn_resource eel 400 1 preview
mobs.spawn_resource eel 400 1
```

Each line is a separate one-shot tool: close the console and click suitable owned
water after each command. Confirm a real catch, then save to a separate slot and
reload. Check whether the shoal remains, retains its kind/quantity under ordinary
game rules and can still be harvested. A visible icon alone is not this result.

For explicit cleanup, `mobs.resource remove eel preview`, then the same command
without preview, removes the nearest matching owned node after a click. This now
also accepts an empty clumpless aquatic node. `fish` targets only fish. Deletion has
no undo; unloading the mod does not revert saved edits.

## Create a huntable herd

```text
mobs.spawn_wildlife deer preview
mobs.spawn_wildlife deer
```

After each command, close the console and click clear owned ground. **The node
and herd home are placed at that click**, with animals nearby. Preview checks the
same animal positions used by apply: valid native height, same owned region and
native blockers. A blocked/border-crossing placement is refused before spawning.
Population is the midpoint of the game normal/rich herd range, so preview and apply
agree. The result reports population, herd ID and clicked coordinates. Animals can
wander afterward under ordinary game AI.

Include that site in a staffed hunting camp's work area, ensure its hunting limit
allows catches, resume simulation and observe actual hunting and collected goods.
Save separately and reload; check the herd/node is still present and huntable.

Other supported variants:

```text
mobs.spawn_wildlife deer rich
mobs.spawn_wildlife hare preview
mobs.spawn_wildlife hare
mobs.spawn_wildlife hare rich
```

These create one herd per applied click; don't run all lines if you only want one.
`rich` uses native rich population settings. Arbitrary food amounts/clump counts
are not supported here. `mobs.animal deer/hare` remains individual animal spawning,
separate from a hunting resource node. There is no herd-spawn undo; discard the
test save when finished. If the result says registration was incomplete, capture
the message and don't repeat placement blindly.

Read-only help is available through `mobs.advice.repair_fishing`,
`mobs.advice.spawn_wildlife`, and the updated `mobs.tutorial` chapters.

## What to report

Send `mobs.version`, exact command/result text, whether actual catches occurred,
and whether the shoal/herd survived a separate save/reload. For eel behavior include
the season and whether it was a new or repaired node. Screenshot the result if
either native template or registration checks refuse the operation.
