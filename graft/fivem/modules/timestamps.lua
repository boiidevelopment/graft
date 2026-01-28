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

--- @module core.lib.timestamps
--- @description Time and date utilities with server/client compatibility.

--- @section Constants

local IS_SERVER = IsDuplicityVersion()

--- @section Module

local m = {}

--- @section Shared

--- Gets current UNIX timestamp (seconds).
--- @return number: UNIX timestamp
function m.now()
    if IS_SERVER then
        return os.time()
    end
    return GetCloudTimeAsInt()
end

--- Gets current UNIX timestamp (milliseconds).
--- @return number: UNIX timestamp in milliseconds
function m.now_ms()
    if IS_SERVER then
        return os.time() * 1000
    end
    return GetCloudTimeAsInt() * 1000
end

--- Gets current formatted date/time.
--- @return string: Formatted time (YYYY-MM-DD HH:MM:SS)
function m.now_formatted()
    if IS_SERVER then
        return os.date("%Y-%m-%d %H:%M:%S")
    end
    
    if GetLocalTime then
        local y, m, d, h, min, s = GetLocalTime()
        return string.format("%04d-%02d-%02d %02d:%02d:%02d", y, m, d, h, min, s)
    end
    
    return "0000-00-00 00:00:00"
end

--- Converts UNIX timestamp to date/time components.
--- @param ts number: UNIX timestamp (default: current time)
--- @return table: {date, time, both}
function m.convert(ts)
    ts = ts or m.now()
    
    if IS_SERVER then
        return {
            date = os.date("%Y-%m-%d", ts),
            time = os.date("%H:%M:%S", ts),
            both = os.date("%Y-%m-%d %H:%M:%S", ts)
        }
    end

    local current = m.now()
    local offset = ts - current
    return {
        date = "N/A",
        time = "N/A", 
        both = string.format("~%d seconds", offset)
    }
end

--- Adds seconds to timestamp.
--- @param ts number: UNIX timestamp
--- @param seconds number: Seconds to add
--- @return number: New timestamp
function m.add_seconds(ts, seconds)
    return ts + seconds
end

--- Adds minutes to timestamp.
--- @param ts number: UNIX timestamp
--- @param minutes number: Minutes to add
--- @return number: New timestamp
function m.add_minutes(ts, minutes)
    return ts + (minutes * 60)
end

--- Adds hours to timestamp.
--- @param ts number: UNIX timestamp
--- @param hours number: Hours to add
--- @return number: New timestamp
function m.add_hours(ts, hours)
    return ts + (hours * 3600)
end

--- Checks if timestamp is in the past.
--- @param ts number: UNIX timestamp
--- @return boolean: True if past
function m.is_past(ts)
    return ts < m.now()
end

--- Checks if timestamp is in the future.
--- @param ts number: UNIX timestamp
--- @return boolean: True if future
function m.is_future(ts)
    return ts > m.now()
end

--- Formats duration in seconds to human readable.
--- @param seconds number: Duration in seconds
--- @return string: Human readable (e.g., "2h 30m 15s")
function m.format_duration(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    
    local parts = {}
    if hours > 0 then table.insert(parts, hours .. "h") end
    if minutes > 0 then table.insert(parts, minutes .. "m") end
    if secs > 0 or #parts == 0 then table.insert(parts, secs .. "s") end
    
    return table.concat(parts, " ")
end

--- @section Server

if IS_SERVER then

    --- Formats custom timestamp.
    --- @param ts number: UNIX timestamp
    --- @param format string: Format string (os.date patterns)
    --- @return string: Formatted timestamp
    function m.format(ts, format)
        if not IS_SERVER then
            print("[timestamps] format() only works server-side")
            return "N/A"
        end
        
        ts = ts or os.time()
        return os.date(format, ts)
    end

    --- Parses date string to timestamp.
    --- @param date_str string: Date "YYYY-MM-DD"
    --- @param time_str string?: Time "HH:MM:SS" (default: "00:00:00")
    --- @return number|nil: UNIX timestamp or nil if client
    function m.parse(date_str, time_str)
        if not IS_SERVER then
            print("[timestamps] parse() only works server-side")
            return nil
        end
        
        time_str = time_str or "00:00:00"
        local y, m, d = date_str:match("(%d+)%-(%d+)%-(%d+)")
        local h, min, s = time_str:match("(%d+):(%d+):(%d+)")
        
        return os.time({
            year = tonumber(y),
            month = tonumber(m),
            day = tonumber(d),
            hour = tonumber(h) or 0,
            min = tonumber(min) or 0,
            sec = tonumber(s) or 0
        })
    end

    --- Adds days to a date string.
    --- @param date_str string: Date "YYYY-MM-DD"
    --- @param days number: Days to add
    --- @return string|nil: New date or nil if client
    function m.add_days(date_str, days)
        if not IS_SERVER then
            print("[timestamps] add_days() only works server-side")
            return nil
        end
        
        local y, m, d = date_str:match("(%d+)%-(%d+)%-(%d+)")
        local time = os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d) })
        local new_time = time + (days * 24 * 60 * 60)
        return os.date("%Y-%m-%d", new_time)
    end

    --- Calculates date difference.
    --- @param start_date string: Start "YYYY-MM-DD"
    --- @param end_date string: End "YYYY-MM-DD"
    --- @return number|nil: Days difference or nil if client
    function m.date_diff(start_date, end_date)
        if not IS_SERVER then
            print("[timestamps] date_diff() only works server-side")
            return nil
        end
        
        local sy, sm, sd = start_date:match("(%d+)%-(%d+)%-(%d+)")
        local ey, em, ed = end_date:match("(%d+)%-(%d+)%-(%d+)")
        local t1 = os.time({ year = tonumber(sy), month = tonumber(sm), day = tonumber(sd) })
        local t2 = os.time({ year = tonumber(ey), month = tonumber(em), day = tonumber(ed) })
        return math.floor(math.abs(os.difftime(t2, t1)) / 86400)
    end

end

return m