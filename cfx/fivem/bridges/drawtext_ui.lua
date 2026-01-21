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

--- @module bridges.drawtext_ui
--- @description Handles a variety of commonly used drawtext UI systems.
--- Used by resources to display on-screen text prompts in a framework-agnostic way.

--- @section Constants

local AUTO_DETECT_DRAWTEXT = GetConvar("bridge:drawtext_ui:auto_detect", "true") == "true"
local ACTIVE_DRAWTEXT = GetConvar("bridge:drawtext_ui:active", "standalone")

--- @section Mapping

local DRAWTEXT_UIS = {
    "ox_lib",
    "boii_ui",
    "okokTextUI",
    "es_extended",
    "qb-core"
}

--- @section Initialization

if AUTO_DETECT_DRAWTEXT then
    for _, resource in ipairs(DRAWTEXT_UIS) do
        if GetResourceState(resource) == "started" then
            ACTIVE_DRAWTEXT = resource
            break
        end
    end
end

--- @section Standalone Help Text

local showing_help_text = false
local current_help_text = ""

if not IsDuplicityVersion() and ACTIVE_DRAWTEXT == "standalone" then
    CreateThread(function()
        while true do
            if showing_help_text then
                BeginTextCommandDisplayHelp("STRING")
                AddTextComponentSubstringPlayerName(current_help_text)
                EndTextCommandDisplayHelp(0, false, true, -1)
                Wait(0)
            else
                Wait(1000)
            end
        end
    end)
end

--- @section Implementations

local IS_SERVER = IsDuplicityVersion()
local IMPL = {}

if not IS_SERVER then
    IMPL.standalone = {
        show = function(options)
            if not options or not options.message then return false end
            current_help_text = options.message
            showing_help_text = true
            return true
        end,

        hide = function()
            showing_help_text = false
            current_help_text = ""
            return true
        end
    }

    IMPL.ox_lib = {
        show = function(options)
            if not options or not options.message then return false end
            exports.ox_lib:showTextUI(options.message, { icon = options.icon })
            return true
        end,

        hide = function()
            exports.ox_lib:hideTextUI()
            return true
        end
    }

    IMPL.boii_ui = {
        show = function(options)
            if not options or not options.message then return false end
            exports.boii_ui:show_drawtext(options.header, options.message, options.icon)
            return true
        end,

        hide = function()
            exports.boii_ui:hide_drawtext()
            return true
        end
    }

    IMPL.okokTextUI = {
        show = function(options)
            if not options or not options.message then return false end
            exports.okokTextUI:Open(options.message, "lightgrey", "left", true)
            return true
        end,

        hide = function()
            exports.okokTextUI:Close()
            return true
        end
    }

    IMPL.es_extended = {
        show = function(options)
            if not options or not options.message then return false end
            exports.es_extended:TextUI(options.message)
            return true
        end,

        hide = function()
            exports.es_extended:HideUI()
            return true
        end
    }

    IMPL["qb-core"] = {
        show = function(options)
            if not options or not options.message then return false end
            exports["qb-core"]:DrawText(options.message)
            return true
        end,

        hide = function()
            exports["qb-core"]:HideText()
            return true
        end
    }
end

return IMPL[ACTIVE_DRAWTEXT] or IMPL.standalone