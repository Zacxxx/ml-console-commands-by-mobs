# mobs.resources

Guide for **0.16.0-alpha.3**, game **0.8.117**.

Inspect existing mineral, berry, mushroom, fish and eel clumps in the target owned region; does not count stored goods.

```text
mobs.resources [kind]
```

## In-game advice

`mobs.advice.resources` or `mobs.advice resources`. These display help without executing the action.

## Target

Your owned command-target region. Run mobs.regions, then mobs.region with a listed ID; confirm mobs.status. mobs.region auto clears the pin.

## Steps

Inspect existing clumps with resources. Refill returns matching existing clumps to capacity; empty sets matching amounts to zero while retaining actors. Preview either mutation first.

## Examples

Examples below are command text to enter yourself; reading this page never runs them.

```text
mobs.resources berries
```

## Limits and expected results

Kinds: iron, clay, salt, stone, berries, mushrooms, fish, eel; wildlife excluded. Does not create nodes or fill storehouses. Existing underground reserves use deposit. Empty seasonal resources may later regrow under game rules.

## Related commands

- [mobs.undo_resources](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-undo_resources) — `mobs.advice.undo_resources`
- [mobs.spawn_resource](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-spawn_resource) — `mobs.advice.spawn_resource`
- [mobs.deposit](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Command-deposit) — `mobs.advice.deposit`

[All commands](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Commands) · [Tutorial](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Tutorial) · [Item IDs](https://github.com/Zacxxx/ml-console-commands-by-mobs/wiki/Item-IDs)
