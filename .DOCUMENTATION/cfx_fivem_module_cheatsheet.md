# FiveM Module Cheatsheet

*One page. Every module. Total reference.*

## Animations

*Handles dictionary loading, playback, and automatic prop attachment, refer to `Animation Options` for full details*

### Client Functions

```lua
animations.request(dict, timeout?)              -- Requests and waits for anim dict
animations.play(ped, options, callback?)        -- Plays anim with props, freezing, and duration logic
```

---

## Callbacks

*Standalone event-based request/response system between client and server.*

### Server Functions

```lua
callbacks.register(name, function(source, data, cb) cb(result) end)     -- Registers a server-side callback

```

### Client Functions

```lua
callbacks.trigger(name, data, function(result) end)     -- Triggers server callback from client
```

---

## Commands

*ACE permission-based command registration with chat autocomplete support.*

### Server Functions

```lua
commands.register({name = "cmd", ace = "perm", help = "Desc", params = {{name = "id", help = "text"}}, handler = function(src, args, raw) end})     -- Registers a command
```

### Client Functions

```lua
commands.get_suggestions()      -- Syncs registered command suggestions to the chat UI
```

---

## Cooldowns

*Server-side tracking for player and global action timers.*

### Server Functions

```lua
cooldowns.add(source, type, duration, is_global)        -- Adds a cooldown (duration in seconds)
cooldowns.check(source, type, is_global)                -- Returns true if cooldown is active
cooldowns.clear(source, type, is_global)                -- Forcefully removes a specific cooldown
cooldowns.clear_all()                                   -- Wipes all expired cooldowns from memory
cooldowns.clear_resource(resource_name)                 -- Clears all cooldowns registered by a specific resource
```

---

## Entities

*Search utilities for peds, vehicles, objects, and players.*

### Shared Functions

```lua
entities.get_distance_between_entities(e1, e2)      -- Returns numeric distance between two handles
```

### Server Functions

```lua
entities.get_in_radius(coords, dist, type, models?)     -- Returns table of handles (type: 1=Ped, 2=Veh, 3=Obj)
entities.get_nearby_peds(coords, dist)                  -- Returns table of ped handles
entities.get_nearby_vehicles(coords, dist)              -- Returns table of vehicle handles
entities.get_nearby_objects(coords, dist, models?)      -- Returns table of object handles
entities.get_closest(coords, entity_list)               -- Returns closest handle from a custom list
entities.get_closest_ped(coords, dist)                  -- Returns closest ped handle
entities.get_closest_vehicle(coords, dist)              -- Returns closest vehicle handle
entities.get_closest_object(coords, dist, models?)      -- Returns closest object handle
```

### Client Functions

```lua
entities.get_nearby_entities(pool, coords, dist, filter?)       -- Returns {entity, coords} table
entities.get_closest_entity(pool, coords, dist, filter?)        -- Returns entity handle, coords
entities.get_nearby_objects(coords, dist)                       -- Returns table of nearby objects
entities.get_nearby_peds(coords, dist)                          -- Returns peds (excludes players)
entities.get_nearby_players(coords, dist, include_self?)        -- Returns players only
entities.get_nearby_vehicles(coords, dist, include_cur?)        -- Returns vehicles
entities.get_closest_object(coords, dist)                       -- Returns closest object handle, coords
entities.get_closest_ped(coords, dist)                          -- Returns closest ped handle, coords
entities.get_closest_player(coords, dist, include_self?)        -- Returns closest player handle, coords
entities.get_closest_vehicle(coords, dist, include_cur?)        -- Returns closest vehicle handle, coords
entities.get_in_front_of_player(dist)                           -- Raycast to find entity in crosshair
entities.get_target_ped(dist)                                   -- Returns ped in front or closest
entities.get_target_entity()                                    -- Returns entity currently being aimed at
```

---

## Environment

*Utilities for weather, time, location, and environmental states.*

### Shared Functions

```lua
environment.get_cardinal_direction(player_ped)      -- Returns "N", "NE", "E", etc. based on heading
```

### Client Functions

```lua
environment.get_street_name(player_ped)     -- Returns "Street Name, Area"
environment.get_current_zone(entity)        -- Returns zone internal name (e.g., "AIRP")
environment.get_weather_name(hash)          -- Converts weather hash to string (e.g., "CLEAR")
environment.get_current()                   -- Returns current weather string
environment.get_time()                      -- Returns {hour, minute, formatted}
environment.get_date()                      -- Returns {day, month, year, formatted}
environment.get_sun_times(weather?)         -- Returns {sunrise, sunset} based on weather
environment.is_daytime()                    -- Returns true between 06:00 and 18:00
environment.is_nighttime()                  -- Returns true between 20:00 and 06:00
environment.is_midday()                     -- Returns true between 11:00 and 13:00
environment.get_season()                    -- Returns "Winter", "Spring", "Summer", "Autumn"
environment.get_altitude()                  -- Returns Z-coordinate of player
environment.get_distance_to_water()         -- Returns distance to nearest water or -1
environment.get_zone_scumminess()           -- Returns zone scum level (0-5)
environment.get_ground_material()           -- Returns material hash under player
environment.get_wind_direction()            -- Returns wind compass heading
environment.get_wind_speed()                -- Returns current wind speed
environment.get_rain_level()                -- Returns 0.0-1.0 rain intensity
environment.get_snow_level()                -- Returns 0.0-1.0 snow intensity
environment.get_all()                       -- Returns table of all environmental data
```

