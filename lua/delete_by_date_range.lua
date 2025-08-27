-- delete_by_date_range.lua
local cursor = "0"
local start_date = ARGV[1]
local end_date = ARGV[2]
local deleted = 0

repeat
    local result = redis.call("SCAN", cursor, "MATCH", "*", "COUNT", 1000)
    cursor = result[1]
    local keys = result[2]

    for i, key in ipairs(keys) do
        local date = string.match(key, "%d%d%d%d%-%d%d%-%d%d")
        if date and date >= start_date and date <= end_date then
            redis.call("DEL", key)
            deleted = deleted + 1
        end
    end
until cursor == "0"

return deleted
