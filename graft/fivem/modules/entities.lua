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

--- @module entities
--- @description Entity search utilities for finding nearby objects, peds, vehicles, and players.

--- @section Constants

local IS_SERVER = IsDuplicityVersion()

--- @section Module

local m = {}

--- @section Shared

--- Calculates the distance between two entities.
--- @param entity_1 number: First entity handle.
--- @param entity_2 number: Second entity handle.
--- @return number: Distance between the entities.
function m.get_distance_between_entities(entity_1, entity_2)
    local e1 = GetEntityCoords(entity_1)
    local e2 = GetEntityCoords(entity_2)
    return #(e1 - e2)
end

--- @section Server

if IS_SERVER then
    
    --- Get entities in radius (server-side).
    --- @param coords vector3: Center coordinates
    --- @param radius number: Search radius
    --- @param entity_type number: 1=Peds, 2=Vehicles, 3=Objects
    --- @param models table?: Optional allowed model hashes
    --- @return table: Array of entity handles
    function m.get_in_radius(coords, radius, entity_type, models)
        local pool = entity_type == 1 and GetGamePool("CPed") or entity_type == 2 and GetGamePool("CVehicle") or entity_type == 3 and GetGamePool("CObject")
        if not pool then return {} end

        local results = {}
        local r2 = radius * radius
        local model_filter = nil

        if models then
            model_filter = {}
            for _, m in ipairs(models) do
                model_filter[m] = true
            end
        end

        for _, entity in ipairs(pool) do
            local ecoords = GetEntityCoords(entity)
            local dx = ecoords.x - coords.x
            local dy = ecoords.y - coords.y
            local dz = ecoords.z - coords.z

            if (dx*dx + dy*dy + dz*dz) <= r2 then
                if not model_filter or model_filter[GetEntityModel(entity)] then
                    results[#results + 1] = entity
                end
            end
        end

        return results
    end

    --- Get nearby peds.
    --- @param coords vector3: Center coordinates
    --- @param radius number: Search radius
    --- @return table: Array of ped entities
    function m.get_nearby_peds(coords, radius)
        return m.get_in_radius(coords, radius, 1)
    end
    
    --- Get nearby vehicles.
    --- @param coords vector3: Center coordinates
    --- @param radius number: Search radius
    --- @return table: Array of vehicle entities
    function m.get_nearby_vehicles(coords, radius)
        return m.get_in_radius(coords, radius, 2)
    end
    
    --- Get nearby objects.
    --- @param coords vector3: Center coordinates
    --- @param radius number: Search radius
    --- @param models table?: Optional allowed model hashes
    --- @return table: Array of object entities
    function m.get_nearby_objects(coords, radius, models)
        return m.get_in_radius(coords, radius, 3, models)
    end
    
    --- Get closest entity from a list.
    --- @param coords vector3: Reference coordinates
    --- @param entity_list table: Array of entities
    --- @return number|nil: Closest entity or nil
    function m.get_closest(coords, entity_list)
        local closest, closest_dist = nil, math.huge
        
        for _, entity in ipairs(entity_list) do
            local entity_coords = GetEntityCoords(entity)
            local dist = #(coords - entity_coords)
            
            if dist < closest_dist then
                closest = entity
                closest_dist = dist
            end
        end
        
        return closest
    end
    
    --- Get closest ped.
    --- @param coords vector3: Reference coordinates
    --- @param radius number: Search radius
    --- @return number|nil: Closest ped or nil
    function m.get_closest_ped(coords, radius)
        local peds = m.get_nearby_peds(coords, radius)
        return m.get_closest(coords, peds)
    end
    
    --- Get closest vehicle.
    --- @param coords vector3: Reference coordinates
    --- @param radius number: Search radius
    --- @return number|nil: Closest vehicle or nil
    function m.get_closest_vehicle(coords, radius)
        local vehicles = m.get_nearby_vehicles(coords, radius)
        return m.get_closest(coords, vehicles)
    end
    
    --- Get closest object.
    --- @param coords vector3: Reference coordinates
    --- @param radius number: Search radius
    --- @param models table?: Optional allowed model hashes
    --- @return number|nil: Closest object or nil
    function m.get_closest_object(coords, radius, models)
        local objects = m.get_nearby_objects(coords, radius, models)
        return m.get_closest(coords, objects)
    end

end

if not IS_SERVER then
    
    --- Find nearby entities (client-side).
    --- @param pool string: Entity pool ("CObject", "CPed", "CVehicle")
    --- @param coords vector3: Reference coordinates
    --- @param max_distance number: Maximum search distance
    --- @param filter function?: Optional filter function
    --- @return table: Array of {entity, coords} entries
    function m.get_nearby_entities(pool, coords, max_distance, filter)
        local pool_entities = GetGamePool(pool)
        local nearby = {}
        local count = 0
        max_distance = max_distance or 2.0

        for i = 1, #pool_entities do
            local entity = pool_entities[i]
            local entity_coords = GetEntityCoords(entity)
            local distance = #(coords - entity_coords)
            
            if distance < max_distance and (not filter or filter(entity)) then
                count = count + 1
                nearby[count] = { entity = entity, coords = entity_coords }
            end
        end

        return nearby
    end

    --- Get closest entity (client-side).
    --- @param pool string: Entity pool type
    --- @param coords vector3: Reference coordinates
    --- @param max_distance number: Maximum distance
    --- @param filter function?: Optional filter
    --- @return number|nil, vector3|nil: Entity and coords
    function m.get_closest_entity(pool, coords, max_distance, filter)
        local nearby = m.get_nearby_entities(pool, coords, max_distance, filter)
        local closest_entity, closest_coords, closest_dist = nil, nil, max_distance or 2.0

        for _, entry in ipairs(nearby) do
            local dist = #(coords - entry.coords)
            if dist < closest_dist then
                closest_entity = entry.entity
                closest_coords = entry.coords
                closest_dist = dist
            end
        end

        return closest_entity, closest_coords
    end

    --- Get nearby objects.
    --- @param coords vector3: Reference coordinates
    --- @param max_distance number: Maximum distance
    --- @return table: Array of {entity, coords}
    function m.get_nearby_objects(coords, max_distance)
        return m.get_nearby_entities("CObject", coords, max_distance)
    end

    --- Get nearby peds (excluding players).
    --- @param coords vector3: Reference coordinates
    --- @param max_distance number: Maximum distance
    --- @return table: Array of {entity, coords}
    function m.get_nearby_peds(coords, max_distance)
        return m.get_nearby_entities("CPed", coords, max_distance, function(ped)
            return not IsPedAPlayer(ped)
        end)
    end

    --- Get nearby players.
    --- @param coords vector3: Reference coordinates
    --- @param max_distance number: Maximum distance
    --- @param include_self boolean?: Include local player
    --- @return table: Array of {entity, coords}
    function m.get_nearby_players(coords, max_distance, include_self)
        local player_id = PlayerId()
        return m.get_nearby_entities("CPed", coords, max_distance, function(ped)
            return IsPedAPlayer(ped) and (include_self or NetworkGetPlayerIndexFromPed(ped) ~= player_id)
        end)
    end

    --- Get nearby vehicles.
    --- @param coords vector3: Reference coordinates
    --- @param max_distance number: Maximum distance
    --- @param include_current boolean?: Include player's vehicle
    --- @return table: Array of {entity, coords}
    function m.get_nearby_vehicles(coords, max_distance, include_current)
        local player_vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        return m.get_nearby_entities("CVehicle", coords, max_distance, function(vehicle)
            return include_current or vehicle ~= player_vehicle
        end)
    end

    --- Get closest object.
    --- @param coords vector3: Reference coordinates
    --- @param max_distance number: Maximum distance
    --- @return number|nil, vector3|nil: Entity and coords
    function m.get_closest_object(coords, max_distance)
        return m.get_closest_entity("CObject", coords, max_distance)
    end

    --- Get closest ped.
    --- @param coords vector3: Reference coordinates
    --- @param max_distance number: Maximum distance
    --- @return number|nil, vector3|nil: Entity and coords
    function m.get_closest_ped(coords, max_distance)
        return m.get_closest_entity("CPed", coords, max_distance, function(ped)
            return not IsPedAPlayer(ped)
        end)
    end

    --- Get closest player.
    --- @param coords vector3: Reference coordinates
    --- @param max_distance number: Maximum distance
    --- @param include_self boolean?: Include local player
    --- @return number|nil, vector3|nil: Entity and coords
    function m.get_closest_player(coords, max_distance, include_self)
        local player_id = PlayerId()
        return m.get_closest_entity("CPed", coords, max_distance, function(ped)
            return IsPedAPlayer(ped) and (include_self or NetworkGetPlayerIndexFromPed(ped) ~= player_id)
        end)
    end

    --- Get closest vehicle.
    --- @param coords vector3: Reference coordinates
    --- @param max_distance number: Maximum distance
    --- @param include_current boolean?: Include player's vehicle
    --- @return number|nil, vector3|nil: Entity and coords
    function m.get_closest_vehicle(coords, max_distance, include_current)
        local player_vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        return m.get_closest_entity("CVehicle", coords, max_distance, function(vehicle)
            return include_current or vehicle ~= player_vehicle
        end)
    end

    --- Get entity in front of player using raycast.
    --- @param distance number: Ray distance
    --- @return number|nil: Entity or nil
    function m.get_in_front_of_player(distance)
        local player = PlayerPedId()
        local coords = GetEntityCoords(player)
        local forward = GetEntityForwardVector(player)
        local end_coords = coords + (forward * distance)
        
        local _, hit, _, _, entity = StartShapeTestRay(
            coords.x, coords.y, coords.z,
            end_coords.x, end_coords.y, end_coords.z,
            -1, player, 0
        )
        
        return hit and GetEntityType(entity) ~= 0 and entity or nil
    end

    --- Get target ped (raycast or nearest).
    --- @param distance number: Maximum distance
    --- @return number|nil, vector3|nil: Ped and coords
    function m.get_target_ped(distance)
        local entity = m.get_in_front_of_player(distance)
        
        if entity and IsEntityAPed(entity) and not IsPedAPlayer(entity) then
            return entity, GetEntityCoords(entity)
        end
        
        return m.get_closest_ped(GetEntityCoords(PlayerPedId()), distance)
    end

    --- Retrieves the entity a player is targeting.
    --- @return number: The entity that the player is targeting.
    function m.get_target_entity()
        local player_ped = PlayerPedId()
        local entity = 0

        if IsPlayerFreeAiming(player_ped) then
            local success, target = GetEntityPlayerIsFreeAimingAt(player_ped)
            if success then
                entity = target
            end
        end

        return entity
    end


end

return m