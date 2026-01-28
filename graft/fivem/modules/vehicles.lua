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

--- @module vehicles
--- @description Vehicle data and property utilities for both client and server.

--- @section Constants

local IS_SERVER = IsDuplicityVersion()

--- @section Module

local m = {}

--- @section Shared

--- Get vehicle plate (trimmed).
--- @param vehicle number: Vehicle entity
--- @return string: License plate
function m.get_plate(vehicle)
    if not vehicle or vehicle == 0 then return "" end
    local plate = GetVehicleNumberPlateText(vehicle)
    return plate:gsub("^%s*(.-)%s*$", "%1")
end

--- Get vehicle plate style/index.
--- @param vehicle number: Vehicle entity
--- @return number: Plate style index
function m.get_plate_index(vehicle)
    if not vehicle or vehicle == 0 then return 0 end
    return GetVehicleNumberPlateTextIndex(vehicle)
end

--- Set vehicle plate text.
--- @param vehicle number: Vehicle entity
--- @param text string: Plate text (max 8 chars)
function m.set_plate(vehicle, text)
    if not vehicle or vehicle == 0 then return end
    SetVehicleNumberPlateText(vehicle, text)
end

--- Set vehicle plate style.
--- @param vehicle number: Vehicle entity
--- @param index number: Plate style (0-5)
function m.set_plate_index(vehicle, index)
    if not vehicle or vehicle == 0 then return end
    SetVehicleNumberPlateTextIndex(vehicle, index)
end

--- @section Server

