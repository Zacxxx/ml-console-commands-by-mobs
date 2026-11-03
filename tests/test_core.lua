package.path = "src/mobs_console/Scripts/?.lua;" .. package.path
local core = require("core")
assert(core.target(20, "add", 5) == 25)
assert(core.target(20, "set", 5) == 5)
for _, value in ipairs({"nan", "inf", "1.2", "-1", "100000001", "1;quit"}) do
    assert(not pcall(core.integer, value, 0, 100000000), value)
end
assert(not pcall(core.target, 1, "add", -2))
assert(not pcall(core.target, 1, "multiply", 2))
print("Input validation and bounds passed")
