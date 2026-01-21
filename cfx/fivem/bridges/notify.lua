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

--- @module bridges.notify
--- @description Handles a variety of commonly used notification systems.
--- Used by resources to display notifications in a framework-agnostic way.

--- @section Guard

if rawget(_G, "__bridges_notify_module") then
    return _G.__bridges_notify_module
end

--- @section Constants

local RESOURCE_NAME = GetCurrentResourceName()
local AUTO_DETECT_NOTIFY = GetConvar("bridge:notify:auto_detect", "true") == "true"
local ACTIVE_NOTIFY = GetConvar("bridge:notify:active", "standalone")
local IS_SERVER = IsDuplicityVersion()

--- @section Mapping

local NOTIFY_SYSTEMS = {
    "ox_lib",
    "boii_ui",
    "okokNotify",
    "es_extended",
    "qb-core",
    "pluck"
}

--- @section Initialization

if AUTO_DETECT_NOTIFY then
    for _, resource in ipairs(NOTIFY_SYSTEMS) do
        if GetResourceState(resource) == "started" then
            ACTIVE_NOTIFY = resource
            break
        end
    end
end

--- @section Event Registry

local event_registered = false

if not IS_SERVER then
    if ACTIVE_NOTIFY == "standalone" and not event_registered then
        event_registered = true

        RegisterNetEvent(RESOURCE_NAME .. ":cl:notify")
        AddEventHandler(RESOURCE_NAME .. ":cl:notify", function(options)
            if not options or not options.message then return end

            local text = options.header
                and (options.header .. "\n" .. options.message)
                or options.message

            BeginTextCommandThefeedPost("STRING")
            AddTextComponentSubstringPlayerName(text)
            EndTextCommandThefeedPostTicker(false, options.duration or 5000)
        end)
    end
end


--- @section Implementations

local IMPL = {}

if IS_SERVER then
    IMPL.standalone = {
        send = function(source, options)
            if not source or not options or not (options.type and options.message) then return false end
            TriggerClientEvent(RESOURCE_NAME .. ":cl:notify", source, options)
            return true
        end
    }

    IMPL.ox_lib = {
        send = function(source, options)
            if not source or not options or not (options.type and options.message) then return false end
            TriggerClientEvent("ox_lib:notify", source, {
                type = options.type,
                title = options.header,
                description = options.message
            })
            return true
        end
    }

    IMPL.boii_ui = {
        send = function(source, options)
            if not source or not options or not (options.type and options.message) then return false end
            TriggerClientEvent("boii_ui:notify", source, {
                type = options.type,
                header = options.header,
                message = options.message,
                duration = options.duration
            })
            return true
        end
    }

    IMPL.okokNotify = {
        send = function(source, options)
            if not source or not options or not (options.type and options.message) then return false end
            TriggerClientEvent("okokNotify:Alert", source, options.header, options.message, options.type, options.duration)
            return true
        end
    }

    IMPL.es_extended = {
        send = function(source, options)
            if not source or not options or not (options.type and options.message) then return false end
            TriggerClientEvent("ESX:Notify", source, options.type, options.duration, options.message)
            return true
        end
    }

    IMPL["qb-core"] = {
        send = function(source, options)
            if not source or not options or not (options.type and options.message) then return false end
            local t = ({ information = "primary", info = "primary" })[options.type] or options.type
            TriggerClientEvent("QBCore:Notify", source, options.message, t, options.duration)
            return true
        end
    }

    IMPL.pluck = {
        send = function(source, options)
            if not source or not options or not (options.type and options.message) then return false end
            TriggerClientEvent("pluck:notify", source, {
                type = options.type or "info",
                header = options.header or "No Header Provided",
                message = options.message or "No message provided.",
                icon = options.icon or "fa-solid fa-check-circle",
                duration = options.duration or 3500,
                match_border = options.match_border or false,
                match_shadow = options.match_shadow or false
            })
            return true
        end
    }
end

if not IS_SERVER then
    IMPL.standalone = {
        send = function(options)
            if not options or not options.type or not options.message then return false end
            TriggerEvent(RESOURCE_NAME .. ":cl:notify", options)
            return true
        end
    }

    IMPL.ox_lib = {
        send = function(options)
            if not options or not options.type or not options.message then return false end
            TriggerEvent("ox_lib:notify", {
                type = options.type,
                title = options.header,
                description = options.message
            })
            return true
        end
    }

    IMPL.boii_ui = {
        send = function(options)
            if not options or not options.type or not options.message then return false end
            TriggerEvent("boii_ui:notify", {
                type = options.type,
                header = options.header,
                message = options.message,
                duration = options.duration
            })
            return true
        end
    }

    IMPL.okokNotify = {
        send = function(options)
            if not options or not options.type or not options.message then return false end
            TriggerEvent("okokNotify:Alert", options.header, options.message, options.type, options.duration)
            return true
        end
    }

    IMPL.es_extended = {
        send = function(options)
            if not options or not options.type or not options.message then return false end
            TriggerEvent("ESX:Notify", options.type, options.duration, options.message)
            return true
        end
    }

    IMPL["qb-core"] = {
        send = function(options)
            if not options or not options.type or not options.message then return false end
            local t = ({ information = "primary", info = "primary" })[options.type] or options.type
            TriggerEvent("QBCore:Notify", options.message, t, options.duration)
            return true
        end
    }

    IMPL.pluck = {
        send = function(options)
            if not options or not options.type or not options.message then return false end
            TriggerEvent("pluck:notify", {
                type = options.type or "info",
                header = options.header or "No Header Provided",
                message = options.message or "No message provided.",
                icon = options.icon or "fa-solid fa-check-circle",
                duration = options.duration or 3500,
                match_border = options.match_border or false,
                match_shadow = options.match_shadow or false
            })
            return true
        end
    }
end

_G.__bridges_notify_module = IMPL[ACTIVE_NOTIFY] or IMPL.standalone
return _G.__bridges_notify_module