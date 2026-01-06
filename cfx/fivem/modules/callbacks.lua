--[[
--------------------------------------------------
┏━┓╻  ┏━┓╻ ╻╻┏┓╻┏━╸   ╻┏┓╻   ╺┳╸┏━┓┏━┓┏━╸┏━╸╻┏━╸
┣━┛┃  ┣━┫┗┳┛┃┃┗┫┃╺┓   ┃┃┗┫    ┃ ┣┳┛┣━┫┣╸ ┣╸ ┃┃  
╹  ┗━╸╹ ╹ ╹ ╹╹ ╹┗━┛   ╹╹ ╹    ╹ ╹┗╸╹ ╹╹  ╹  ╹┗━╸
--------------------------------------------------
┏┓┳┓┏┓┏┓┏┳┓
┃┓┣┫┣┫┣  ┃ 
┗┛┛┗┛┗┻  ┻     
--------------------------------------------------

This file is part of GRAFT.
You are free to use these files within your own resources.
Please retain the original credit and attached MIT license.
Support honest development.

Author: Case @ Playing In Traffic
GitHub: https://github.com/playingintraffic/graft

--------------------------------------------------

MIT License

Copyright (c) 2025 Playing In Traffic

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

--------------------------------------------------
]]

--- @module callbacks
--- @description Simple standalone callback registration system.

--- @section Guard

if rawget(_G, "__callbacks_module") then
    return _G.__callbacks_module
end

--- @section Constants

local RESOURCE_NAME = GetCurrentResourceName()
local IS_SERVER = IsDuplicityVersion()

--- @section Module

local m = {}

--- @section Server

if IS_SERVER then

    local sv_callbacks = {}

    --- Registers a server-side callback.
    --- @param name string: The name of the callback event.
    --- @param cb function: The callback function to be executed.
    function m.register(name, cb)
        if not name or type(cb) ~= "function" then
            print(("[callbacks] Failed to register callback: %s"):format(name or "nil"))
            return
        end

        if sv_callbacks[name] then
            print(("[callbacks] Overwriting existing callback: %s"):format(name))
        end

        sv_callbacks[name] = cb
    end

    --- @section Events

    --- Handles client callback requests and executes registered server callbacks.
    --- Sends response back to client via callbacks:cl:response event.
    RegisterServerEvent(RESOURCE_NAME .. ":sv:trigger")
    AddEventHandler(RESOURCE_NAME .. ":sv:trigger", function(name, data, cb_id)
        local source = source
        local callback = sv_callbacks[name]

        if not callback then
            print(("[callbacks] Callback not found: %s"):format(name))
            TriggerClientEvent(RESOURCE_NAME .. ":cl:response", source, cb_id, nil)
            return
        end

        callback(source, data, function(response)
            TriggerClientEvent(RESOURCE_NAME .. ":cl:response", source, cb_id, response)
        end)
    end)

end

--- @section Client

if not IS_SERVER then

    local cl_callbacks = {}
    local cb_id = 0

    --- Triggers a server-side callback from the client.
    --- @param name string: Callback name to trigger
    --- @param data table: Data to send with the callback
    --- @param cb function: Function to handle the servers response
    function m.trigger(name, data, cb)
        if type(cb) ~= "function" then return end
        cb_id = cb_id + 1
        cl_callbacks[cb_id] = cb
        TriggerServerEvent(RESOURCE_NAME .. ":sv:trigger", name, data, cb_id)
    end

    --- @section Events

    --- Handles server callback responses and executes the client-side callback.
    --- Cleans up the callback after execution to prevent memory leaks.
    RegisterNetEvent(RESOURCE_NAME .. ":cl:response")
    AddEventHandler(RESOURCE_NAME .. ":cl:response", function(id, response)
        local callback = cl_callbacks[id]

        if not callback then
            print(("[callbacks] Callback response received but callback not found: %s"):format(id))
            return
        end

        cl_callbacks[id] = nil
        callback(response)
    end)

end

_G.__callbacks_module = m
return _G.__callbacks_module