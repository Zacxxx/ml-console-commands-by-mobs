# Compatibility and known limits — 0.15.0-alpha.1

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
Selection, contextual autocomplete and deposit creation/removal fixes pass offline
checks but still need fresh in-game reproduction and save/load confirmation.
Spawned eel ignored by fishermen / later despawning remains an open report.
`mobs.animal deer/hare` creates individuals, not registered huntable resource nodes.

New `spawn_deposit` creates the requested amount in a surface clump PLUS the same
underground reserves; these are separate layers. Rich underground reserves can be
endless under native deep-mining rules. Existing white-stripe/empty-marker placements
are not silently rewritten. Preview `remove_deposit` to remove the old reserve/decal,
and `resource remove` for remaining real surface clumps or orphaned empty markers.

## Reporting a problem

Include your game version, UE4SS version, mod version from mobs.version, exact
command, selected target, expected result and actual result. State whether the
problem also occurs after restarting with other optional mods disabled.
Attach only the relevant UE4SS.log excerpt; remove personal paths or save names.
Do not post an entire save or Native/State folder unless you choose to share it.
For a crash, include the timestamp and the preceding relevant log lines.
