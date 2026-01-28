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

--- @module commands
--- @description ACE permission-based command registration with chat suggestion support.

--- @section Guard

if rawget(_G, "__commands_module") then
    return _G.__commands_module
end

--- @section Constants

local RESOURCE_NAME = GetCurrentResourceName()
local IS_SERVER = IsDuplicityVersion()
local DEV_MODE = GetConvar("commands:dev_mode", "false") == "true"

--- @section Module

local m = {}
_G.__commands_module = m

--- @section Server

if IS_SERVER then

    local chat_suggestions = {}

    --- Checks if a player has the required ACE permission.
    --- @param source number: Player source ID.
    --- @param required_ace string|table|nil: ACE permission(s) required.
    --- @return boolean: True if player has permission.
    local function has_permission(source, required_ace)
        if DEV_MODE then return true end
        if not required_ace then return true end

        local aces = type(required_ace) == "table" and required_ace or { required_ace }

        for _, ace in ipairs(aces) do
            if IsPlayerAceAllowed(source, ace) then
                return true
            end
        end

        return false
    end

    --- Registers a chat suggestion for autocomplete.
    --- @param command string: Command name.
    --- @param help string: Help description.
    --- @param params table: Parameter definitions.
    local function register_chat_suggestion(command, help, params)
        chat_suggestions[#chat_suggestions + 1] = {
            command = command,
            help = help,
            params = params
        }
    end

    --- Registers a command with ACE permission checks.
    --- @param opts table: Command options.
    --- @field name string: Command name (without /).
    --- @field ace string|table|nil: ACE permission(s) or nil for public command.
    --- @field help string: Help description for chat suggestions.
    --- @field params table: Parameter definitions for chat suggestions.
    --- @field handler function: Command handler (source, args, raw).
    function m.register(opts)
        if not opts or not opts.name or not opts.handler then
            print("[commands] Registration failed: missing name or handler")
            return false
        end

        if opts.help and opts.params then
            register_chat_suggestion(opts.name, opts.help, opts.params)
        end

        RegisterCommand(opts.name, function(source, args, raw)
            if has_permission(source, opts.ace) then
                opts.handler(source, args, raw)
            else
                TriggerClientEvent("chat:addMessage", source, {
                    args = { "^1PERMISSION DENIED", "You don't have permission to use this command." }
                })
            end
        end, false)

        return true
    end

    --- @section Events

    --- Sends chat suggestions to a client.
    RegisterServerEvent(RESOURCE_NAME .. "sv:get_suggestions")
    AddEventHandler(RESOURCE_NAME .. "sv:get_suggestions", function()
        local src = source
        local formatted = {}

        for _, suggestion in ipairs(chat_suggestions) do
            formatted[#formatted + 1] = {
                name = "/" .. suggestion.command,
                help = suggestion.help,
                params = suggestion.params
            }
        end

        TriggerClientEvent("chat:addSuggestions", src, formatted)
    end)

end

--- @section Client

if not IS_SERVER then

    --- Requests command suggestions from the server.
    function m.get_suggestions()
        TriggerServerEvent(RESOURCE_NAME .. "sv:get_suggestions")
    end

end

return m