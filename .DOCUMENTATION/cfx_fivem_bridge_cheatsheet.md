# FiveM Bridge Cheatsheet

*One page. Every bridge. Total reference.*

## Framework Bridge

*Unified wrapper for `qb-core`, `qbx_core`, `ox_core`, `es_extended`, `ND_Core`, and `standalone` more can be added*

### Server: Player & Identity

```lua
bridge.get_players()                        -- Returns array of all player objects
bridge.get_player(source)                   -- Returns raw framework player object
bridge.get_player_id(source)                -- Returns unique CID / License
bridge.get_id_params(source)                -- Returns SQL query string + {params}
bridge.get_identity(source)                 -- Returns {first_name, last_name, dob, sex, nationality}
bridge.get_identity_by_id(unique_id)        -- Returns identity table for offline/specific ID
```

### Server: Inventory & Items

```lua
bridge.get_inventory(source)                                -- Returns full inventory table
bridge.get_item(source, name)                               -- Returns item object or nil
bridge.has_item(source, name, amt?)                         -- Returns boolean (amt defaults to 1)
bridge.add_item(source, name, amt, data?)                   -- Add item (data = metadata/info)
bridge.remove_item(source, name, amt)                       -- Remove item
bridge.update_item_data(source, name, updates)              -- Update metadata (uses bridge if native lacks support)
bridge.register_item(name, function(source) ... end)        -- Register item usage callback
```

### Server: Money & Economy

```lua
bridge.get_balances(source)                     -- Returns {cash = 0, bank = 0, ...}
bridge.get_balance_by_type(source, b_type)      -- Get specific (e.g., "crypto")
bridge.add_balance(source, b_type, amt)         -- Add money to account
bridge.remove_balance(source, b_type, amt)      -- Remove money from account
```

### Server: Jobs & Duty

```lua
bridge.get_player_jobs(source)                      -- Returns {name, label, grade, ...}
bridge.get_player_job_name(source)                  -- Returns string name only
bridge.get_player_job_grade(source, job_id)         -- Returns numeric rank
bridge.player_has_job(source, {jobs}, on_duty?)     -- Check if player has job in list
bridge.count_players_by_job({jobs}, on_duty?)       -- Returns total, on_duty_count
```

### Server: Status & Metadata

```lua
-- Modifies levels. Supports ranges: { remove = { min, max } } or { add = { min, max } }
bridge.adjust_statuses(source, { hunger = { remove = {5, 10} }, armor = { add = 10 } })
```

### Client: Local Player

```lua
bridge.get_data()           -- Get full local player framework data
bridge.get_identity()       -- Get local identity table
bridge.get_player_id()      -- Get local unique identifier
```

---

## Inventory Bridge

*Unified wrapper for `ox_inventory` & `inventory_system` more can be added*

### Server Functions

```lua
inventory.get_inventory(source)                         -- Returns full inventory object
inventory.get_item(source, item_name)                   -- Returns item table if count > 0
inventory.has_item(source, item_name, amount?)          -- Returns boolean (amount defaults to 1)
inventory.add_item(source, item_id, amount, data?)      -- Adds item with optional metadata
inventory.remove_item(source, item_id, amount)          -- Removes item from source
inventory.update_item_data(source, item_id, upd)        -- Merges 'upd' table into existing metadata
inventory.register_item(item_name, cb)                  -- Registers item usage (callback receives src, data, slot, metadata)
```

---

## Notification Bridge

*Unified wrapper for `ox_lib`, `boii_ui`, `okokNotify`, `es_extended`, `qb-core`, `pluck` more can be added*

### Server Functions

```lua
notify.send(source, {type = "success", header = "Title", message = "Msg", duration = 5000})     -- Server requires player source
```

### Client Functions

```lua
notify.send({type = "success", header = "Title", message = "Msg", duration = 5000})     -- Sends to local player
```

---

## DrawText Bridge

*Unified wrapper for `ox_lib`, `boii_ui`, `okokTextUI`, `es_extended`, `qb-core`, `standalone` more can be added*

### Client Functions

```lua
drawtext.show({header = "Title", message = "Msg", icon = "fa-check"})       -- Displays UI prompt
drawtext.hide()                                                             -- Removes UI prompt
```