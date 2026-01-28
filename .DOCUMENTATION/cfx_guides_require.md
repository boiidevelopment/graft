# Guide: Requiring Modules

GRAFT is designed to be flexible. 
Whether you want to use it as a global library or bake it directly into your own scripts to keep them dependency-free, the `require` system is the engine that makes it work.

---

## The `require` Logic

GRAFT includes a **Safe Require** function. 
It mimics standard Lua behavior by loading files, caching them to prevent memory bloat, and returning them as usable tables.
It can be used on both cfx platforms `FiveM` & `RedM`.

### 1. External Usage (Resource Mode)

If you have GRAFT running as a standalone resource, you can access any module from another script using the export.

```lua
local vehicles = exports.graft:require("cfx.fivem.modules.vehicles")        -- Import the module
local plate = vehicles.get_plate(veh)                                       -- Now use it as normal
```

### 2. Internal Usage (Standalone Mode)

If you want your script to be **100% standalone**, copy the `require.lua` file and the specific modules you want into your own resource folder.

**Your `fxmanifest.lua`:**

```lua
shared_scripts {
    'require.lua',      -- Load this first
}
```

**Your `script.lua`:**

```lua
local framework = require("framework")                          -- Import the module from your file path
local notify = require("my.special.path.to.notifications")      -- Import the module from your file path
local player = framework.get_player(source)                     -- Now use it as normal
```