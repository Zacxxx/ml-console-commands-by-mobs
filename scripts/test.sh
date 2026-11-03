#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")/.."
python3 scripts/command_parity.py --check
python3 -m unittest discover -s tests/world_tools -p 'test_*.py' -v
python3 -m unittest discover -s tests/release -p 'test_*.py' -v
lua tests/console_ux/test_ux.lua
lua tests/world_tools/test_commands.lua
lua tests/parity_tools/test_commands.lua
lua tests/parity_tools/test_files.lua
lua tests/parity_tools/test_resources.lua
lua tests/parity_tools/test_deposits.lua
lua tests/parity_tools/test_teleport.lua
lua tests/test_core.lua
lua tests/test_commands.lua
lua tests/test_construction.lua
lua tests/test_construction_layout.lua
lua tests/test_supplies_click.lua
lua tests/pile_tools/test_cleanup.lua
lua tests/perk_tools/test_commands.lua
lua tests/perk_tools/test_card_identity.lua
lua tests/perk_tools/test_stacking.lua
lua tests/forestry/test_commands.lua
perk_test_binary=$(mktemp /tmp/mobs-perks-test.XXXXXX)
trap 'rm -f "$perk_test_binary"' EXIT
cc -Wall -Wextra -Werror tests/perk_tools/test_containers.c -o "$perk_test_binary"
"$perk_test_binary"
cc -Wall -Wextra -Werror tests/forestry/test_growth_loop.c -o "$perk_test_binary"
"$perk_test_binary"
cc -Wall -Wextra -Werror tests/parity_tools/test_soil_cells.c -o "$perk_test_binary"
"$perk_test_binary"
cc -Wall -Wextra -Werror tests/world_tools/test_resource_plan.c -o "$perk_test_binary"
"$perk_test_binary"
cc -Wall -Wextra -Werror tests/console_ux/test_tree.c -o "$perk_test_binary"
"$perk_test_binary"
for file in src/mobs_console/Scripts/*.lua; do
    luac -p "$file"
done
