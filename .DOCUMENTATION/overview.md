# GRAFT - General Runtime Abstraction & Framework Toolkit

**[Documentation](https://boii.dev)**

---

## What Is GRAFT?

GRAFT (General Runtime Abstraction & Framework Toolkit) is a **modular collection of framework-aware and standalone utilities** for script development.

Use it **as a resource**, **embed it in your scripts**, or **cherry-pick individual files**.

No forced dependencies. No commitment to the entire toolkit.

---

## Why GRAFT Exists

GRAFT is my personal script development kit.

I've used it for over two years to build nearly everything I ship *(originally boii_utils)* - from small standalone scripts to full production systems.
It's been rewritten, trimmed, reorganized, and stress-tested in real servers, not demos.

The API is intentionally minimal.
Not because features are missing, but because it only covers what you actually need to ship production-ready scripts:

* Common framework differences handled once
* Reusable patterns without opinionated bloat
* Utilities that solve real problems, not edge cases

If something isn't here, it's because you probably don't need it.

GRAFT isn't meant to impress.
It's meant to work - quietly, reliably, and without getting in your way.

---

## How to Use GRAFT

### Option A - Standalone Resource

Drop `graft` into your resources folder, `ensure graft` in `server.cfg`, then use exports:

```lua
local commands = exports.graft:require("graft.fivem.modules.commands")
local framework = exports.graft:require("graft.fivem.bridges.framework")
local maths = exports.graft:require("graft.standalone.modules.maths")
```

Works well for a **shared utility base** across multiple resources.

---

### Option B - Embedded Library

Copy the `graft` folder into your resource (e.g., `myresource/lib/graft/`), update your `fxmanifest.lua`:

```lua
shared_scripts {
    "lib/graft/standalone/**/*.lua",
    "lib/graft/cfx_require.lua",
    "lib/graft/fivem/**/*.lua"
}
```

Then use directly:

```lua
local fw = require("lib.graft.fivem.bridges.framework")
local inventory = require("lib.graft.fivem.bridges.inventory")
local maths = require("lib.graft.standalone.modules.maths")
```

Ideal for:
* Standalone scripts
* Releases that shouldn't require extra resources
* Developers who prefer explicit control

---

### Option C - Individual Files (Recommended)

Every file is self-contained. Copy only what you need:

```
lib/
├─ cfx_require.lua                           # Drop-in require() helper
├─ fivem/
│  └─ bridges/
│     └─ framework.lua                       # Framework bridge
└─ standalone/
   └─ modules/
      └─ maths.lua                           # Standalone math utilities
```

No resource dependency. No bloat.

---

## What's Included

### FiveM Bridges (`graft/fivem/bridges/`)
* **framework.lua** - Unified API across ESX, QBCore, QBox, NDCore, and more
* **inventory.lua** - Currently only covers ox_inventory, will add more asap
* **notify.lua** - Consistent notify API
* **drawtext_ui.lua** - Framework-aware text display

### FiveM Modules (`graft/fivem/modules/`)
* **animations.lua** - Animation helpers
* **callbacks.lua** - Client/server callback system
* **commands.lua** - Simple ace perms command registration
* **cooldowns.lua** - Global or per player cooldown management
* **entities.lua** - Entity helper functions
* **environment.lua** - Weather, time, and world state
* **keys.lua** - Keybind management
* **requests.lua** - Asset streaming helpers
* **timestamps.lua** - Time utilities
* **vehicles.lua** - Vehicle-specific helpers

### FiveM Scripts (`graft/fivem/scripts/`)
* **zone_creator.lua** - Simple zone creation tool: https://github.com/CaseIRL/fivem_zone_creator

### Standalone Modules (`graft/standalone/modules/`)
* **maths.lua** - Math utilities
* **strings.lua** - String manipulation
* **tables.lua** - Table helpers

These work anywhere - no FiveM dependency.

### RedM Support (`graft/redm/`)
Placeholder structure ready for RedM-specific implementations.

---

## Project Structure

```
graft/
├─ cfx_require.lua       # Drop-in require() helper
├─ fivem/
│  ├─ bridges/           # Framework & system bridges
│  ├─ modules/           # FiveM utility modules
│  └─ scripts/           # Standalone scripts (zone creator, etc)
├─ redm/                 # RedM support (placeholder)
└─ standalone/
   └─ modules/           # Framework-free utilities
```

All modules are:
* Shared-runtime safe
* Client/server aware where applicable
* Designed to be copied or reused freely

---

## Why Use GRAFT?

* Use as **resource**, **embedded library**, or **individual files**
* No forced dependencies
* Framework-agnostic APIs
* Consistent structure and naming
* Built for real scripts, not demos

GRAFT exists to **remove friction**, not introduce another layer of it.

---

## Support

Need help? Found a bug? Regretting a refactor?

👉 [Discord](https://discord.gg/MUckUyS5Kq)

**Support Hours:** Mon–Fri, 10AM–10PM GMT  
Outside hours? Messages are still logged.

---

## Warning

Using GRAFT may result in:
* Cleaner projects
* Less duplicated logic
* Faster development
* Mild discomfort from increased productivity

Use responsibly.