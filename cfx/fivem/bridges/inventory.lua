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

--- @module bridges.inventory
--- @description Handles a variety of commonly used inventory systems.
--- Used by the framework bridge for inventory functions first if included.
--- Not required for servers just running basic settings only for ones with custom resources.

--- @section Constants

local AUTO_DETECT_INVENTORY = GetConvar("bridge:inventory:auto_detect", "true") == "true"
local ACTIVE_INVENTORY = GetConvar("bridge:inventory:active", "standalone")

--- @section Mapping

local INVENTORIES = {
    "ox_inventory",
    "pit_inventory"
}

--- @section Initialization

if AUTO_DETECT_INVENTORY then
    for _, resource in ipairs(INVENTORIES) do
        if GetResourceState(resource) == "started" then
            ACTIVE_INVENTORY = resource
            break
        end
    end
end

--- @section Implementations

local IS_SERVER = IsDuplicityVersion()
local IMPL = {}

if IS_SERVER then
    IMPL.ox_inventory = {
        get_inventory = function(source)
            return exports.ox_inventory:GetInventory(source, false)
        end,

        get_item = function(source, item_name)
            local item = exports.ox_inventory:GetItem(source, item_name, nil, false)
            return item and item.count and item.count > 0 and item or nil
        end,

       has_item = function(source, item_name, item_amount)
            local required_amount = item_amount or 1
            local count = exports.ox_inventory:GetItemCount(source, item_name, nil, false)
            return count >= required_amount
        end,

        add_item = function(source, item_id, amount, data)
            return exports.ox_inventory:AddItem(source, item_id, amount, data)
        end,

        remove_item = function(source, item_id, amount)
            return exports.ox_inventory:RemoveItem(source, item_id, amount)
        end,

        update_item_data = function(source, item_id, updates)
            local items = exports.ox_inventory:Search(source, 1, item_id)
            if type(items) ~= "table" then return false end

            for _, v in pairs(items) do
                local metadata = v.metadata or {}

                for key, value in pairs(updates) do
                    metadata[key] = value
                end

                exports.ox_inventory:SetMetadata(source, v.slot, metadata)
                return true
            end

            return false
        end,

        register_item = function(item, cb) 
            if not item or type(cb) ~= "function" then return false end
            
            exports(item, function(event, itemData, inventory, slot, data)
                local src = inventory.id or source
                if event == "usedItem" then
                    cb(src, itemData, slot, data)
                end
            end)
            
            return true
        end,
    }

    IMPL.pit_inventory = {
        get_inventory = function(source)
            print("[pit_inventory] get_inventory - Not implemented")
            return {}
        end,

        get_item = function(source, item_name)
            print("[pit_inventory] get_item - Not implemented")
            return nil
        end,

        has_item = function(source, item_name, item_amount)
            print("[pit_inventory] has_item - Not implemented")
            return false
        end,

        add_item = function(source, item_id, amount, data)
            print("[pit_inventory] add_item - Not implemented")
            return false
        end,

        remove_item = function(source, item_id, amount)
            print("[pit_inventory] remove_item - Not implemented")
            return false
        end,

        update_item_data = function(source, item_id, updates)
            print("[pit_inventory] update_item_data - Not implemented")
            return false
        end,

        register_item = function(item, cb)
            print("[pit_inventory] register_item - Not implemented")
            return false
        end,
    }
end

return IMPL[ACTIVE_INVENTORY]