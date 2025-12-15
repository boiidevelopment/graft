--[[ 
    This file is part of GRAFT (General Runtime Abstraction & Framework Toolkit) and is licensed under the MIT License.
    See the LICENSE file in the root directory for full terms.

    © 2025 Case @ Playing In Traffic

    Support honest development — retain this credit. Don't be that guy...
]]

--- @module environment
--- Handles a bunch of custom fuctions relating to the "environment"; weather, water etc. 

local environment = {}

--- Retrieves the player's altitude above sea level.
--- @param source number: Player source ID (server-side only, optional on client).
--- @return number: Altitude value.
function environment.get_altitude(source)
    local player_ped = core.is_server and GetPlayerPed(source) or PlayerPedId()
    return player_ped and GetEntityCoords(player_ped).z or 0
end


if not graft.is_server then

    --- Retrieves the human-readable name of the weather from its hash.
    --- @param hash number: The hash key of the weather type.
    --- @return string: The human-readable name of the weather.
    function environment.get_weather_name(hash)
        local weather_names = {
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

        return weather_names[hash] or "UNKNOWN"
    end

    --- Retrieves the current game time and its formatted version.
    --- @return table: Contains raw time data and formatted time string.
    function environment.get_game_time()
        local hour, minute = GetClockHours(), GetClockMinutes()

        return {
            time = {hour = hour, minute = minute},
            formatted = string.format("%02d:%02d", hour, minute)
        }
    end

    --- Retrieves the game"s current date and its formatted version.
    --- @return table: Contains raw date data and formatted date string.
    function environment.get_game_date()
        local day, month, year = GetClockDayOfMonth(), GetClockMonth(), GetClockYear()

        return {
            date = {day = day, month = month, year = year},
            formatted = string.format("%02d/%02d/%04d", day, month, year)
        }
    end

    --- Retrieves sunrise and sunset times based on weather.
    --- @param weather string: The current weather type.
    --- @return table: Sunrise and sunset times.
    function environment.get_sunrise_sunset_times(weather)
        local times = {
            CLEAR = { sunrise = "06:00", sunset = "18:00" },
            CLOUDS = { sunrise = "06:15", sunset = "17:45" },
            OVERCAST = { sunrise = "06:30", sunset = "17:30" },
            RAIN = { sunrise = "07:00", sunset = "17:00" },
            THUNDER = { sunrise = "07:00", sunset = "17:00" },
            SNOW = { sunrise = "08:00", sunset = "16:00" },
            BLIZZARD = { sunrise = "09:00", sunset = "15:00" },
        }

        return times[weather] or {sunrise = "06:00", sunset = "18:00"}
    end

    --- Checks if the current time is daytime.
    --- @return boolean: True if daytime, false otherwise.
    function environment.is_daytime()
        return GetClockHours() >= 6 and GetClockHours() < 18
    end

    --- Checks if the current time is nighttime.
    --- @return boolean: True if nighttime, false otherwise.
    function environment.is_nighttime()
        local hour = GetClockHours()
        return hour >= 20 or hour < 6
    end

    --- Checks if the current time is midday (around noon).
    --- @return boolean: True if midday, false otherwise.
    function environment.is_midday()
        local hour = GetClockHours()
        return hour >= 11 and hour <= 13
    end

    --- Retrieves the current season.
    --- @return string: The current season.
    function environment.get_current_season()
        local month = GetClockMonth()

        local seasons = {
            [0] = "Winter", 
            [1] = "Winter", 
            [2] = "Winter",
            [3] = "Spring", 
            [4] = "Spring", 
            [5] = "Spring",
            [6] = "Summer", 
            [7] = "Summer", 
            [8] = "Summer",
            [9] = "Autumn", 
            [10] = "Autumn", 
            [11] = "Autumn"
        }

        return seasons[month] or "Unknown"
    end

    --- Get the distance from the player to the nearest water body.
    --- @return number: The distance to the nearest water body.
    function environment.get_distance_to_water()
        local player_coords = GetEntityCoords(PlayerPedId())
        local water_test_result, water_height = TestVerticalProbeAgainstAllWater(player_coords.x, player_coords.y, player_coords.z, 0)

        return water_test_result and #(player_coords - vector3(player_coords.x, player_coords.y, water_height)) or -1
    end

    --- Gets the scumminess level of the player"s current zone.
    --- @return integer: The scumminess level (0-5) or -1 if unknown.
    function environment.get_zone_scumminess()
        local player_coords = GetEntityCoords(PlayerPedId())
        local zone_id = GetZoneAtCoords(player_coords.x, player_coords.y, player_coords.z)

        return zone_id and GetZoneScumminess(zone_id) or -1
    end

    --- Retrieves the ground material type at the player"s position.
    --- @return material_hash: Ground type hash
    function environment.get_ground_material()
        local coords = GetEntityCoords(PlayerPedId())
        local shape_test = StartShapeTestCapsule(coords.x, coords.y, coords.z + 1.0, coords.x, coords.y, coords.z - 2.0, 2, 1, PlayerPedId(), 7)
        local _, _, _, _, material_hash = GetShapeTestResultEx(shape_test)

        return material_hash
    end

    --- Retrieves the wind direction as a readable compass value.
    --- @return string: Compass direction (N, NE, E, SE, S, SW, W, NW)
    function environment.get_wind_direction()
        local wind_vector = GetWindDirection()
        local angle = math.deg(math.atan2(wind_vector.y, wind_vector.x)) + 180
        local directions = { "N", "NE", "E", "SE", "S", "SW", "W", "NW" }

        return directions[math.floor(((angle + 22.5) % 360) / 45) + 1] or "Unknown"
    end

    --- Retrieves environment details.
    --- @return table: Detailed environment information.
    function environment.get_environment_details()
        return {
            weather = get_weather_name(GetPrevWeatherTypeHashName()),
            time = get_game_time(),
            date = get_game_date(),
            season = get_current_season(),
            sunrise_sunset = get_sunrise_sunset_times(get_weather_name(GetPrevWeatherTypeHashName())),
            is_daytime = is_daytime(),
            distance_to_water = get_distance_to_water(),
            scumminess = get_zone_scumminess(),
            ground_material = get_ground_material(),
            rain_level = GetRainLevel(),
            wind_speed = GetWindSpeed(),
            wind_direction = get_wind_direction(),
            snow_level = GetSnowLevel(),
            altitude = get_altitude()
        }
    end

end

return environment