---

## Keys

*Key code mapping and utility functions for easy input handling.*

### Client Functions

```lua
keys.get_keys()             -- Returns the full table of key names and codes
keys.get_key("e")           -- Returns the code for a key name (e.g., 46)
keys.get_key_name(46)       -- Returns the string name for a key code (e.g., "e")
keys.key_exists("tab")      -- Returns true if the key name is in the mapping
keys.print_key_list()       -- Prints all available keys and codes to console
```

---

## Requests

*Wrapper functions for FiveM natives that handle loading wait-times and timeouts automatically.*

### Client Functions

```lua
requests.model(hash, timeout?)                  -- Wait for model (ped, vehicle, prop) to load
requests.interior(id, timeout?)                 -- Wait for interior (MLO) to be ready
requests.texture(dict, wait?, timeout?)         -- Load texture dictionary (Txd)
requests.collision(x, y, z, timeout?)           -- Ensure collision is loaded at coordinates
requests.anim(dict, timeout?)                   -- Load animation dictionary
requests.anim_set(set, timeout?)                -- Load animation set (walking styles)
requests.clip_set(clip, timeout?)               -- Load clip set
requests.audio_bank(name, timeout?)             -- Load script audio bank
requests.scaleform_movie(name, timeout?)        -- Load and return scaleform handle
requests.cutscene(name, timeout?)               -- Load cutscene data
requests.ipl(name, timeout?)                    -- Request and wait for IPL (Map changes)
```

---

## Timestamps

*Comprehensive time and date utilities with full cross-platform compatibility.*

### Shared Functions

```lua
timestamps.now()                    -- Returns current UNIX timestamp (seconds)
timestamps.now_ms()                 -- Returns current UNIX timestamp (milliseconds)
timestamps.now_formatted()          -- Returns "YYYY-MM-DD HH:MM:SS"
timestamps.convert(ts?)             -- Returns {date, time, both} table
timestamps.add_seconds(ts, sec)     -- Adds seconds to a timestamp
timestamps.add_minutes(ts, min)     -- Adds minutes to a timestamp
timestamps.add_hours(ts, hours)     -- Adds hours to a timestamp
timestamps.is_past(ts)              -- Returns true if timestamp has passed
timestamps.is_future(ts)            -- Returns true if timestamp is in the future
timestamps.format_duration(sec)     -- Returns human readable (e.g., "2h 30m 15s")

```

### Server-Only Functions

```lua
timestamps.format(ts, pattern)          -- Formats timestamp using os.date patterns
timestamps.parse(date, time?)           -- Converts "YYYY-MM-DD" string to UNIX timestamp
timestamps.add_days(date, days)         -- Adds days to a "YYYY-MM-DD" string
timestamps.date_diff(start, end)        -- Returns number of days between two date strings
```

---

# FiveM API Cheatsheet

*One page. Every module. Total reference.*

---

## Vehicles

*Vehicle data, property management, and spawning utilities.*

### Shared Functions

```lua
vehicles.get_plate(vehicle)                 -- Returns trimmed license plate text
vehicles.get_plate_index(vehicle)           -- Returns plate style index (0-5)
vehicles.set_plate(vehicle, text)           -- Sets plate text (max 8 chars)
vehicles.set_plate_index(vehicle, i)        -- Sets plate style (0-5)
```

### Server Functions

```lua
vehicles.get_nearby(coords, radius, models?)        -- Array of vehicles in range
vehicles.get_closest(coords, radius)                -- Closest vehicle entity handle
vehicles.get_info(vehicle?, options?)               -- Table of basic entity data
vehicles.spawn(model, options)                      -- Server-side spawn (returns NetID)
vehicles.delete(net_id)                             -- Deletes vehicle by Network ID
vehicles.clear()                                    -- Deletes all tracked vehicles
```

### Client Functions

```lua
vehicles.get_model(vehicle)                 -- Returns lowercase model name
vehicles.get_class(vehicle)                 -- Returns class string (e.g., "super")
vehicles.get_class_stats(vehicle)           -- Returns max speed, acceleration, etc.
vehicles.get_properties(vehicle)            -- Get ALL mods, colors, and health states
vehicles.set_properties(vehicle, tbl)       -- Apply a properties table to a vehicle
vehicles.get_info(vehicle?)                 -- Detailed client-side vehicle info
vehicles.spawn(data)                        -- Advanced spawn with mods, health, and handling
```