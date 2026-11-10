# Native deposit placement — 0.16.1-alpha.5

Release validation guide for Manor Lords 0.8.117. Restart and check `mobs.version`.
Use a separate save. User testing confirmed pond/mineral placement and the mineral-imprint repair. Extended extraction and persistence checks remain open.

1. Run `mobs.spawn_deposit iron 1000 preview`, close F10 and move the cursor.
   Expect a native ground-material decal, centre crosshair, mining-radius ring and
   a green READY / red BLOCKED label. The radius is 20m normal / 25m rich in this
   executable. A ring is a range guide, not a blanket clearance rule. Check several
   positions: click reports the exact centre and both amounts without creating a
   real reserve, resource or map node. Preview stays active. Right-click cancels.
2. First load a save with an earlier Mobs mineral imprint. Within a few seconds,
   the imprint and extra mineral mesh should disappear without changing reserves.
   `mobs.refresh_resource_icons preview` counts eligible render actors without changing
   them; `mobs.refresh_resource_icons` applies the repair immediately. Check map icons,
   hover amounts and richness before/after. Do not delete/recreate the deposit.
3. Run `mobs.spawn_deposit iron 1000`. Move onto clear owned land, check READY,
   then left-click. The preview should disappear and exactly one native mineral
   group should appear, centred at that click, not at a random nearby location.
   After placing, iron/clay/salt must have NO projected terrain artwork or extra
   ore model. Check the normal-map icon, paper-map icon and tooltip still exist.
   Surface stones elsewhere must keep their models.
   The screenshot error about missing mineral template should no longer occur.
4. Repeat dry-run and real placement with `mobs.spawn_deposit clay 2000 rich` and
   `mobs.spawn_deposit salt 1500`, using different sites. Check the larger rich
   range and the displayed quantity. Each number goes to BOTH surface and underground
   reserves: 1000 means 1000 surface + 1000 underground, not a combined total.
5. Place the centre on a building/native blocker or foreign land: expect a specific
   red reason and no allocation. Click a blocked site, move away and click a READY
   site: the blocked click must not disarm the tool. An existing reserve within 1m
   of the centre is rejected; use `mobs.deposit` to edit it rather than duplicate it.
6. Put an appropriate mine/pit within the shown native mining range and confirm
   actual production with workers. Rich underground reserves follow native deep
   mining rules. Avoid cliffs and awkward banks: a READY centre is not a guarantee
   of worker access or room for a mine everywhere inside the ring.
7. Save separately, reload and confirm position, native decals, tooltip quantities
   and mining still work. Cancel a fresh preview with right-click, mobs.cancel,
   another placement tool, ordinary building mode and loading a save. No stale
   preview or delayed duplicate placement should remain. Five minutes also expires it.
8. Recheck `mobs.pond place preview`: relaxed pond mode should remain as before.
   Surface-only `mobs.spawn_resource iron 100` also uses the corrected mineral class;
   it intentionally creates no underground reserve.

Cleanup is separate for the two layers. Use `mobs.remove_deposit iron preview`, then
repeat without preview to remove underground reserves. `mobs.resource remove iron
preview`, then repeat, removes the real surface group. Each removal command needs
its own click. Inspect the preview carefully; neither removal has undo.

## Evidence and implementation

- Read-only inspection of the user's loaded 0.8.117 game found all three mineral
  ResourceNodeProperties.ResourceTemplate fields NULL, with ScaleVariation 1..1.
- Engine fields ironResourceBP (+0x8a8), clayResourceBP (+0x8b0), saltResourceBP
  (+0x8b8) were populated with Resource_Iron_C / Resource_Clay_C / Resource_Salt_C.
  Native getResourceBP (RVA 0x4cc9c10) uses those exact fields.
- ResourceSettings.resourceDepositRadius / resourceRichDepositRadius (+0x3c/+0x40)
  were 2000 / 2500 game units. Native deposit creation (0x4ce2b30) uses those settings,
  the passed X/Y and ground-height snapping. Resource factory 0x4ce5780 accepts the
  clicked FTransform and authoritative mineral class, rather than a scatter request.
- Hover visuals are plain StaticMeshActor / DecalActor / TextRenderActor instances;
  they never use DepositDecal and never enter the game's reserve/resource registries.
- Input callbacks schedule all UObject work on the game thread, per the
  [official UE4SS API](https://docs.ue4ss.com/dev/lua-api/global-functions/executeingamethread.html).
- These findings and offline checks establish the repair path, not loaded-save
  mining or visual proof. New placement and persistence remain manual checks.

## Terrain imprint finding

Read-only inspection of the affected loaded save confirmed the node's PaperMapDecal
was already invisible in terrain view. The extra underground DepositDecal component
was visible and used resourceNodeDecal_Iron, the paper-map artwork. Natural mineral
nodes had zero clumps; this Mobs node held one Resource_Iron_C data clump. The repair
hides only those extra mineral render actors/components, retaining reserve and finite
clump data for mining/tooltip behavior. Native onPaperMapViewChanged only changes
component visibility: actor hidden-in-game remains independent, so map toggles should
not expose repaired artwork. Verify normal/paper map switching and reload manually.
