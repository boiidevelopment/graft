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

--- @module requests
--- @description Wrapper functions around FiveM's native Request functions with proper error handling.

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
    function m.model(model, timeout)
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

    --- Requests an interior and waits until it's ready.
    --- @param interior number: The ID of the interior to load.
    --- @param timeout number: Optional timeout in ms (default: 10000).
    --- @return boolean: True if loaded successfully, false if invalid or timeout.
    function m.interior(interior, timeout)
        if IsInteriorReady(interior) then return true end
        
        if not IsValidInterior(interior) then
            print(("[requests] Invalid interior ID: %s"):format(interior))
            return false
        end
        
        LoadInterior(interior)
        local start = GetGameTimer()
        local max_wait = timeout or 10000
        
        while not IsInteriorReady(interior) do
            if GetGameTimer() - start > max_wait then
                print(("[requests] Interior load timeout: %s"):format(interior))
                return false
            end
            Wait(0)
        end
        
        return true
    end

    --- Requests a texture dictionary and optionally waits until it's loaded.
    --- @param texture string: The name of the texture dictionary to load.
    --- @param wait boolean: Whether to wait for the texture dictionary to load.
    --- @param timeout number: Optional timeout in ms (default: 10000).
    --- @return boolean: True if loaded successfully, false if timeout.
    function m.texture(texture, wait, timeout)
        if HasStreamedTextureDictLoaded(texture) then return true end
        
        RequestStreamedTextureDict(texture, wait or false)
        
        if not wait then return true end
        
        local start = GetGameTimer()
        local max_wait = timeout or 10000
        
        while not HasStreamedTextureDictLoaded(texture) do
            if GetGameTimer() - start > max_wait then
                print(("[requests] Texture load timeout: %s"):format(texture))
                return false
            end
            Wait(0)
        end
        
        return true
    end

    --- Requests collision at a given location and waits until it's loaded.
    --- @param x number: The X coordinate.
    --- @param y number: The Y coordinate.
    --- @param z number: The Z coordinate.
    --- @param timeout number: Optional timeout in ms (default: 10000).
    --- @return boolean: True if loaded successfully, false if timeout.
    function m.collision(x, y, z, timeout)
        local ped = PlayerPedId()
        if HasCollisionLoadedAroundEntity(ped) then return true end
        
        RequestCollisionAtCoord(x, y, z)
        local start = GetGameTimer()
        local max_wait = timeout or 10000
        
        while not HasCollisionLoadedAroundEntity(ped) do
            if GetGameTimer() - start > max_wait then
                print(("[requests] Collision load timeout at: %.2f, %.2f, %.2f"):format(x, y, z))
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
    function m.anim(dict, timeout)
        if HasAnimDictLoaded(dict) then return true end
        
        RequestAnimDict(dict)
        local start = GetGameTimer()
        local max_wait = timeout or 10000
        
        while not HasAnimDictLoaded(dict) do
            if GetGameTimer() - start > max_wait then
                print(("[requests] Anim dict load timeout: %s"):format(dict))
                return false
            end
            Wait(0)
        end
        
        return true
    end

    --- Requests an animation set and waits until loaded.
    --- @param set string: The name of the animation set to load.
    --- @param timeout number: Optional timeout in ms (default: 10000).
    --- @return boolean: True if loaded successfully, false if timeout.
    function m.anim_set(set, timeout)
        if HasAnimSetLoaded(set) then return true end
        
        RequestAnimSet(set)
        local start = GetGameTimer()
        local max_wait = timeout or 10000
        
        while not HasAnimSetLoaded(set) do
            if GetGameTimer() - start > max_wait then
                print(("[requests] Anim set load timeout: %s"):format(set))
                return false
            end
            Wait(100)
        end
        
        return true
    end

    --- Requests an animation clip set and waits until it's loaded.
    --- @param clip string: The name of the clip set to load.
    --- @param timeout number: Optional timeout in ms (default: 10000).
    --- @return boolean: True if loaded successfully, false if timeout.
    function m.clip_set(clip, timeout)
        if HasClipSetLoaded(clip) then return true end
        
        RequestClipSet(clip)
        local start = GetGameTimer()
        local max_wait = timeout or 10000
        
        while not HasClipSetLoaded(clip) do
            if GetGameTimer() - start > max_wait then
                print(("[requests] Clip set load timeout: %s"):format(clip))
                return false
            end
            Wait(0)
        end
        
        return true
    end

    --- Requests a script audio bank and waits until it's loaded.
    --- @param audio string: The name of the audio bank to load.
    --- @param timeout number: Optional timeout in ms (default: 10000).
    --- @return boolean: True if loaded successfully, false if timeout.
    function m.audio_bank(audio, timeout)
        if RequestScriptAudioBank(audio, false) then return true end
        
        local start = GetGameTimer()
        local max_wait = timeout or 10000
        
        while not RequestScriptAudioBank(audio, false) do
            if GetGameTimer() - start > max_wait then
                print(("[requests] Audio bank load timeout: %s"):format(audio))
                return false
            end
            Wait(0)
        end
        
        return true
    end

    --- Requests a scaleform movie and waits until it's loaded.
    --- @param scaleform string: The name of the scaleform movie to load.
    --- @param timeout number: Optional timeout in ms (default: 10000).
    --- @return number|nil: The handle of the loaded scaleform movie, or nil if timeout.
    function m.scaleform_movie(scaleform, timeout)
        local handle = RequestScaleformMovie(scaleform)
        
        if HasScaleformMovieLoaded(handle) then return handle end
        
        local start = GetGameTimer()
        local max_wait = timeout or 10000
        
        while not HasScaleformMovieLoaded(handle) do
            if GetGameTimer() - start > max_wait then
                print(("[requests] Scaleform load timeout: %s"):format(scaleform))
                return nil
            end
            Wait(0)
        end
        
        return handle
    end

    --- Requests a cutscene and waits until it's loaded.
    --- @param scene string: The name of the cutscene to load.
    --- @param timeout number: Optional timeout in ms (default: 10000).
    --- @return boolean: True if loaded successfully, false if timeout.
    function m.cutscene(scene, timeout)
        if HasCutsceneLoaded() then return true end
        
        RequestCutscene(scene, 8)
        local start = GetGameTimer()
        local max_wait = timeout or 10000
        
        while not HasCutsceneLoaded() do
            if GetGameTimer() - start > max_wait then
                print(("[requests] Cutscene load timeout: %s"):format(scene))
                return false
            end
            Wait(0)
        end
        
        return true
    end

    --- Requests an IPL and waits until it's active.
    --- @param str string: The name of the IPL to load.
    --- @param timeout number: Optional timeout in ms (default: 10000).
    --- @return boolean: True if loaded successfully, false if timeout.
    function m.ipl(str, timeout)
        if IsIplActive(str) then return true end
        
        RequestIpl(str)
        local start = GetGameTimer()
        local max_wait = timeout or 10000
        
        while not IsIplActive(str) do
            if GetGameTimer() - start > max_wait then
                print(("[requests] IPL load timeout: %s"):format(str))
                return false
            end
            Wait(0)
        end
        
        return true
    end

end

return m