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

--- @module environment
--- @description Weather, time, season, and environmental utilities (client-side only).

--- @section Constants

local IS_SERVER = IsDuplicityVersion()

--- @section Module

local m = {}

--- @section Shared

--- Gets a player"s cardinal direction based on their current heading.
--- @param player number: The player ped use "PlayerPedId()" on client and "GetPlayerPed(source)" on server.
--- @return string: The cardinal direction the player is facing.
function m.get_cardinal_direction(player_ped)
    if not player_ped then return false end
    
    local heading = GetEntityHeading(player_ped)
    if not heading then return false end

    local directions = { "N", "NE", "E", "SE", "S", "SW", "W", "NW" }
    local index = math.floor(((heading + 22.5) % 360) / 45) + 1

    return directions[index]
end

--- @section Client

if not IS_SERVER then

    --- Retrieves the street name and area where a player is currently located.
    --- @param player_ped number: The player entity.
    --- @return string: The street and area name the player is on.
    function m.get_street_name(player_ped)
        local player_coords = GetEntityCoords(player_ped)
        local street_hash, _ = GetStreetNameAtCoord(player_coords.x, player_coords.y, player_coords.z)
        local street_name = GetStreetNameFromHashKey(street_hash)
        local area_name = GetLabelText(GetNameOfZone(player_coords.x, player_coords.y, player_coords.z))

        return table.concat({ street_name, area_name }, street_name and area_name and ", " or ""):match("%S") or "Unknown"
    end

    --- Retrieves the name of the current zone a entity is in.
    --- @param entity number: The entity.
    --- @return string: The region name the entity is in.
    function m.get_current_zone(entity)
        local e = GetEntityCoords(entity)
        return GetNameOfZone(e.x, e.y, e.z)
    end

    --- Get weather name from hash.
    --- @param hash number: Weather type hash
    --- @return string: Weather name
    function m.get_weather_name(hash)
        local names = {
            [GetHashKey("EXTRASUNNY")] = "EXTRASUNNY",
            [GetHashKey("CLEAR")] = "CLEAR",
            [GetHashKey("CLOUDS")] = "CLOUDS",
            [GetHashKey("OVERCAST")] = "OVERCAST",
            [GetHashKey("RAIN")] = "RAIN",
            [GetHashKey("THUNDER")] = "THUNDER",
            [GetHashKey("CLEARING")] = "CLEARING",
            [GetHashKey("NEUTRAL")] = "NEUTRAL",
            [GetHashKey("SNOW")] = "SNOW",
            [GetHashKey("BLIZZARD")] = "BLIZZARD",
            [GetHashKey("SNOWLIGHT")] = "SNOWLIGHT",
            [GetHashKey("XMAS")] = "XMAS",
            [GetHashKey("HALLOWEEN")] = "HALLOWEEN",
        }
        return names[hash] or "UNKNOWN"
    end

    --- Get current m.
    --- @return string: Current weather name
    function m.get_current()
        return m.get_weather_name(GetPrevWeatherTypeHashName())
    end

    --- Get game time.
    --- @return table: {hour, minute, formatted}
    function m.get_time()
        local hour, minute = GetClockHours(), GetClockMinutes()
        return {
            hour = hour,
            minute = minute,
            formatted = string.format("%02d:%02d", hour, minute)
        }
    end

    --- Get game date.
    --- @return table: {day, month, year, formatted}
    function m.get_date()
        local day, month, year = GetClockDayOfMonth(), GetClockMonth(), GetClockYear()
        return {
            day = day,
            month = month,
            year = year,
            formatted = string.format("%02d/%02d/%04d", day, month, year)
        }
    end

    --- Get sunrise/sunset times based on m.
    --- @param weather_type string?: Weather name (default: current)
    --- @return table: {sunrise, sunset}
    function m.get_sun_times(weather_type)
        weather_type = weather_type or m.get_current()
        
        local times = {
            CLEAR = { sunrise = "06:00", sunset = "18:00" },
            CLOUDS = { sunrise = "06:15", sunset = "17:45" },
            OVERCAST = { sunrise = "06:30", sunset = "17:30" },
            RAIN = { sunrise = "07:00", sunset = "17:00" },
            THUNDER = { sunrise = "07:00", sunset = "17:00" },
            SNOW = { sunrise = "08:00", sunset = "16:00" },
            BLIZZARD = { sunrise = "09:00", sunset = "15:00" },
        }
        
        return times[weather_type] or { sunrise = "06:00", sunset = "18:00" }
    end

    --- Check if daytime.
    --- @return boolean: True if daytime (6:00-18:00)
    function m.is_daytime()
        local hour = GetClockHours()
        return hour >= 6 and hour < 18
    end

    --- Check if nighttime.
    --- @return boolean: True if nighttime (20:00-6:00)
    function m.is_nighttime()
        local hour = GetClockHours()
        return hour >= 20 or hour < 6
    end

    --- Check if midday.
    --- @return boolean: True if midday (11:00-13:00)
    function m.is_midday()
        local hour = GetClockHours()
        return hour >= 11 and hour <= 13
    end

    --- Get current season.
    --- @return string: Season name
    function m.get_season()
        local month = GetClockMonth()
        local seasons = {
            [0] = "Winter", [1] = "Winter", [2] = "Winter",
            [3] = "Spring", [4] = "Spring", [5] = "Spring",
            [6] = "Summer", [7] = "Summer", [8] = "Summer",
            [9] = "Autumn", [10] = "Autumn", [11] = "Autumn"
        }
        return seasons[month] or "Unknown"
    end

    --- Get player altitude.
    --- @return number: Altitude in meters
    function m.get_altitude()
        return GetEntityCoords(PlayerPedId()).z
    end

    --- Get distance to nearest water.
    --- @return number: Distance or -1 if none found
    function m.get_distance_to_water()
        local coords = GetEntityCoords(PlayerPedId())
        local has_water, water_height = TestVerticalProbeAgainstAllWater(coords.x, coords.y, coords.z, 0)
        
        if not has_water then return -1 end
        
        return math.abs(coords.z - water_height)
    end

    --- Check if the player is near water.
    --- @param player number The player entity ID.
    --- @return boolean Whether the player is near water.
    function m.is_near_water(player)
        if IsPedSwimming(player) then return false end
        local bone_coords = GetPedBoneCoords(player, 31086, 0.0, 0.0, 0.0)
        local forward_coords = GetOffsetFromEntityInWorldCoords(player, 0.0, 5.0, 0.0)
        local is_near = TestProbeAgainstWater(bone_coords.x, bone_coords.y, bone_coords.z, forward_coords.x, forward_coords.y, forward_coords.z)
        if not is_near then
            local distance_to_water = m.get_distance_to_water()
            if distance_to_water > 0 and distance_to_water <= 5.0 then
                return true
            end
        end
        return is_near
    end

    --- Check if entity is in water, optionally excluding swimming.
    --- @param entity number: The entity to check.
    --- @param allow_swimming boolean|nil: If false, returns false when swimming (default: false).
    --- @return boolean
    function m.is_in_water(entity, allow_swimming)
        if not IsEntityInWater(entity) then return false end
        if not allow_swimming and IsPedSwimming(entity) then return false end
        return true
    end

    --- Get zone scumminess level.
    --- @return number: Scumminess (0-5) or -1 if unknown
    function m.get_zone_scumminess()
        local coords = GetEntityCoords(PlayerPedId())
        local zone = GetZoneAtCoords(coords.x, coords.y, coords.z)
        return zone and GetZoneScumminess(zone) or -1
    end

    --- Get ground material at player position.
    --- @return number: Material hash
    function m.get_ground_material()
        local coords = GetEntityCoords(PlayerPedId())
        local shape = StartShapeTestCapsule(
            coords.x, coords.y, coords.z + 1.0,
            coords.x, coords.y, coords.z - 2.0,
            2, 1, PlayerPedId(), 7
        )
        local _, _, _, _, material = GetShapeTestResultEx(shape)
        return material
    end

    --- Get wind direction as compass heading.
    --- @return string: Compass direction (N, NE, E, SE, S, SW, W, NW)
    function m.get_wind_direction()
        local wind = GetWindDirection()
        local angle = math.deg(math.atan2(wind.y, wind.x)) + 180
        local directions = { "N", "NE", "E", "SE", "S", "SW", "W", "NW" }
        return directions[math.floor(((angle + 22.5) % 360) / 45) + 1] or "Unknown"
    end

    --- Get wind speed.
    --- @return number: Wind speed
    function m.get_wind_speed()
        return GetWindSpeed()
    end

    --- Get rain level.
    --- @return number: Rain level (0.0-1.0)
    function m.get_rain_level()
        return GetRainLevel()
    end

    --- Get snow level.
    --- @return number: Snow level (0.0-1.0)
    function m.get_snow_level()
        return GetSnowLevel()
    end

    --- Get comprehensive weather/environment data.
    --- @return table: All environment details
    function m.get_all()
        return {
            weather = m.get_current(),
            time = m.get_time(),
            date = m.get_date(),
            season = m.get_season(),
            sun_times = m.get_sun_times(),
            is_daytime = m.is_daytime(),
            altitude = m.get_altitude(),
            distance_to_water = m.get_distance_to_water(),
            zone_scumminess = m.get_zone_scumminess(),
            ground_material = m.get_ground_material(),
            rain_level = m.get_rain_level(),
            snow_level = m.get_snow_level(),
            wind_speed = m.get_wind_speed(),
            wind_direction = m.get_wind_direction()
        }
    end
end

return m