# 0.15.0-alpha.1 — Community fixes and shared guidance

- Add detailed `mobs.advice.<command>` / `mobs.advice <command>` guides and a
  13-chapter tutorial (`mobs.tutorial all`). Advice is read-only and works without a save.
- Publish a generated wiki: 94 base names/aliases, linked per-command steps and
  examples, a report-status audit, and 212 sparse item enum IDs in Markdown/JSON/CSV.
- Read selected buildings from the reflected pawn-owned selection; avoid borrowing
  the by-value `getSelectedBuildings()` return array. Preserve ownership preflight.
- Gate autocomplete argument entries until the full command prefix. Hide detailed
  advice aliases from broad help/search prefixes; accept native Windows CRLF responses.
- Create underground decals with native ground-facing rotation. New spawn_deposit
  also creates a real finite surface clump: amount applies separately to surface and reserves.
- Remove colocated empty legacy mineral markers with underground removal, and allow
  resource remove to find orphaned empty mineral markers without deleting real reserves.
- Include all 0.14.1–0.14.3 local resource sizing/view/HUD-list/type-hint fixes.
- Offline checks and 30 native entry guards pass. Fresh live visuals/mining/save-load
  confirmation is pending; spawned eel harvesting/despawn remains open. Individual
  deer/hare spawning is not registered hunting-node creation.

# 0.14.3-alpha.1 — Resource type hints

- If an owned nearby node has a different resource type, keep the requested
  filter and explain the actual nearby type with an example command.
- Resource removal/richness previews and results now name the resource type.
- Read-only live diagnosis confirmed the reported rich river node in In der
  Schlau is ENodeType::Eel (11), while fish is ENodeType::Fish (5). The existing
  `mobs.resource remove eel` command handles it; richness does not change syntax.

# 0.14.2-alpha.1 — Resource icons and hover details

- Synchronize the HUD's separate resource-node snapshot after creating or
  removing nodes. It previously retained only the nodes present at HUD startup.
- Add `mobs.refresh_resource_icons [preview]` to repair existing normal-map
  resource icons and paper-map hover details without clicking, moving resources
  or changing their quantities.
- `mobs.resource refresh` now synchronizes that HUD list as well.
- Live read-only diagnosis confirmed a spawned node present in the world list
  and absent from the HUD list. Visual confirmation of this fix is pending.

# 0.14.1-alpha.1 — Resource visibility repair

- Spawn resource clumps at the size configured for their resource type instead
  of a fixed actor scale of 1.
- Synchronize new resource meshes and decals with the current paper-map view.
- Add `mobs.resource refresh berries [preview]`: click near an existing owned
  berry group to refresh ground height, size and visibility. The same tool
  supports other land resource kinds; quantities/capacity/richness stay intact.
- Offline checks and exact-build guards pass. The reported missing-bush case
  still requires an in-game visual check; this patch is not a claim of that result.

# 0.14.0-alpha.1 — First Nexus release candidate

## Console and usability

- Native command suggestions with descriptions, fixed choices and loaded item,
  owned-region and regional-card names; exact game-build guard.
- Dashboard, ranked command search with spelling suggestions, syntax help and
  read-only completion fallback.
- Recent successful-command history, shorter errors and usage guidance.
- Exact spaced routing, for example mobs finish constructions preview.

## Settlement tools included

- Treasury, influence, regional wealth and approval edits, with guarded economy undo.
- Region targeting, inventories, construction reports, material supply, work preparation,
  pause/resume and a session-global instant-build toggle for new placements.
- Click/selected-building supply tools, new Supplies piles and empty/selected pile removal.
- Natural resources and deposits: inspect, refill, create, enrich, add reserves and remove.
- World-tree growth/regrowth and separate forester-sapling/stage tools.
- Regional perk tier choices, respec and additional active card effects.
- Population/livestock utilities, units/camera/name tools, weather, time, farming/soil,
  ownership/claim helpers and local command files.

## Scope and verification

All 74 identifiers in the supplied original 1.0.4-a.4 reference inventory have scoped
practical counterparts. Their behavior is independently implemented; exact parity,
universal compatibility and gameplay testing of every variant are not claimed.
Focused user confirmations cover construction, Supplies/pile tools and regional perks.
Later features and their save/load behavior remain marked for further confirmation.
