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

--- @module strings
--- @description String utilities beyond standard Lua string library

--- @section Module

local m = {}

--- Capitalizes the first letter of each word in a string.
--- @param str string The string to capitalize
--- @return string The capitalized string
function m.capitalize(str)
    if type(str) ~= "string" then
        error("capitalize: expected string, got " .. type(str))
    end
    return string.gsub(str, "(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
end

--- Splits a string into a table based on a delimiter.
--- @param str string The string to split
--- @param delimiter string The delimiter to split by
--- @return table Array of substrings
function m.split(str, delimiter)
    if type(str) ~= "string" then
        error("split: expected string, got " .. type(str))
    end
    if type(delimiter) ~= "string" or delimiter == "" then
        error("split: delimiter must be non-empty string")
    end
    
    local result = {}
    for piece in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, piece)
    end
    return result
end

--- Trims whitespace from the beginning and end of a string.
--- @param str string The string to trim
--- @return string The trimmed string
function m.trim(str)
    if type(str) ~= "string" then
        error("trim: expected string, got " .. type(str))
    end
    return str:match("^%s*(.-)%s*$") or ""
end

--- Generates a random alphanumeric string of specified length.
--- @param length number The length of the random string
--- @return string The generated string
function m.random_string(length)
    if type(length) ~= "number" or length < 0 then
        error("random_string: length must be non-negative number")
    end
    
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = {}
    for i = 1, length do
        local idx = math.random(1, #chars)
        result[i] = chars:sub(idx, idx)
    end
    return table.concat(result)
end

--- Checks if string starts with a prefix.
--- @param str string The string to check
--- @param prefix string The prefix to match
--- @return boolean True if string starts with prefix
function m.starts_with(str, prefix)
    if type(str) ~= "string" or type(prefix) ~= "string" then
        error("starts_with: expected strings")
    end
    return str:sub(1, #prefix) == prefix
end

--- Checks if string ends with a suffix.
--- @param str string The string to check
--- @param suffix string The suffix to match
--- @return boolean True if string ends with suffix
function m.ends_with(str, suffix)
    if type(str) ~= "string" or type(suffix) ~= "string" then
        error("ends_with: expected strings")
    end
    return str:sub(-#suffix) == suffix
end

--- Replaces first occurrence of old substring with new.
--- @param str string The string to search in
--- @param old string The substring to replace
--- @param new string The replacement substring
--- @return string Modified string
function m.replace(str, old, new)
    if type(str) ~= "string" or type(old) ~= "string" or type(new) ~= "string" then
        error("replace: expected strings")
    end
    return str:gsub(old, new, 1)
end

--- Replaces all occurrences of old substring with new.
--- @param str string The string to search in
--- @param old string The substring to replace
--- @param new string The replacement substring
--- @return string Modified string
function m.replace_all(str, old, new)
    if type(str) ~= "string" or type(old) ~= "string" or type(new) ~= "string" then
        error("replace_all: expected strings")
    end
    return str:gsub(old, new)
end

--- Reverses a string.
--- @param str string The string to reverse
--- @return string Reversed string
function m.reverse(str)
    if type(str) ~= "string" then
        error("reverse: expected string, got " .. type(str))
    end
    return str:reverse()
end

--- Repeats a string N times.
--- @param str string The string to repeat
--- @param count number How many times to repeat
--- @return string Concatenated repeated string
function m.repeat_string(str, count)
    if type(str) ~= "string" or type(count) ~= "number" or count < 0 then
        error("repeat_string: expected string and non-negative number")
    end
    return string.rep(str, count)
end

--- Truncates string to max length, adding suffix if truncated.
--- @param str string The string to truncate
--- @param max_length number Maximum length (including suffix)
--- @param suffix string Suffix to add if truncated (default: "...")
--- @return string Truncated string
function m.truncate(str, max_length, suffix)
    if type(str) ~= "string" or type(max_length) ~= "number" then
        error("truncate: expected string and number")
    end
    
    suffix = suffix or "..."
    if #str <= max_length then
        return str
    end
    return str:sub(1, math.max(0, max_length - #suffix)) .. suffix
end

--- Checks if string is empty or contains only whitespace.
--- @param str string The string to check
--- @return boolean True if string is empty or whitespace-only
function m.is_empty(str)
    if type(str) ~= "string" then
        error("is_empty: expected string, got " .. type(str))
    end
    return m.trim(str) == ""
end

--- Converts string to lowercase.
--- @param str string The string to convert
--- @return string Lowercase string
function m.lowercase(str)
    if type(str) ~= "string" then
        error("lowercase: expected string, got " .. type(str))
    end
    return str:lower()
end

--- Converts string to uppercase.
--- @param str string The string to convert
--- @return string Uppercase string
function m.uppercase(str)
    if type(str) ~= "string" then
        error("uppercase: expected string, got " .. type(str))
    end
    return str:upper()
end

--- Counts occurrences of substring in string.
--- @param str string The string to search in
--- @param substring string The substring to count
--- @return number Number of occurrences
function m.count(str, substring)
    if type(str) ~= "string" or type(substring) ~= "string" then
        error("count: expected strings")
    end
    if substring == "" then
        return 0
    end
    local _, count = str:gsub(substring, "")
    return count
end

--- Pads string to length with character (left side).
--- @param str string The string to pad
--- @param length number Target length
--- @param char string Character to pad with (default: space)
--- @return string Padded string
function m.pad_left(str, length, char)
    if type(str) ~= "string" or type(length) ~= "number" then
        error("pad_left: expected string and number")
    end
    char = char or " "
    if #char ~= 1 then
        error("pad_left: padding character must be single character")
    end
    return string.rep(char, math.max(0, length - #str)) .. str
end

--- Pads string to length with character (right side).
--- @param str string The string to pad
--- @param length number Target length
--- @param char string Character to pad with (default: space)
--- @return string Padded string
function m.pad_right(str, length, char)
    if type(str) ~= "string" or type(length) ~= "number" then
        error("pad_right: expected string and number")
    end
    char = char or " "
    if #char ~= 1 then
        error("pad_right: padding character must be single character")
    end
    return str .. string.rep(char, math.max(0, length - #str))
end

--- Checks if string contains substring.
--- @param str string The string to search in
--- @param substring string The substring to find
--- @return boolean True if substring found
function m.contains(str, substring)
    if type(str) ~= "string" or type(substring) ~= "string" then
        error("contains: expected strings")
    end
    return str:find(substring, 1, true) ~= nil
end

--- Extracts substring between two delimiters.
--- @param str string The string to search in
--- @param start_delim string Starting delimiter
--- @param end_delim string Ending delimiter
--- @return string|nil Extracted substring or nil if not found
function m.between(str, start_delim, end_delim)
    if type(str) ~= "string" or type(start_delim) ~= "string" or type(end_delim) ~= "string" then
        error("between: expected strings")
    end
    
    local start_pos = str:find(start_delim, 1, true)
    if not start_pos then
        return nil
    end
    
    local end_pos = str:find(end_delim, start_pos + #start_delim, true)
    if not end_pos then
        return nil
    end
    
    return str:sub(start_pos + #start_delim, end_pos - 1)
end

return m