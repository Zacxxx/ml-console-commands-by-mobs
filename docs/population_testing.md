# Population checks — 0.16.0-alpha.3

Restart the game and confirm `mobs.version`. This is an alpha release for
Manor Lords 0.8.117; native creation in a loaded save and save/reload still need testing.

The old command called the whole natural growth evaluator repeatedly on the same
date. That evaluator checks the monthly growth modifiers and scheduled arrival
days; repeating it does not advance the calendar. It also performs other daily
population processing. The replacement calls the native person/family/home creation
path directly, without changing the date or forcing approval values.

## Commands

```text
mobs.grow_population status
mobs.grow_population 3 preview
mobs.grow_population 3
```

No click is needed. Use your owned command-target region; `mobs.status` shows it,
`mobs.region auto` clears an old pin. The number now means **people**, not families
or attempts. Default one person; maximum ten per call. Three added people may fill
an existing family or form a new household depending on available places.

Status reports the game's natural monthly growth result, approval, usable housing
places and homeless families. A zero natural growth result no longer prevents
explicit creation. The command still requires completed, active, non-mourning
housing. Existing homeless families take priority over new households.

Preview plans the whole requested count and checks native entrances before any
creation. If there are too few places, it refuses without adding anyone. Request
a smaller number or provide housing. If a native creation fails during apply,
the command stops and reports the actual count; earlier successful arrivals remain.
There is no automatic retry or undo.

## Test

1. Use a separate save. Record population, date and approval.
2. Run status and preview. Confirm that preview adds nobody and advances no time.
3. Apply the same count. Check the **human population**, family membership and home
   assignments; the family counter need not increase by the requested people count.
4. Resume simulation and inspect the new residents. They have normal needs and
   can later leave under normal migration rules if conditions deteriorate.
5. Save separately and reload; confirm the new people, families and homes persist.

If the command refuses an entrance, housing or registration check, send the exact
result and `mobs.version`. If it reports partial completion, inspect the population
before issuing another request.
