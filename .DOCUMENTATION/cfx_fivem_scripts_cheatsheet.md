# FiveM Script Cheatsheet

*One page. Every script. Total reference.*

## Zones

*Self-contained convex polygon zone creation and state tracking.*

### Server Commands

*Requires ACE permission: `zone_creator.use*`

```lua
/zones:create       -- Starts the Noclip Zone Creator mode
/zones:debug        -- Toggles the global on-screen debug overlay
```

### Client Events

*Listen for these events in your own scripts.*

```lua
local RESOURCE_NAME = GetCurrentResourceName()      -- Ensures events are listening on your current resource if copied internally
```

```lua
AddEventHandler(RESOURCE_NAME .. ":zone_created", function(data) ... end)       -- Triggered when a new zone is saved; returns data = { name, zone = {vector3s}, player = {source, name} }
AddEventHandler(RESOURCE_NAME .. ":entered_zone", function(name) ... end)       -- Triggered player enters a zone
AddEventHandler(RESOURCE_NAME .. ":inside_zone", function(name) ... end)        -- Triggered when player is inside zone
AddEventHandler(RESOURCE_NAME .. ":left_zone", function(name) ... end)          -- Triggered when player leaves zone
```