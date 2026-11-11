# 0.16.1-alpha.6 — Background callback stability

- Run automatic mineral visual repair and extra perk restoration with repeating
  UE4SS game-thread timers. Each job registers its callback once instead of
  repeatedly handing callbacks from an asynchronous timer to the game thread.
- Refresh autocomplete with a direct game-thread delay. Cancel a pending refresh
  when another load/restart requests one, avoiding duplicate queued refreshes.
- Keep background timers single-instance and allow the mineral repair timer to
  be cancelled cleanly. Existing deposit visual repair and extra-card restoration
  continue automatically on supported UE4SS builds.
- Require the game-thread timer APIs for these automatic jobs. The installed
  UE4SS 3.0.1-1152 build provides them. Older builds without these APIs report
  unavailable background jobs at startup; manual commands remain available.
- Add checks for async-free startup, repeating repair, cancellation and refresh
  replacement. The complete offline suite passes. This targets the reported
  UE4SS Lua callback access violations; extended in-game stability confirmation
  is still pending.

Restart the game after updating. Preserve Native/State and your custom Commands
files. Target remains Manor Lords 0.8.117.

# 0.16.1-alpha.5 — Pond and deposit placement fixes

- Fishing Ponds now place already completed using the native map-initialization
  path. No builders or finish_constructions are needed. Stock fish separately with
  `mobs.pond_fish 500`; fish use the completed pond's native placement anchors.
- Add a moving pond outline with a green READY / red BLOCKED label and specific
  rejection reasons. Blocked clicks keep the preview active; right-click or
  `mobs.cancel` cancels. `mobs.pond place preview` supports repeated read-only checks.
- Make pond placement more permissive: check the actual polygon, remove the extra
  clearance margin, allow 10m rather than 2m of height variation, and allow adjacent
  regions owned by the same lord. `mobs.pond place strict` restores the old rules.
- Fix "Mineral resource template or native size unavailable" by using the game's
  authoritative iron/clay/salt Blueprint classes. Surface-only mineral spawning
  uses the corrected class lookup too.
- Add native ground-material previews, exact-centre crosshairs and mining-range rings
  to `mobs.spawn_deposit`. Place at the clicked X/Y with terrain height snapping;
  no random relocation. Show native 20m normal / 25m rich mining range and amounts.
- Fix white paper-map artwork projected onto terrain after mineral placement. Hide
  extra reserve/data-clump rendering while preserving quantities, richness, capacity,
  collision/mining data and separate normal-map/paper-map icons and tooltips.
  Surface stones keep their models.
- Automatically repair earlier owned mineral imprints after loading, without deleting
  or recreating the deposits. `mobs.refresh_resource_icons` applies the same visual
  repair immediately; append `preview` for a read-only count.
- Update in-game advice/tutorial, wiki examples and report-status notes. Native
  incompatibility errors identify the failed executable layout or entry point.
- User testing confirmed improved pond placement, native deposit placement and the
  terrain-imprint repair. Offline checks pass and all 49 native entry guards match
  the supported game. Extended mining, harvesting and save/reload checks remain open.

Restart the game after upgrading native helpers. Preserve Native/State and custom
Commands files. Target remains Manor Lords 0.8.117; this is an alpha release.

# 0.16.0-alpha.3 — Aquatic repair, click-placed wildlife and population

- Add `mobs.repair_fishing [eel|fish] [preview]` to repair native aquatic identity,
  seasonality, height, regional/spatial registration and availability tags. Existing
  shoal quantity, capacity and richness are preserved. New aquatic nodes retain
  their native Blueprint identity and seasonal flags.
- Add `mobs.spawn_wildlife <deer|hare> [rich] [preview]`: create a native registered
  herd and hunting node at the next clicked owned location, with native normal/rich
  population. Preflight terrain, ownership and blockers for every animal.
- Replace repeated calendar-gated population attempts with native resident/family/
  home creation. `grow_population` now requests PEOPLE (1..10), default 1, with
  `status` and `preview`. No date/approval changes; housing and entrance checks stay.
  A partial native failure reports the actual result and stops without retrying.
- Allow explicit cleanup of empty clumpless aquatic nodes. Exact resource filters
  remain: eel and fish are different kinds and are never substituted automatically.
- Update advice, tutorial, wiki and report audit: 96 base names/aliases, 95 detailed
  dotted advice shortcuts, 13 tutorial chapters and 212 item enum IDs.
- Replace versioned promotional cards with the corrected medieval-computer cover
  and banner, generated using Manor Lords key art as a visual reference.
- Offline checks and 43 native entry guards pass. Worker catches, hunting, arrivals
  and save/reload persistence are not yet confirmed in a loaded game. This remains
  an alpha for Manor Lords 0.8.117 only; restart after updating and preserve State.

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