if IS_SERVER then

    local ACTIVE_VEHICLES = ACTIVE_VEHICLES or {}
    
    --- Get vehicles near coordinates.
    --- @param coords vector3: Center coordinates
    --- @param radius number: Search radius
    --- @param models table?: Optional model hash filter
    --- @return table: Array of vehicle entities
    function m.get_nearby(coords, radius, models)
        local pool = GetGamePool("CVehicle")
        local results = {}
        local count = 0
        local r2 = radius * radius

        local model_filter = nil
        if models then
            model_filter = {}
            for i = 1, #models do
                model_filter[models[i]] = true
            end
        end

        for i = 1, #pool do
            local veh = pool[i]
            local vcoords = GetEntityCoords(veh)
            local dx = vcoords.x - coords.x
            local dy = vcoords.y - coords.y
            local dz = vcoords.z - coords.z

            if (dx*dx + dy*dy + dz*dz) <= r2 then
                if not model_filter or model_filter[GetEntityModel(veh)] then
                    count = count + 1
                    results[count] = veh
                end
            end
        end

        return results
    end

    
    --- Get closest vehicle to coordinates.
    --- @param coords vector3: Center coordinates
    --- @param radius number: Search radius
    --- @return number|nil: Closest vehicle entity
    function m.get_closest(coords, radius)
        local vehicles_list = m.get_nearby(coords, radius)
        local closest, closest_dist = nil, radius
        
        for _, vehicle in ipairs(vehicles_list) do
            local veh_coords = GetEntityCoords(vehicle)
            local dist = #(coords - veh_coords)
            
            if dist < closest_dist then
                closest = vehicle
                closest_dist = dist
            end
        end
        
        return closest
    end
    
    --- Get basic vehicle info.
    --- If no vehicle is provided, finds the closest vehicle using GetEntitiesInRadius.
    --- @param vehicle number|nil: Vehicle entity handle (optional).
    --- @param options table|nil: Optional search options.
    --- @return table|nil: Basic vehicle data.
    function m.get_info(vehicle, options)
        options = options or {}

        if not vehicle or vehicle == 0 then
            local coords = options.coords or GetEntityCoords(GetPlayerPed(options.source))
            local radius = options.radius or 5.0
            local models = options.models
            local vehicles = m.get_nearby(coords, radius, models)
            vehicle = vehicles[1]
        end

        if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
            return nil
        end

        return {
            entity = vehicle,
            model = GetEntityModel(vehicle),
            coords = GetEntityCoords(vehicle),
            heading = GetEntityHeading(vehicle),
            plate = m.get_plate(vehicle),
            plate_index = m.get_plate_index(vehicle)
        }
    end

    --- Spawns a vehicle using CreateVehicleServerSetter.
    --- @param model string: Vehicle model name.
    --- @param options table: Spawn options.
    --- @return number|nil: Net ID of the spawned vehicle or nil.
    function m.spawn(model, opts)
        if not model or model == "" then
            print("[vehicles] spawn: Invalid model name (empty or nil).")
            return nil
        end

        opts = opts or {}
        local coords = opts.coords
        local vehicle_type = opts.vehicle_type or "automobile"
        local z_mod = opts.z_mod or 0

        if not coords then
            print("[vehicles] spawn: No coordinates provided.")
            return nil
        end

        local hash = GetHashKey(model)
        local x, y, z = coords.x, coords.y, coords.z - 1.0 + z_mod
        local w = coords.w or 0.0

        local entity = CreateVehicleServerSetter(hash, vehicle_type, x, y, z, w)

        if not entity or not DoesEntityExist(entity) then
            print("[vehicles] spawn: Vehicle creation failed.")
            return nil
        end

        if opts.plate then
            SetVehicleNumberPlateText(entity, tostring(opts.plate))
        end

        local net_id = NetworkGetNetworkIdFromEntity(entity)
        if not net_id then
            print("[vehicles] spawn: Failed to get network ID from entity.")
            return nil
        end

        ACTIVE_VEHICLES[#ACTIVE_VEHICLES + 1] = entity
        return net_id
    end

    --- Deletes a vehicle from a given network ID.
    --- @param net_id number: The network ID of the vehicle.
    function m.delete(net_id)
        if not net_id then return end
        local vehicle = NetworkGetEntityFromNetworkId(net_id)
        if not vehicle or not DoesEntityExist(vehicle) then return end
        DeleteEntity(vehicle)
    end

    --- Deletes all tracked vehicles on cleanup.
    function m.clear()
        for _, entity in pairs(ACTIVE_VEHICLES) do
            if entity and DoesEntityExist(entity) then
                DeleteEntity(entity)
            end
        end
        ACTIVE_VEHICLES = {}
        print("[VEHICLES] All vehicles cleared.")
    end

end

--- @section Client

if not IS_SERVER then

    --- Requests a model and waits until it's loaded.
    --- @param model hash: The hash of the model to load.
    --- @param timeout number: Optional timeout in ms (default: 10000).
    --- @return boolean: True if loaded successfully, false if timeout.
    local function request_model(model, timeout)
        if HasModelLoaded(model) then return true end
        
        RequestModel(model)
        local start = GetGameTimer()
        local max_wait = timeout or 10000
        
        while not HasModelLoaded(model) do
            if GetGameTimer() - start > max_wait then
                print(("[vehicles] Model load timeout: %s"):format(model))
                return false
            end
            Wait(0)
        end
        
        return true
    end
    
    --- Get vehicle model name.
    --- @param vehicle number: Vehicle entity
    --- @return string: Model name (lowercase)
    function m.get_model(vehicle)
        local hash = GetEntityModel(vehicle)
        local name = GetDisplayNameFromVehicleModel(hash)
        return name:lower()
    end
    
    --- Get vehicle class as string.
    --- @param vehicle number: Vehicle entity
    --- @return string: Class name
    function m.get_class(vehicle)
        local classes = {
            [0] = "compacts", 
            [1] = "sedans", 
            [2] = "suvs", 
            [3] = "coupes",
            [4] = "muscle",
            [5] = "sports classics", 
            [6] = "sports", 
            [7] = "super",
            [8] = "motorcycles", 
            [9] = "off-road", 
            [10] = "industrial", 
            [11] = "utility",
            [12] = "vans", 
            [13] = "cycles", 
            [14] = "boats", 
            [15] = "helicopters",
            [16] = "planes", 
            [17] = "service", 
            [18] = "emergency", 
            [19] = "military",
            [20] = "commercial", 
            [21] = "trains"
        }
        return classes[GetVehicleClass(vehicle)] or "unknown"
    end
    
    --- Get vehicle class performance stats.
    --- @param vehicle number: Vehicle entity
    --- @return table: Class performance data
    function m.get_class_stats(vehicle)
        local class_id = GetVehicleClass(vehicle)
        return {
            id = class_id,
            name = m.get_class(vehicle),
            max_speed = GetVehicleClassEstimatedMaxSpeed(class_id),
            max_acceleration = GetVehicleClassMaxAcceleration(class_id),
            max_agility = GetVehicleClassMaxAgility(class_id),
            max_braking = GetVehicleClassMaxBraking(class_id),
            max_traction = GetVehicleClassMaxTraction(class_id)
        }
    end
    
    --- Get comprehensive vehicle properties.
    --- @param vehicle number: Vehicle entity
    --- @return table|nil: Vehicle properties
    function m.get_properties(vehicle)
        if not DoesEntityExist(vehicle) then return nil end
        
        local color1, color2 = GetVehicleColours(vehicle)
        local pearl, wheel_color = GetVehicleExtraColours(vehicle)

        local custom_primary = nil
        if GetIsVehiclePrimaryColourCustom(vehicle) then
            local r, g, b = GetVehicleCustomPrimaryColour(vehicle)
            custom_primary = { r = r, g = g, b = b }
        end
        
        local custom_secondary = nil
        if GetIsVehicleSecondaryColourCustom(vehicle) then
            local r, g, b = GetVehicleCustomSecondaryColour(vehicle)
            custom_secondary = { r = r, g = g, b = b }
        end
        
        -- Mods
        local mods = {}
        for i = 0, 49 do
            mods[i] = {
                mod = GetVehicleMod(vehicle, i),
                variation = GetVehicleModVariation(vehicle, i)
            }
        end
        
        -- Extras
        local extras = {}
        for i = 0, 20 do
            if DoesExtraExist(vehicle, i) then
                extras[i] = IsVehicleExtraTurnedOn(vehicle, i)
            end
        end
        
        -- Neon
        local neon_enabled = {}
        for i = 0, 3 do
            neon_enabled[i] = IsVehicleNeonLightEnabled(vehicle, i)
        end
        local neon_r, neon_g, neon_b = GetVehicleNeonLightsColour(vehicle)
        
        -- Xenon
        local xenon_color = nil
        if type(GetVehicleXenonLightsCustomColor) == "function" then
            local has_custom, xr, xg, xb = GetVehicleXenonLightsCustomColor(vehicle)
            if has_custom then
                xenon_color = { r = xr, g = xg, b = xb }
            end
        end

        -- Tire smoke
        local smoke_r, smoke_g, smoke_b = GetVehicleTyreSmokeColor(vehicle)
        
        -- Livery
        local livery = GetVehicleMod(vehicle, 48)
        if livery == -1 then
            livery = GetVehicleLivery(vehicle)
        end
        
        return {
            model = GetEntityModel(vehicle),
            plate = m.get_plate(vehicle),
            plate_index = GetVehicleNumberPlateTextIndex(vehicle),

            color1 = color1,
            color2 = color2,
            custom_primary = custom_primary,
            custom_secondary = custom_secondary,
            pearl = pearl,
            wheel_color = wheel_color,
            dashboard_color = GetVehicleDashboardColour(vehicle),
            interior_color = GetVehicleInteriorColour(vehicle),
 
            body_health = GetVehicleBodyHealth(vehicle),
            engine_health = GetVehicleEngineHealth(vehicle),
            tank_health = GetVehiclePetrolTankHealth(vehicle),
            fuel_level = GetVehicleFuelLevel(vehicle),
            oil_level = GetVehicleOilLevel(vehicle),
            dirt_level = GetVehicleDirtLevel(vehicle),
  
            mods = mods,
            wheels = GetVehicleWheelType(vehicle),
            window_tint = GetVehicleWindowTint(vehicle),

            xenon = IsToggleModOn(vehicle, 22),
            xenon_color = GetVehicleXenonLightsColor(vehicle),
            custom_xenon = xenon_color,
            neon_enabled = neon_enabled,
            neon_color = { r = neon_r, g = neon_g, b = neon_b },
            headlight_color = GetVehicleHeadlightsColour(vehicle),

            extras = extras,
            tire_smoke = { r = smoke_r, g = smoke_g, b = smoke_b },
            livery = livery,
            tires_can_burst = GetVehicleTyresCanBurst(vehicle)
        }
    end
    
    --- Apply properties to vehicle.
    --- @param vehicle number: Vehicle entity
    --- @param props table: Properties from get_properties()
    function m.set_properties(vehicle, props)
        if not DoesEntityExist(vehicle) or not props then return end
   
        if props.color1 and props.color2 then
            SetVehicleColours(vehicle, props.color1, props.color2)
        end
        
        if props.custom_primary then
            SetVehicleCustomPrimaryColour(vehicle, props.custom_primary.r, props.custom_primary.g, props.custom_primary.b)
        end
        
        if props.custom_secondary then
            SetVehicleCustomSecondaryColour(vehicle, props.custom_secondary.r, props.custom_secondary.g, props.custom_secondary.b)
        end
        
        if props.pearl and props.wheel_color then
            SetVehicleExtraColours(vehicle, props.pearl, props.wheel_color)
        end

        if props.mods then
            for i, mod_data in pairs(props.mods) do
                SetVehicleMod(vehicle, i, mod_data.mod, mod_data.variation)
            end
        end

        if props.extras then
            for i, enabled in pairs(props.extras) do
                SetVehicleExtra(vehicle, i, not enabled)
            end
        end

        if props.neon_enabled then
            for i, enabled in pairs(props.neon_enabled) do
                SetVehicleNeonLightEnabled(vehicle, i, enabled)
            end
        end
        
        if props.neon_color then
            SetVehicleNeonLightsColour(vehicle, props.neon_color.r, props.neon_color.g, props.neon_color.b)
        end

        if props.xenon then
            ToggleVehicleMod(vehicle, 22, true)
        end
        
        if props.xenon_color then
            SetVehicleXenonLightsColor(vehicle, props.xenon_color)
        end

        if props.wheels then SetVehicleWheelType(vehicle, props.wheels) end
        if props.window_tint then SetVehicleWindowTint(vehicle, props.window_tint) end
        if props.livery then SetVehicleLivery(vehicle, props.livery) end
        if props.plate_index then SetVehicleNumberPlateTextIndex(vehicle, props.plate_index) end
        if props.tire_smoke then
            SetVehicleTyreSmokeColor(vehicle, props.tire_smoke.r, props.tire_smoke.g, props.tire_smoke.b)
        end

        if props.body_health then SetVehicleBodyHealth(vehicle, props.body_health + 0.0) end
        if props.engine_health then SetVehicleEngineHealth(vehicle, props.engine_health + 0.0) end
        if props.tank_health then SetVehiclePetrolTankHealth(vehicle, props.tank_health + 0.0) end
        if props.fuel_level then SetVehicleFuelLevel(vehicle, props.fuel_level + 0.0) end
        if props.oil_level then SetVehicleOilLevel(vehicle, props.oil_level + 0.0) end
        if props.dirt_level then SetVehicleDirtLevel(vehicle, props.dirt_level + 0.0) end
        
        if props.tires_can_burst ~= nil then
            SetVehicleTyresCanBurst(vehicle, props.tires_can_burst)
        end
    end
    
    --- Get basic vehicle info.
    --- @param vehicle number?: Vehicle entity (default: current vehicle or closest)
    --- @return table|nil: Vehicle info
    function m.get_info(vehicle)
        if not vehicle then
            local ped = PlayerPedId()
            if IsPedInAnyVehicle(ped, false) then
                vehicle = GetVehiclePedIsIn(ped, false)
            else
                local coords = GetEntityCoords(ped)
                local pool = GetGamePool("CVehicle")
                local closest, closest_dist = nil, 5.0
                
                for _, veh in ipairs(pool) do
                    local veh_coords = GetEntityCoords(veh)
                    local dist = #(coords - veh_coords)
                    
                    if dist < closest_dist then
                        closest = veh
                        closest_dist = dist
                    end
                end
                
                vehicle = closest
            end
        end
        
        if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return nil end
        
        return {
            entity = vehicle,
            model = GetEntityModel(vehicle),
            model_name = m.get_model(vehicle),
            coords = GetEntityCoords(vehicle),
            heading = GetEntityHeading(vehicle),
            plate = m.get_plate(vehicle),
            plate_index = m.get_plate_index(vehicle),
            class = m.get_class(vehicle),
            class_stats = m.get_class_stats(vehicle),
            body_health = GetVehicleBodyHealth(vehicle),
            engine_health = GetVehicleEngineHealth(vehicle),
            fuel_level = GetVehicleFuelLevel(vehicle)
        }
    end

    --- Spawns a vehicle with specified properties and modifications.
    --- @param vehicle_data table: Data specifying the properties and modifications for the vehicle.
    --- @example
    --[[
    local spawn_vehicle_data = {
        model = 'adder', -- Vehicle model name
        coords = vector4(0.0, 0.0, 0.0, 0.0), -- Coordinates and heading for spawn
        is_network = false, -- Whether the vehicle is networked
        net_mission_entity = false, -- Whether the vehicle is a mission entity
        -- Optional data
        -- set_into_vehicle = true, -- Whether to set the player into a vehicle or not
        -- custom_plate = 'TEST VEH', -- Custom vehicle plate set if specified
        -- lock_doors = true, -- Whether vehicle doors should be locked or not
        -- invincible = false, -- Whether the vehicle should be invincible or not
        -- damages = { -- Remove to not apply any damages
            -- doors = { -- Remove this section to not damage any doors
                -- ids = {0, 1} -- IDs of doors to break
                -- all = true -- Uncomment to break all doors
                -- random = true -- Uncomment to randomly break some doors
            -- },
            -- windows = true, -- Set to true to break all windows // SmashVehicleWindow seems to just smash every window on spawn so this is just a boolean toggle
            -- tyres = { -- Remove this section to not damage any tyres
                -- ids = {0, 1}, -- IDs of tyres to burst
                -- burst_completely = true -- Set to true to completely burst the tyres
                -- all = true -- Uncomment to burst all tyres
                -- random = true -- Uncomment to randomly burst some tyres
            -- }
        -- },
        -- maintenance = { -- Remove to apply default maintenance
            -- fuel = 100.0, -- Set the fuel level of the vehicle (range from 0.0 to 100.0). Remove to use default value.
            -- oil = 1000.0, -- Set the oil level of the vehicle. Higher values represent better condition. Remove for default.
            -- engine = 1000.0, -- Set the engine health of the vehicle (range from -4000.0 to 1000.0). Remove to use default value.
            -- body = 1000.0, -- Set the body health of the vehicle (range from 0.0 to 1000.0). Remove for default condition.
            -- clutch = 1000.0, -- Set the clutch health of the vehicle. Higher values represent better condition. Remove for default.
            -- petrol_tank = 1000.0, -- Set the petrol tank health of the vehicle. Higher values are better. Remove for default.
            -- dirt = 0.0, -- Set the dirt level on the vehicle (range from 0.0 for clean to 15.0 for very dirty). Remove for default.
        -- },
        -- mods = { -- Remove to spawn default vehicle
            -- random = false, -- Set to true to apply random mods
            -- max_performance = true -- Set to true to apply max performance mods
            -- ids = { [15] = 2, [16] = 4 }, -- Specific mods to apply
            -- custom_paint = { -- Remove to apply default paint
                -- primary = { r = 255, g = 0, b = 0 }, -- Primary colour rgb
                -- secondary = { r = 0, g = 255, b = 0 }  -- Secondary colour rgb
            -- },
            -- neon_lights = { -- Remove to not apply neons
                -- colour = { r = 255, g = 255, b = 255 } -- Custom neon colour
            -- },
            -- xenon_lights = { -- Remove to not apply xenons
                -- colour = 2 -- Xenon light colour index
            -- },
            -- bulletproof_tyres = true, -- Wether vehicle has bullet proof tyres or not
            -- engine_audio = 'ADDER', -- Custom engine sound for vehicle
            -- top_speed = 156, -- Set top speed of vehicle
            -- livery = 2, -- Set a livery if available
            -- plate_style = 3, -- Set the plate style for the vehicle
            -- window_tint = 3, -- Set the vehicles window tint
            -- handling_tweaks = { -- Remove to apply default handling
                -- ['fSuspensionHeight'] = -1.0, -- Lower the vehicle closer to the ground
                -- ['fBrakeForce'] = 1.5, -- Increase brake force
                -- ['fTractionCurveMax'] = 2.5, -- Improve maximal traction
                -- ['fTractionCurveMin'] = 1.5, -- Improve minimal traction
                -- ['fTractionCurveLateral'] = 2.0, -- Improve lateral traction
                -- ['fInitialDriveForce'] = 2.0, -- Increase acceleration
                -- ['fDriveBiasFront'] = 0.5, -- Distribute power evenly between front and back
            -- },
        -- }
    }
    ]]
    function m.spawn(vehicle_data)
        local model = vehicle_data.model
        local coords = vehicle_data.coords
        local is_network = vehicle_data.is_network
        local net_mission_entity = vehicle_data.net_mission_entity
        local hash = GetHashKey(model)

        request_model(hash)

        local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, coords.w, is_network, net_mission_entity)

        if vehicle_data.custom_plate then
            SetVehicleNumberPlateText(vehicle, vehicle_data.custom_plate)
        end

        if vehicle_data.damages then

            if damages.doors then
                for _, door_id in ipairs(damages.doors.ids) do 
                    SetVehicleDoorBroken(vehicle, door_id, true) 
                end
            end

            if damages.windows then
                for i = 0, 7 do 
                    SmashVehicleWindow(vehicle, i) 
                end
            end

            if damages.tyres then
                for _, tyre_id in ipairs(damages.tyres.ids) do 
                    SetVehicleTyreBurst(vehicle, tyre_id, damages.tyres.burst_completely, 1000) 
                end
            end

        end

        if vehicle_data.maintenance then
            local m = vehicle_data.maintenance
            SetVehicleFuelLevel(vehicle, m.fuel or 100.0)
            SetVehicleOilLevel(vehicle, m.oil or 1000.0)
            SetVehicleEngineHealth(vehicle, m.engine or 1000.0)
            SetVehicleBodyHealth(vehicle, m.body or 1000.0)
            SetVehiclePetrolTankHealth(vehicle, m.petrol_tank or 1000.0)
            SetVehicleDirtLevel(vehicle, m.dirt or 0.0)
        end

        if vehicle_data.mods then

            if vehicle_data.mods.random then
                for mod_type = 0, 49 do
                    local max = GetNumVehicleMods(vehicle, mod_type)
                    SetVehicleMod(vehicle, mod_type, math.random(0, max - 1), false)
                end
            end

            if vehicle_data.mods.max_performance then
                for mod_type = 0, 49 do
                    local max = GetNumVehicleMods(vehicle, mod_type)
                    SetVehicleMod(vehicle, mod_type, max - 1, false)
                end
            end

            if vehicle_data.mods.ids then
                for mod_type, modIndex in pairs(mods.ids) do
                    SetVehicleMod(vehicle, mod_type, modIndex, false)
                end
            end

            if vehicle_data.mods.custom_paint then
                local cp = vehicle_data.mods.custom_paint
                if cp.primary then
                    SetVehicleCustomPrimaryColour(vehicle, cp.primary.r, cp.primary.g, cp.primary.b)
                end
                if cp.secondary then
                    SetVehicleCustomSecondaryColour(vehicle, cp.secondary.r, cp.secondary.g, cp.secondary.b)
                end
            end

            if vehicle_data.mods.neon_lights then
                for i = 0, 3 do
                    SetVehicleNeonLightEnabled(vehicle, i, true)
                end
                SetVehicleNeonLightsColour(vehicle, vehicle_data.mods.neon_lights.colour.r, vehicle_data.mods.neon_lights.colour.g, vehicle_data.mods.neon_lights.colour.b)
            end

            if vehicle_data.mods.xenon_lights then
                ToggleVehicleMod(vehicle, 22, true)
                if vehicle_data.mods.xenon_lights.colour then
                    SetVehicleHeadlightsColour(vehicle, vehicle_data.mods.xenon_lights.colour)
                end
            end

            if vehicle_data.mods.bulletproof_tyres then
                SetVehicleTyresCanBurst(vehicle, false)
            end

            if vehicle_data.mods.engine_audio then
                ForceVehicleEngineAudio(vehicle, vehicle_data.mods.engine_audio)
            end

            if vehicle_data.mods.livery then
                SetVehicleLivery(vehicle, vehicle_data.mods.livery)
            end

            if vehicle_data.mods.plate_style then
                SetVehicleNumberPlateTextIndex(vehicle, vehicle_data.mods.plate_style)
            end
            
            if vehicle_data.mods.window_tint then
                SetVehicleWindowTint(vehicle, vehicle_data.mods.window_tint)
            end

            if vehicle_data.mods.top_speed then
                SetVehicleEnginePowerMultiplier(vehicle, vehicle_data.mods.top_speed)
            end

            if vehicle_data.mods.handling_tweaks then
                for property, value in pairs(vehicle_data.mods.handling_tweaks) do
                    SetVehicleHandlingFloat(vehicle, 'CHandlingData', property, value)
                end
            end
        end

        if vehicle_data.lock_doors then
            SetVehicleDoorsLocked(vehicle, 2)
        end

        if vehicle_data.invincible then
            SetEntityInvincible(vehicle, true)
        end

        PlaceObjectOnGroundProperly(vehicle)

        if vehicle_data.set_into_vehicle then
            local playerPed = PlayerPedId()
            SetPedIntoVehicle(playerPed, vehicle, -1)
        end

        return vehicle
    end

end

return m