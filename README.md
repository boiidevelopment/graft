![pit_graft_thumb](https://github.com/user-attachments/assets/83551524-8d00-4f24-9590-bb0d9d38fd36)

> **CURRENT PIT RESOURCES USE THE LATEST RELEASE VERSION PLEASE DOWNLOAD THE LATEST RELEASE AND NOT MAIN BRANCH!**
> **MAIN BRANCH IS NOT BACKWARD COMPATIBLE IT IS BEING TWEAKED STILL - LATEST RELEASE: [V1.1.1](https://github.com/playingintraffic/graft/releases/tag/v1.1.1)**

# GRAFT - General Runtime Abstraction & Framework Toolkit

📚 **Docs:** [https://playingintraffic.site/docs/graft](https://playingintraffic.site/docs/graft)
💬 **Support:** [https://discord.gg/MUckUyS5Kq](https://discord.gg/MUckUyS5Kq)

---

## What Is GRAFT?

> **Normally:** General Runtime Abstraction & Framework Toolkit
> **In practice:** A practical utility toolkit for FiveM that removes boilerplate and friction
> **When it breaks:** Goddamn Rage-Angering Frustrating Tool

GRAFT is a **modular collection of framework-aware and standalone utilities** for FiveM development.

It can be used **as a normal resource** *or* **file-by-file**, depending on how you prefer to structure your projects.

There are **no forced dependencies** and no requirement to commit to the entire toolkit.

---

## Why GRAFT Exists

GRAFT is, first and foremost, my personal script development kit.

I've used it for over two years to build nearly everything I ship from small standalone scripts to full production systems.
It's been rewritten, trimmed, reorganized, and stress-tested in real servers, not demos.

The API is intentionally minimal.
Not because features are missing but because it only covers what you actually need to ship production-ready scripts:

Common framework differences handled once
Reusable patterns without opinionated bloat
Utilities that solve real problems, not edge cases

If something isn't here, it's because you probably dont "need" it.

GRAFT isn't meant to impress.
It's meant to work, quietly, reliably, and without getting in your way

---

## How GRAFT Is Meant to Be Used

### Option A - Use It as a Resource (Traditional)

* Drop `graft` into your resources folder
* `ensure graft` in your `server.cfg`
* Use the provided modules internally or via your own require system or through grafts export

```lua
local commands = exports.graft:require("cfx.fivem.modules.commands")
```

This works well if you want a **shared utility base** across multiple resources.

---

### Option B - Use Individual Files (Recommended for Scripts)

GRAFT is now designed so **every file is self-contained**.

You may:

* Copy **only the files you need** into your resource
* Ignore the rest
* Avoid adding GRAFT as a dependency entirely

This is ideal for:

* Standalone scripts
* Releases that should not require extra resources
* Developers who prefer explicit control

---

## `require.lua` (Optional Helper)

If your project **does not already have a Lua `require()` implementation**, GRAFT includes a minimal one:

```
cfx/require.lua
```

You may copy this file **once** into your project and reuse it everywhere.
If you already have a working `require()` helper, you do **not** need this file.

---

## Example Usage

```lua
local fw = require("framework")
local inventory = require("inventory")
local maths = require("maths")
```

Each module initializes independently and safely shares FiveM runtime state.

---

## What's Included

### Bridges

* **Framework**
* **Inventory** 
* **Notifications**
* **DrawText UI**

---

### Standalone Scripts

* **Zone Creator**

---

### Utility Modules

* **Commands**
* **Callbacks**
* **Cooldowns**
* **Entities**
* **Environment**
* **Keys**
* **Requests**
* **Timestamps**
* **Vehicles**

---

### Lightweight Libraries (Framework-Free)

Located under `standalone/modules`:

* **Maths**
* **Strings**
* **Tables**

These modules do **not** depend on FiveM and may be reused anywhere.

---

## Project Structure

```
cfx/
├─ require.lua            # Optional require helper
├─ fivem/
│  ├─ bridges/            # Framework & system bridges
│  ├─ modules/            # Utility helpers
│  └─ standalone/         # Framework-free systems
├─ tests/                 # Validation and test commands
└─ fxmanifest.lua
```

All modules are:

* Shared-runtime safe
* Client/server aware where applicable
* Designed to be copied or reused freely

---

## Why Use GRAFT?

* Use it **as a resource** or **as a file library**
* No forced dependencies
* Framework-agnostic APIs
* Consistent structure and naming
* Built for real scripts, not demos

GRAFT exists to **remove friction**, not introduce another layer of it.

---

## Support

Need help?
Found a bug?
Regretting a refactor?

👉 [https://discord.gg/MUckUyS5Kq](https://discord.gg/MUckUyS5Kq)

> **Support Hours:** Mon–Fri, 10AM–10PM GMT
> Outside hours? Messages are still logged.

---

## Warning

Using GRAFT may result in:

* Cleaner projects
* Less duplicated logic
* Faster development
* Mild discomfort from increased productivity

Use responsibly.