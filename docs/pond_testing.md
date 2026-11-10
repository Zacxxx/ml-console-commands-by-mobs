# Relaxed pond placement — 0.16.1-alpha.5

Release validation guide for Manor Lords 0.8.117. Restart the game and check
`mobs.version`.  Use a separate save.

1. Run `mobs.pond place preview`, close the console and move over your land.
   The outline follows the pond's actual polygon (about 84 x 79 metres); its size
   has not changed. The label should say RELAXED and green READY or red BLOCKED.
   There is no extra rectangle/margin requirement. Up to 10 metres of height
   variation across the outline is allowed, as is neighbouring owned land.
   Click sites for read-only reports; no pond, terrain edit or construction job
   should be created. A blocked click keeps the preview. Right-click cancels.
2. Compare with `mobs.pond place strict preview` at the same location. STRICT
   restores the old rectangle plus 1-metre margin, 2-metre height limit and single
   region restriction. It should reject some sites accepted by RELAXED. Reasons
   should distinguish terrain, ownership and native blockers. Both modes continue
   to reject invalid map terrain, foreign land and native navigation/building blockers.
3. Cancel the dry run, then run `mobs.pond place`. Left-click a green READY site.
   One completed empty pond should appear and the preview should disappear. Check
   terrain, water and banks, especially on uneven ground. More permissive placement
   does not guarantee attractive banks or usable fishing access on every slope.
4. Use `mobs.pond_fish 500 preview`, then `mobs.pond_fish 500`, each followed by a
   click near the completed pond. Confirm actual worker catches, then save separately
   and reload to check pond geometry, shoal and fishing. No builders are needed.
5. Cancel another preview with right-click, `mobs.cancel`, ordinary construction
   mode, another click tool or loading a save. No stale ghost/delayed placement
   should remain. Five minutes also expires the tool.

The ghost previews the footprint, not water/terrain deformation. Its status label
always uses red/green; outline tint additionally depends on the engine material's
Color parameter. Visual actors do not collide or enter game building registries.
The exact click is rechecked using the same native plan as the hovering preview.

Existing unfinished ponds are untouched. Removal still uses `mobs.pond remove
preview` then `mobs.pond remove`, each with its own click. There is no undo; do not
blindly repeat after a partial native failure. Native compatibility guards remain
active. Offline checks are complete; in-game results remain for manual testing.

## Native investigation

The verified executable's fish-map-generator branch at RVA 0x4ce3fcf allocates
building type 39 through 0x4ca1bb0, sets Data.constructed at +0x3c1, registers its
region/owner with 0x4d39b40, then calls initial SetupBuilding at 0x4d1a650. After
native additionalWorkPositions are populated, it updates finalBorder through
0x4d37620 and spawns fish using those full transforms. A read-only inspection of the loaded native pond row found 20 custom-border
points (X -3877..4480, Y -3791..4062 game units). Relaxed preflight now samples that actual polygon; strict mode retains the
conservative rectangle plus 100 units. Neither treats the full 8500×9500 UI Bounds
as half-extents. The candidate uses that
initialization sequence only on a fresh allocation, leaving stocking separate.
These are source/disassembly findings, not evidence of successful gameplay.
