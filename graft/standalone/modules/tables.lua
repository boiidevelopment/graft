--[[
--------------------------------------------------

This file is part of GRAFT.
You are free to use these files within your own resources.
Please retain the original credit and attached MIT license.
Support honest development.

Author: Case @ BOII Development
License: MIT (https://github.com/boiidevelopment/graft/blob/main/LICENSE)
GitHub: https://github.com/boiidevelopment/graft

--------------------------------------------------
]]

--- @module tables
--- @description StTablering utilities beyond standard Lua table library

--- @section Module

local m = {}

--- Prints the contents of a table to the console. Useful for debugging.
--- @param t table: The table to print.
--- @param indent string|nil: The indentation level for nested m.
function m.print(t, indent)
    indent = indent or ''
    for k, v in pairs(t) do
        if type(v) == 'table' then
            print(indent .. k .. ':')
            m.print(v, indent .. '  ')
        else
            local value_str = type(v) == "boolean" and tostring(v) or v
            print(indent .. k .. ': ' .. value_str)
        end
    end
end

--- Checks if a table contains a specific value.
--- @param tbl table: The table to search through.
--- @param val any: The value to search for in the table.
--- @return boolean: True if the value was found, false otherwise.
function m.contains(tbl, val)
    for _, value in pairs(tbl) do
        if value == val then
            return true
        elseif type(value) == "table" then
            if m.contains(value, val) then
                return true
            end
        end
    end
    return false
end
m.table_contains = contains

--- Creates a deep copy of a table, ensuring changes to the copy won't affect the original table.
--- @param t table: The table to copy.
--- @return table: A deep copy of the table.
function m.copy(t)
    local orig_type = type(t)
    local copy

    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, t, nil do
            copy[m.copy(orig_key)] = m.copy(orig_value)
        end
        setmetatable(copy, m.copy(getmetatable(t)))
    else
        copy = t
    end

    return copy
end
m.deep_copy = copy

--- Compares two nested tables to check if they are equal.
--- @param t1 table: The first table.
--- @param t2 table: The second table.
--- @return boolean: True if the tables are equal, false otherwise.
function m.compare(t1, t2)
    if t1 == t2 then return true end
    if type(t1) ~= "table" or type(t2) ~= "table" then return false end

    for k, v in pairs(t1) do
        if not m.compare(v, t2[k]) then return false end
    end

    for k in pairs(t2) do
        if t1[k] == nil then return false end
    end

    return true
end

--- Deeply merges two tables (b into a), without mutating original m.
--- @param a table: The base table (usually defaults).
--- @param b table: The override table (e.g., strain).
--- @return table: A new table containing the merged result.
function m.merge(a, b)
    local result = m.copy(a)

    for k, v in pairs(b) do
        if type(v) == "table" and type(result[k]) == "table" then
            local is_array = (#v > 0 or #result[k] > 0)
            if not is_array then
                result[k] = m.merge(result[k], v)
            else
                result[k] = v
            end
        else
            result[k] = v
        end
    end

    return result
end

--- Serialize a table to a formatted string
--- @param tbl table
--- @param indent string|nil
--- @return string
function m.serialize(tbl, indent)
    indent = indent or ""
    local next_indent = indent .. "    "
    local lines = { "{" }

    for k, v in pairs(tbl) do
        local kt = type(k)
        local key = (kt == "string" and k:match("^[%a_][%w_]*$") and k) or (kt == "string" and ("[" .. string.format("%q", k) .. "]")) or ("[" .. tostring(k) .. "]")

        local vt = type(v)
        local value = (vt == "table" and m.serialize(v, next_indent)) or (vt == "string" and string.format("%q", v)) or ((vt == "number" or vt == "boolean") and tostring(v))

        if value then
            lines[#lines + 1] = next_indent .. key .. " = " .. value .. ","
        end
    end

    lines[#lines + 1] = indent .. "}"
    return table.concat(lines, "\n")
end

return m