-- Copyright 2026 Mobs. MIT licensed. Original implementation.
local M = {}

function M.integer(value, minimum, maximum)
    local number = tonumber(value)
    assert(number and number == number and number % 1 == 0,
        "Expected a whole number")
    assert(number >= minimum and number <= maximum,
        string.format("Number must be between %d and %d", minimum, maximum))
    return number
end

function M.target(current, operation, amount)
    assert(operation == "set" or operation == "add", "Use set or add")
    local result = operation == "set" and amount or current + amount
    return M.integer(result, 0, 100000000)
end

return M
