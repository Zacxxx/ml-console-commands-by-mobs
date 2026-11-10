# Compatibility and known limits — 0.16.1-alpha.5

- **Game target: Manor Lords 0.8.117 only.** The native helper guards target the
  Steam pre_release executable (PE timestamp 0x6836c1ba, image size 0x9dfd000).
  Other game/loader versions and Vortex deployment are unverified.
- **Alpha status.** Offline checks are not a complete game-session or save/load test.
  Construction, Supplies placement/cleanup and regional perks received focused user
  confirmations. Recent world spawning, weather, soil, forestry variants and native
  autocomplete still need broader in-game confirmation. This is feature coverage,
  not a claim that every variant has passed gameplay testing.
- **Unloading does not revert saved edits.** Economy, inventory, demolition and
  spawned-world changes can remain in a save. Not all actions support undo.
  Some batch operations can report partial completion; already completed changes remain.
- **Mineral terrain appearance:** placed iron/clay/salt reserves and data clumps
  are render-hidden, preserving quantities and the separate map icon/tooltip.
  Earlier mineral imprints are hidden automatically after load; run
  `mobs.refresh_resource_icons` for immediate repair. Surface stones stay visible.
- **Deposit preview:** native ground material, centre crosshair and mining-range ring
  follow the cursor. The ring is not an empty-clearance requirement. Owned centre,
  terrain, native blockers and duplicate-centre checks apply. Mine access, display
  and persistence of these new placements still need manual checks.
- **Pond preview:** relaxed mode checks the actual footprint, up to 10m height
  variation and adjoining owned regions. Add strict for the old rectangle/2m rule.
  The ghost shows the active footprint, not the final
  water/terrain deformation. The green/red READY/BLOCKED label is authoritative;
  outline tint is available only if the installed engine material exposes Color.
  User testing confirmed pond placement and the mineral visual repair; extended
  harvesting and persistence checks remain open.
- **Construction:** the command prepares work and supplies materials; finalization
  remains simulation-driven. Resume if paused and let workers reach the site.
- **Piles:** remove_selected_piles deletes selected owned Supplies piles including
  their contents. Use preview and check your selection first. It has no undo.
- **Extra regional cards:** the vanilla screen shows primary cards only. Extra
  cards apply both bonuses and penalties; shared effects apply once. Their saved
  bookkeeping is kept in Native/State. Preserve that folder when upgrading.
  Full extra-effect save/load persistence has not been independently verified.
- **Trees:** growth runs in bounded batches through native transitions, and can
  report blocked entries. grow_saplings and grow_stage distinguish forester-planted
  crops/work areas from world trees. Regrowth and young-tree save/load results need
  further confirmation.
- **Autocomplete:** the native dropdown is exact-build and prefix-based. Typo search
  is supplied by mobs.find, not automatic execution of guessed commands. If entries
  are absent, run mobs.autocomplete refresh or use mobs.complete. Open Development
  once before refreshing card names. Native input/display interactions remain unverified.
- **Regions:** automatic targeting uses your pinned target, otherwise the selected
  region, otherwise the current region. Read mobs.status; use mobs.region auto to
  clear a pin. Ownership checks restrict most regional/building actions.
- **Scope differences:** these are independent mobs.* commands. Original k.* aliases
  are not registered. debug_task is a read-only context diagnostic, not arbitrary
  worker-job assignment. Practical counterpart coverage does not mean identical behavior.

## Community report status

[Full report audit](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Bug-report-status).
Offline checks pass. User testing confirmed pond placement, native mineral placement
and mineral-imprint cleanup. Selection/autocomplete variants, extended worker
extraction and full save/load coverage still need broader confirmation.
The **0.16 alpha** addresses aquatic template identity/seasonality
and missing regional availability tags; `mobs.repair_fishing` repairs existing
shoals without refilling them. Actual catches and save/reload survival remain open
until user testing. It cannot repair every invalid water placement or worker access.
`mobs.spawn_wildlife deer/hare` now uses native herd/squad/node registration. Placement
uses the clicked location as the node/herd home and native population settings; hunting and
save/reload need user confirmation. `mobs.animal deer/hare` remains individual spawning.

New `spawn_deposit` creates the requested amount in a surface clump PLUS the same
underground reserves; these are separate layers. Rich underground reserves can be
endless under native deep-mining rules. Existing owned mineral terrain imprints are hidden automatically after loading,
without deleting data; `refresh_resource_icons` repairs them immediately. Removal
is separate: preview `remove_deposit` for reserves and `resource remove` for real
surface clumps or orphaned empty markers.

## Reporting a problem

Include your game version, UE4SS version, mod version from mobs.version, exact
command, selected target, expected result and actual result. State whether the
problem also occurs after restarting with other optional mods disabled.
Attach only the relevant UE4SS.log excerpt; remove personal paths or save names.
Do not post an entire save or Native/State folder unless you choose to share it.
For a crash, include the timestamp and the preceding relevant log lines.


## Population creation

`grow_population` now creates a requested 1..10 people directly through the native
arrival/family/home path. It bypasses the scheduling/approval gates that made
repeated daily growth checks no-op, while retaining housing and entrance checks.
Use `mobs.grow_population status` and `preview`. The number is people, not families
or attempts. The command does not force approval or advance time. Normal needs and
later migration still apply. Native failure can leave a reported partial result;
there is no undo. Actual arrivals and save/reload need user confirmation.

## Completed pond placement

`mobs.pond place` now directly creates a completed empty pond at your click on
owned ground, using initial map-generation setup. Relaxed mode accepts a 10m
height spread and checks only the actual pond shape; strict retains the old rules. There is
a separate footprint ghost with a green/red status label, and no builder stage.
`place preview` follows the cursor and repeated clicks only report; it creates
no game buildings. Right-click cancels. Fish remain separate (`mobs.pond_fish 500`), using
native pond transforms. Existing unfinished ponds are not automatically repaired.
User testing confirmed pond placement. Actual catches and extended persistence
checks remain open. Native unsupported-build guards
remain active and now identify the failed timestamp/layout or entry RVA.
