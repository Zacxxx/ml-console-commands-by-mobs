# mobs.spawn_wildlife

Guide for **0.16.1-alpha.6**, game **0.8.117**.

Click clear owned ground to place one huntable deer/hare herd and its resource node there. Native normal/rich settings determine population; animals spread around the click. Preview available; no undo.

```text
mobs.spawn_wildlife <deer|hare> [rich] [preview]
```

## In-game advice

`mobs.advice.spawn_wildlife` or `mobs.advice spawn_wildlife`. These display help without executing the action.

## Target

Run the command, close the console, then click the intended location in an owned region. It is a one-shot tool with a five-minute expiry. mobs.cancel disarms it. Preview also requires the click, but changes nothing.

## Steps

Choose deer or hare, optionally rich, and preview first. Close the console and click clear ground in an owned region. The resource node and herd home are placed at that click; animals are distributed nearby. All planned animal sites are checked for valid native height, the same region and native blockers before any squad or animal is created. Repeat without preview and click the same spot to apply. Include the site in a staffed hunting camp work area and resume simulation.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.spawn_wildlife deer preview
mobs.spawn_wildlife deer
mobs.spawn_wildlife deer rich
mobs.spawn_wildlife hare
```

## Limits and expected results

0.16 alpha; actual hunting and save/reload await user testing. Population is the midpoint of the game normal/rich population range (bounded to 1..256), so preview and apply agree. Animals begin within 1000 game units of the clicked node and can wander under normal game AI. Blocked or border-crossing placements are refused before spawning. One herd per applied click. Existing mobs.animal deer/hare remains individual spawning. No undo; do not repeat placement if registration reports an incomplete result.

## Related commands

- [mobs.animal](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-animal) — `mobs.advice.animal`
- [mobs.resources](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-resources) — `mobs.advice.resources`
- [mobs.refresh_resource_icons](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-refresh_resource_icons) — `mobs.advice.refresh_resource_icons`
- [mobs.cancel](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-cancel) — `mobs.advice.cancel`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
