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

--- @module animations
--- @description Handles animation wrapper functions.

--- @section Constants

local IS_SERVER = IsDuplicityVersion()

--- @section Module

local m = {}

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
                print(("[requests] Model load timeout: %s"):format(model))
                return false
            end
            Wait(0)
        end
        
        return true
    end

    --- Requests an animation dictionary and waits until it's loaded.
    --- @param dict string: The name of the animation dictionary to load.
    --- @param timeout number: Optional timeout in ms (default: 10000).
    --- @return boolean: True if loaded successfully, false if timeout.
    function m.request(dict, timeout)
        if HasAnimDictLoaded(dict) then return true end
        
        RequestAnimDict(dict)
        local start = GetGameTimer()
        local max_wait = timeout or 10000
        
        while not HasAnimDictLoaded(dict) do
            if GetGameTimer() - start > max_wait then
                print(("[animations] request: Anim dict load timeout: %s"):format(dict))
                return false
            end
            Wait(0)
        end
        
        return true
    end

    --- Runs animation on the player with params.
    --- @param player_ped number: The player entity.
    --- @param options table: Table of options to run when playing.
    --- @param callback function: Callback function to run when animation has finished.
    function m.play(player_ped, options, callback)
        if not player_ped then print("[animations] play: player_ped ped is missing") return end
        if not options or not options.dict or not options.anim then print("[animations] play: Options or animation dictionary/animation name is missing") return end
        
        m.request(options.dict)

        if options.freeze then FreezeEntityPosition(player_ped, true) end

        local duration = options.duration or 2000
        
        local props = {}
        if options.props then
            for _, prop in ipairs(options.props) do
                request_model(prop.model)
                local prop_entity = CreateObject(GetHashKey(prop.model), GetEntityCoords(player_ped), true, true, true)
                AttachEntityToEntity(prop_entity, player_ped, GetPedBoneIndex(player_ped, prop.bone), prop.coords.x or 0.0, prop.coords.y or 0.0, prop.coords.z or 0.0, prop.rotation.x or 0.0, prop.rotation.y or 0.0, prop.rotation.z or 0.0, true, prop.use_soft or false, prop.collision or false, prop.is_ped or true, prop.rot_order or 1, prop.sync_rot or true)
                table.insert(props, prop_entity)
            end
        end

        if options.continuous then
            TaskPlayAnim(player_ped, options.dict, options.anim, options.blend_in or 8.0, options.blend_out or -8.0, -1, options.flags or 49, options.playback or 0, options.lock_x or 0, options.lock_y or 0, options.lock_z or 0)
        else
            TaskPlayAnim(player_ped, options.dict, options.anim, options.blend_in or 8.0, options.blend_out or -8.0, duration, options.flags or 49, options.playback or 0, options.lock_x or 0, options.lock_y or 0, options.lock_z or 0)
            Wait(duration)
            ClearPedTasks(player_ped)
            if options.freeze then 
                FreezeEntityPosition(player_ped, false) 
            end
            for _, prop_entity in ipairs(props) do 
                DeleteObject(prop_entity) 
            end
            if callback then 
                callback() 
            end
        end
    end

end

return m