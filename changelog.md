## Key
```diff
- Removed
! Modified
+ Added
# Notes
```

# v0.1.3
```diff
! bridges/nd: should now actually work correctly.
! modules/environment: modified get_altitude() to be used from server or client
- init.lua: removed version check on self
```

# v0.1.2
```diff
! entities: Added back in get_closest_entity function was removed accidently, and fixed duplicity split.
! vehicles: Fixed few functions that were namespaced incorrectly, and fixed duplicity split.
! items|version|timestamps|environment: Fixed duplicity split.
! requests: Fix duplicity and remove old exports.
! profanity: Remove exports.
```

# V0.1.1
```diff
! users: Fixed connection logic is_player_banned was namespace, it should not have been.
```

# v0.3.1
```diff
! All fw bridges: changed tables.contains to the new `tables.table_contains` function.
! tables: Fixed namespace typo with tables.print_table.
```

# v0.3.0
```diff
+ tables: Added new deep_merge() function. 
+ framework bridges: Added support for list_inventory.
```