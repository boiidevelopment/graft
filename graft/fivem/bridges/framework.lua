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

--- @module bridges.framework
--- @description Collection of functions to bridge the common fivem framework.
--- If you need to add custom implementation copy the format, it should be easy enough.

--- @section Guard

if rawget(_G, "__bridges_fw_module") then
    return _G.__bridges_fw_module
end

--- @section Constants

local AUTO_DETECT_FRAMEWORK = GetConvar("bridge:framework:auto_detect", "true") == "true"
local ACTIVE_FRAMEWORK = GetConvar("bridge:framework:active", "standalone")

--- @section Mapping

local FRAMEWORKS = {
    "es_extended",
    "ND_Core",
    "ox_core",
    "qbx_core",
    "qb-core",
}

--- @section Internal Safe Require

local function safe_require(path)
    local file_path = path:gsub("%.", "/") .. ".lua"
    local file = LoadResourceFile(GetCurrentResourceName(), file_path)
    if not file then return nil end
    
    local chunk, err = load(file, path)
    if not chunk then return nil end
    
    local ok, result = pcall(chunk)
    return ok and result or nil
end

--- @section Initialization

if AUTO_DETECT_FRAMEWORK then
    for _, resource in ipairs(FRAMEWORKS) do
        if GetResourceState(resource) == "started" then
            ACTIVE_FRAMEWORK = resource
            print("[fw bridge] active framework: " .. resource)
            break
        end
    end
end

--- @section Inventory Bridge
--- @description Make sure you update INVENTORY_BRIDGE_PATH to your file path to the inventory bridge if required.

local INVENTORY_BRIDGE_PATH = "cfx.fivem.bridges.inventory"
local INVENTORY_BRIDGE = safe_require(INVENTORY_BRIDGE_PATH)

--- @section Framework Objects

local FW_OBJECTS = {
    es_extended = function() return exports.es_extended:getSharedObject() end,
    ["qb-core"] = function() return exports['qb-core']:GetCoreObject() end,
    qbx_core = function() return exports['qb-core']:GetCoreObject() end,
    ND_Core = function() return exports.ND_Core end
}

local FW = FW_OBJECTS[ACTIVE_FRAMEWORK] and FW_OBJECTS[ACTIVE_FRAMEWORK]() or nil

--- @section Implementations

local IS_SERVER = IsDuplicityVersion()
local IMPL = {}

--- @section Server

if IS_SERVER then

    --- @section Standalone

    IMPL.standalone = {
        -- Players
        get_players = function() 
            return GetPlayers() 
        end,

        get_player = function(source) 
            -- No framework player object in standalone
            return {
                source = source,
                name = GetPlayerName(source),
                identifier = GetPlayerIdentifierByType(source, "license2") or GetPlayerIdentifierByType(source, "license")
            }
        end,

        -- Database
        get_id_params = function(source) 
            local identifier = GetPlayerIdentifierByType(source, "license2") or GetPlayerIdentifierByType(source, "license")
            return "identifier = ?", { identifier }
        end,

        -- Identity
        get_player_id = function(source)
            return GetPlayerIdentifierByType(source, "license2") or GetPlayerIdentifierByType(source, "license")
        end,

        get_identity = function(source) 
            return {
                first_name = GetPlayerName(source),
                last_name = "",
                dob = "",
                sex = "",
                nationality = ""
            }
        end,

        get_identity_by_id = function(unique_id)
            print("[standalone] get_identity_by_id - Database integration required")
            return nil
        end,

        -- Inventory (requires inventory system)
        get_inventory = function(source) 
            print("[standalone] get_inventory - Inventory system required")
            return {}
        end,

        get_item = function(source, item_name) 
            print("[standalone] get_item - Inventory system required")
            return nil
        end,

        has_item = function(source, item_name, item_amount) 
            print("[standalone] has_item - Inventory system required")
            return false
        end,

        add_item = function(source, item_id, amount, data) 
            print("[standalone] add_item - Inventory system required")
            return false
        end,

        remove_item = function(source, item_id, amount) 
            print("[standalone] remove_item - Inventory system required")
            return false
        end,

        update_item_data = function(source, item_id, updates) 
            print("[standalone] update_item_data - Inventory system required")
            return false
        end,

        register_item = function(item, cb) 
            print("[standalone] register_item - Item registration system required")
            return false
        end,

        -- Balances (requires economy system)
        get_balances = function(source) 
            print("[standalone] get_balances - Economy system required")
            return {}
        end,

        get_balance_by_type = function(source, balance_type) 
            print("[standalone] get_balance_by_type - Economy system required")
            return 0
        end,

        add_balance = function(source, balance_type, amount) 
            print("[standalone] add_balance - Economy system required")
            return false
        end,

        remove_balance = function(source, balance_type, amount) 
            print("[standalone] remove_balance - Economy system required")
            return false
        end,

        -- Jobs (requires job system)
        get_player_jobs = function(source) 
            print("[standalone] get_player_jobs - Job system required")
            return {}
        end,

        player_has_job = function(source, job_names, check_on_duty) 
            print("[standalone] player_has_job - Job system required")
            return false
        end,

        get_player_job_grade = function(source, job_id) 
            print("[standalone] get_player_job_grade - Job system required")
            return nil
        end,

        count_players_by_job = function(job_names, check_on_duty) 
            print("[standalone] count_players_by_job - Job system required")
            return 0, 0
        end,

        get_player_job_name = function(source) 
            print("[standalone] get_player_job_name - Job system required")
            return nil
        end,

        -- Statuses (requires status system)
        adjust_statuses = function(source, statuses) 
            print("[standalone] adjust_statuses - Status system required")
            return false
        end
    }

    --- @section ESX

    IMPL.es_extended = {
        -- Players
        get_players = function() 
            return FW.GetPlayers()
        end,

        get_player = function(source) 
            return FW.GetPlayerFromId(source)
        end,

        -- Database
        get_id_params = function(source) 
            local player = FW.GetPlayerFromId(source)
            if not player then return "1=1", {} end
            return "identifier = ?", { player.identifier }
        end,

        -- Identity
        get_player_id = function(source)
            local player = FW.GetPlayerFromId(source)
            if not player then return false end
            return player.identifier
        end,

        get_identity = function(source) 
            local player = FW.GetPlayerFromId(source)
            if not player then return false end
            
            return {
                first_name = player.variables.firstName,
                last_name = player.variables.lastName,
                dob = player.variables.dateofbirth,
                sex = player.variables.sex,
                nationality = "LS, Los Santos"
            }
        end,

        get_identity_by_id = function(unique_id)
            local players = FW.GetPlayers()
            
            for _, player_source in ipairs(players) do
                local source = type(player_source) == "table" and player_source.source or player_source
                local player = FW.GetPlayerFromId(source)
                
                if player and player.identifier == unique_id then
                    return {
                        first_name = player.variables.firstName,
                        last_name = player.variables.lastName,
                        dob = player.variables.dateofbirth,
                        sex = player.variables.sex,
                        nationality = "LS, Los Santos"
                    }
                end
            end
            
            return nil
        end,

        -- Inventory
        get_inventory = function(source)
            if INVENTORY_BRIDGE and INVENTORY_BRIDGE.get_inventory then
                return INVENTORY_BRIDGE.get_inventory(source)
            end

            local player = FW.GetPlayerFromId(source)
            if not player then return {} end
            return player.getInventory()
        end,

        get_item = function(source, item_name)
            if INVENTORY_BRIDGE and INVENTORY_BRIDGE.get_item then
                return INVENTORY_BRIDGE.get_item(source, item_name)
            end

            local player = FW.GetPlayerFromId(source)
            if not player then return nil end
            return player.getInventoryItem(item_name)
        end,

        has_item = function(source, item_name, item_amount)
            if INVENTORY_BRIDGE and INVENTORY_BRIDGE.has_item then
                return INVENTORY_BRIDGE.has_item(source, item_name, item_amount)
            end

            local required_amount = item_amount or 1
            local player = FW.GetPlayerFromId(source)
            if not player then return false end
            
            local item = player.getInventoryItem(item_name)
            return item and item.count >= required_amount
        end,

        add_item = function(source, item_id, amount, data)
            if INVENTORY_BRIDGE and INVENTORY_BRIDGE.add_item then
                return INVENTORY_BRIDGE.add_item(source, item_id, amount, data)
            end

            local player = FW.GetPlayerFromId(source)
            if not player then return false end
            return player.addInventoryItem(item_id, amount)
        end,

        remove_item = function(source, item_id, amount)
            if INVENTORY_BRIDGE and INVENTORY_BRIDGE.remove_item then
                return INVENTORY_BRIDGE.remove_item(source, item_id, amount)
            end

            local player = FW.GetPlayerFromId(source)
            if not player then return false end
            return player.removeInventoryItem(item_id, amount)
        end,

        update_item_data = function(source, item_id, updates)
            if INVENTORY_BRIDGE and INVENTORY_BRIDGE.update_item_data then
                return INVENTORY_BRIDGE.update_item_data(source, item_id, updates)
            end

            print("[es_extended] update_item_data - Native ESX inventory doesn't support metadata updates")
            return false
        end,

        register_item = function(item, cb) 
            if INVENTORY_BRIDGE and INVENTORY_BRIDGE.register_item then
                return INVENTORY_BRIDGE.register_item(item, cb)
            end

            if not item then return false end
            
            FW.RegisterUsableItem(item, function(source)
                cb(source)
            end)
            return true
        end,

        -- Balances
        get_balances = function(source) 
            local player = FW.GetPlayerFromId(source)
            if not player then return {} end

            local balances = {}
            for _, account in pairs(player.getAccounts()) do
                balances[account.name] = account.money
            end

            return balances
        end,

        get_balance_by_type = function(source, balance_type) 
            local player = FW.GetPlayerFromId(source)
            if not player then return 0 end

            if balance_type == "cash" or balance_type == "money" then
                local cash_item = player.getInventoryItem("money")
                return cash_item and cash_item.count or 0
            end

            local account = player.getAccount(balance_type)
            return account and account.money or 0
        end,

        add_balance = function(source, balance_type, amount) 
            local player = FW.GetPlayerFromId(source)
            if not player then return false end

            if balance_type == "cash" or balance_type == "money" then
                player.addInventoryItem("money", amount)
            else
                player.addAccountMoney(balance_type, amount)
            end
            return true
        end,

        remove_balance = function(source, balance_type, amount) 
            local player = FW.GetPlayerFromId(source)
            if not player then return false end

            if balance_type == "cash" or balance_type == "money" then
                player.removeInventoryItem("money", amount)
            else
                player.removeAccountMoney(balance_type, amount)
            end
            return true
        end,

        -- Jobs
        get_player_jobs = function(source) 
            local player = FW.GetPlayerFromId(source)
            if not player then return {} end
            return player.getJob()
        end,

        player_has_job = function(source, job_names, check_on_duty) 
            local player = FW.GetPlayerFromId(source)
            if not player then return false end

            local job = player.getJob()
            
            for _, job_name in ipairs(job_names) do
                if job.name == job_name then
                    if check_on_duty then
                        return job.onduty == true
                    end
                    return true
                end
            end
            
            return false
        end,

        get_player_job_grade = function(source, job_id) 
            local player = FW.GetPlayerFromId(source)
            if not player then return nil end

            local job = player.getJob()
            if job.name == job_id then
                return job.grade
            end
            return nil
        end,

        count_players_by_job = function(job_names, check_on_duty) 
            local players = FW.GetPlayers()
            local total_with_job = 0
            local total_on_duty = 0

            for _, player_source in ipairs(players) do
                local source = type(player_source) == "table" and player_source.source or player_source
                local player = FW.GetPlayerFromId(source)
                
                if player then
                    local job = player.getJob()
                    for _, job_name in ipairs(job_names) do
                        if job.name == job_name then
                            total_with_job = total_with_job + 1
                            if job.onduty then
                                total_on_duty = total_on_duty + 1
                            end
                            break
                        end
                    end
                end
            end

            return total_with_job, total_on_duty
        end,

        get_player_job_name = function(source) 
            local player = FW.GetPlayerFromId(source)
            if not player then return nil end

            local job = player.getJob()
            return job.name
        end,

        -- Statuses
        adjust_statuses = function(source, statuses) 
            local player = FW.GetPlayerFromId(source)
            if not player then return false end

            local status_map = { armour = "armor", armor = "armour" }
            local esx_max_value = 1000000
            local scale = esx_max_value / 100

            for key, mod in pairs(statuses) do
                local status_key = status_map[key] or key
                local status_found = false
                local add_value = (mod.add and mod.add.min and mod.add.max) and math.random(mod.add.min, mod.add.max) or 0
                local remove_value = (mod.remove and mod.remove.min and mod.remove.max) and math.random(mod.remove.min, mod.remove.max) or 0
                local change_value = add_value - remove_value

                if player.metadata[status_key] then
                    local current = player.metadata[status_key]
                    local new_value = math.min(100, math.max(0, current + change_value))
                    player.set(status_key, new_value)
                    status_found = true
                end

                if not status_found then
                    for _, stat in pairs(player.variables.status) do
                        if stat.name == status_key then
                            local current = stat.val / scale
                            local new_value = math.min(100, math.max(0, current + change_value))
                            local scaled_value = new_value * scale
                            stat.val = scaled_value
                            player.set("status", player.variables.status)
                            TriggerClientEvent("esx_status:set", source, status_key, scaled_value)
                            TriggerEvent("esx_status:update", source, status_key, scaled_value)
                            TriggerEvent("esx_status:updateClient", source)
                            status_found = true
                            break
                        end
                    end
                end
            end
            return true
        end
    }

    --- @section ND Core

    IMPL.ND_Core = {
        -- Players
        get_players = function() 
            return FW:getPlayers()
        end,

        get_player = function(source) 
            return FW:getPlayer(source)
        end,

        -- Database
        get_id_params = function(source) 
            local player = FW:getPlayer(source)
            if not player then return "1=1", {} end
            return "identifier = ?", { player.identifier }
        end,

        -- Identity
        get_player_id = function(source)
            local player = FW:getPlayer(source)
            if not player then return false end
            return player.identifier
        end,

        get_identity = function(source) 
            local player = FW:getPlayer(source)
            if not player then return false end
            
            return {
                first_name = player.firstname,
                last_name = player.lastname,
                dob = player.dob,
                sex = player.gender,
                nationality = "LS, Los Santos"
            }
        end,

        get_identity_by_id = function(unique_id)
            local players = FW:getPlayers()
            
            for _, player_source in ipairs(players) do
                local source = type(player_source) == "table" and player_source.source or player_source
                local player = FW:getPlayer(source)
                
                if player and player.identifier == unique_id then
                    return {
                        first_name = player.firstname,
                        last_name = player.lastname,
                        dob = player.dob,
                        sex = player.gender,
                        nationality = "LS, Los Santos"
                    }
                end
            end
            
            return nil
        end,

        -- Inventory
        get_inventory = function(source)
            if INVENTORY_BRIDGE and INVENTORY_BRIDGE.get_inventory then
                return INVENTORY_BRIDGE.get_inventory(source)
            end

            print("[ND_Core] get_inventory - No native ND inventory implementation")
            return {}
        end,

        get_item = function(source, item_name)
            if INVENTORY_BRIDGE and INVENTORY_BRIDGE.get_item then
                return INVENTORY_BRIDGE.get_item(source, item_name)
            end

            print("[ND_Core] get_item - No native ND inventory implementation")
            return nil
        end,

        has_item = function(source, item_name, item_amount)
            if INVENTORY_BRIDGE and INVENTORY_BRIDGE.has_item then
                return INVENTORY_BRIDGE.has_item(source, item_name, item_amount)
            end

            print("[ND_Core] has_item - No native ND inventory implementation")
            return false
        end,

        add_item = function(source, item_id, amount, data)
            if INVENTORY_BRIDGE and INVENTORY_BRIDGE.add_item then
                return INVENTORY_BRIDGE.add_item(source, item_id, amount, data)
            end

            print("[ND_Core] add_item - No native ND inventory implementation")
            return false
        end,

        remove_item = function(source, item_id, amount)
            if INVENTORY_BRIDGE and INVENTORY_BRIDGE.remove_item then
                return INVENTORY_BRIDGE.remove_item(source, item_id, amount)
            end

            print("[ND_Core] remove_item - No native ND inventory implementation")
            return false
        end,

        update_item_data = function(source, item_id, updates)
            if INVENTORY_BRIDGE and INVENTORY_BRIDGE.update_item_data then
                return INVENTORY_BRIDGE.update_item_data(source, item_id, updates)
            end

            print("[ND_Core] update_item_data - No native ND inventory implementation")
            return false
        end,

        register_item = function(item, cb)
            if INVENTORY_BRIDGE and INVENTORY_BRIDGE.register_item then
                return INVENTORY_BRIDGE.register_item(item, cb)
            end 

            print("[ND_Core] register_item - No native ND inventory implementation")
            return false
        end,

        -- Balances
        get_balances = function(source) 
            local player = FW:getPlayer(source)
            if not player then return {} end

            return { 
                cash = player.cash, 
                bank = player.bank 
            }
        end,

        get_balance_by_type = function(source, balance_type) 
            local player = FW:getPlayer(source)
            if not player then return 0 end

            if balance_type == "cash" or balance_type == "money" then
                return player.cash or 0
            end

            if balance_type == "bank" then
                return player.bank or 0
            end

            return 0
        end,

        add_balance = function(source, balance_type, amount) 
            local player = FW:getPlayer(source)
            if not player then return false end

            player.addMoney(balance_type, amount)
            return true
        end,

        remove_balance = function(source, balance_type, amount) 
            local player = FW:getPlayer(source)
            if not player then return false end

            player.deductMoney(balance_type, amount)
            return true
        end,

        -- Jobs
        get_player_jobs = function(source) 
            local player = FW:getPlayer(source)
            if not player then return {} end
            return player.getJob()
        end,

        player_has_job = function(source, job_names, check_on_duty) 
            local player = FW:getPlayer(source)
            if not player then return false end

            local job = player.getJob()
            
            for _, job_name in ipairs(job_names) do
                if job.name == job_name then
                    -- ND doesn't have on-duty status in the same way
                    return true
                end
            end
            
            return false
        end,

        get_player_job_grade = function(source, job_id) 
            local player = FW:getPlayer(source)
            if not player then return nil end

            local job = player.getJob()
            if job.name == job_id then
                return job.rank
            end
            return nil
        end,

        count_players_by_job = function(job_names, check_on_duty) 
            local players = FW:getPlayers()
            local total_with_job = 0
            local total_on_duty = 0

            for _, player_source in ipairs(players) do
                local source = type(player_source) == "table" and player_source.source or player_source
                local player = FW:getPlayer(source)
                
                if player then
                    local job = player.getJob()
                    for _, job_name in ipairs(job_names) do
                        if job.name == job_name then
                            total_with_job = total_with_job + 1
                            total_on_duty = total_on_duty + 1 -- ND doesn't track on-duty
                            break
                        end
                    end
                end
            end

            return total_with_job, total_on_duty
        end,

        get_player_job_name = function(source) 
            local player = FW:getPlayer(source)
            if not player then return nil end

            local job = player.getJob()
            return job.name
        end,

        -- Statuses
        adjust_statuses = function(source, statuses) 
            print("[ND_Core] adjust_statuses - Not implemented")
            return false
        end
    }

    --- @section QB Core

    IMPL["qb-core"] = {
        -- Players
        get_players = function() 
            return FW.Functions.GetPlayers()
        end,

        get_player = function(source) 
            return FW.Functions.GetPlayer(source)
        end,

        -- Database
        get_id_params = function(source) 
            local player = FW.Functions.GetPlayer(source)
            if not player then return "1=1", {} end
            return "citizenid = ?", { player.PlayerData.citizenid }
        end,

        -- Identity
        get_player_id = function(source)
            local player = FW.Functions.GetPlayer(source)
            if not player then return false end
            return player.PlayerData.citizenid
        end,

        get_identity = function(source) 
            local player = FW.Functions.GetPlayer(source)
            if not player then return false end
            
            return {
                first_name = player.PlayerData.charinfo.firstname,
                last_name = player.PlayerData.charinfo.lastname,
                dob = player.PlayerData.charinfo.birthdate,
                sex = player.PlayerData.charinfo.gender,
                nationality = player.PlayerData.charinfo.nationality
            }
        end,

        get_identity_by_id = function(unique_id)
            local players = FW.Functions.GetPlayers()
            
            for _, player_source in ipairs(players) do
                local player = FW.Functions.GetPlayer(player_source)
                
                if player and player.PlayerData.citizenid == unique_id then
                    return {
                        first_name = player.PlayerData.charinfo.firstname,
                        last_name = player.PlayerData.charinfo.lastname,
                        dob = player.PlayerData.charinfo.birthdate,
                        sex = player.PlayerData.charinfo.gender,
                        nationality = player.PlayerData.charinfo.nationality
                    }
                end
            end
            
            return nil
        end,

        -- Inventory
        get_inventory = function(source)
            if INVENTORY_BRIDGE and INVENTORY_BRIDGE.get_inventory then
                return INVENTORY_BRIDGE.get_inventory(source)
            end

            local player = FW.Functions.GetPlayer(source)
            if not player then return {} end
            return player.PlayerData.inventory or {}
        end,

        get_item = function(source, item_name)
            if INVENTORY_BRIDGE and INVENTORY_BRIDGE.get_item then
                return INVENTORY_BRIDGE.get_item(source, item_name)
            end

            local player = FW.Functions.GetPlayer(source)
            if not player then return nil end
            return player.Functions.GetItemByName(item_name)
        end,

        has_item = function(source, item_name, item_amount)
            if INVENTORY_BRIDGE and INVENTORY_BRIDGE.has_item then
                return INVENTORY_BRIDGE.has_item(source, item_name, item_amount)
            end

            local required_amount = item_amount or 1
            local player = FW.Functions.GetPlayer(source)
            if not player then return false end
            
            local item = player.Functions.GetItemByName(item_name)
            return item and item.amount >= required_amount
        end,

        add_item = function(source, item_id, amount, data)
            if INVENTORY_BRIDGE and INVENTORY_BRIDGE.add_item then
                return INVENTORY_BRIDGE.add_item(source, item_id, amount, data)
            end

            local player = FW.Functions.GetPlayer(source)
            if not player then return false end

            player.Functions.AddItem(item_id, amount, nil, data)
            TriggerClientEvent("qb-inventory:client:ItemBox", source, FW.Shared.Items[item_id], "add", amount)
            return true
        end,

        remove_item = function(source, item_id, amount)
            if INVENTORY_BRIDGE and INVENTORY_BRIDGE.remove_item then
                return INVENTORY_BRIDGE.remove_item(source, item_id, amount)
            end

            local player = FW.Functions.GetPlayer(source)
            if not player then return false end

            player.Functions.RemoveItem(item_id, amount)
            TriggerClientEvent("qb-inventory:client:ItemBox", source, FW.Shared.Items[item_id], "remove", amount)
            return true
        end,

        update_item_data = function(source, item_id, updates)
            if INVENTORY_BRIDGE and INVENTORY_BRIDGE.update_item_data then
                return INVENTORY_BRIDGE.update_item_data(source, item_id, updates)
            end

            for key, value in pairs(updates) do
                exports["qb-inventory"]:SetItemData(source, item_id, key, value)
            end
            return true
        end,

        register_item = function(item, cb)
            if INVENTORY_BRIDGE and INVENTORY_BRIDGE.register_item then
                return INVENTORY_BRIDGE.register_item(item, cb)
            end

            if not item then return false end
            
            FW.Functions.CreateUseableItem(item, function(source)
                cb(source)
            end)
            return true
        end,

        -- Balances
        get_balances = function(source) 
            local player = FW.Functions.GetPlayer(source)
            if not player then return {} end
            return player.PlayerData.money or {}
        end,

        get_balance_by_type = function(source, balance_type) 
            local player = FW.Functions.GetPlayer(source)
            if not player then return 0 end

            local balances = player.PlayerData.money
            return balances and balances[balance_type] or 0
        end,

        add_balance = function(source, balance_type, amount) 
            local player = FW.Functions.GetPlayer(source)
            if not player then return false end

            player.Functions.AddMoney(balance_type, amount)
            return true
        end,

        remove_balance = function(source, balance_type, amount) 
            local player = FW.Functions.GetPlayer(source)
            if not player then return false end

            player.Functions.RemoveMoney(balance_type, amount)
            return true
        end,

        -- Jobs
        get_player_jobs = function(source) 
            local player = FW.Functions.GetPlayer(source)
            if not player then return {} end
            return player.PlayerData.job or {}
        end,

        player_has_job = function(source, job_names, check_on_duty) 
            local player = FW.Functions.GetPlayer(source)
            if not player then return false end

            local job = player.PlayerData.job
            
            for _, job_name in ipairs(job_names) do
                if job.name == job_name then
                    if check_on_duty then
                        return job.onduty == true
                    end
                    return true
                end
            end
            
            return false
        end,

        get_player_job_grade = function(source, job_id) 
            local player = FW.Functions.GetPlayer(source)
            if not player then return nil end

            local job = player.PlayerData.job
            if job.name == job_id then
                return job.grade.level
            end
            return nil
        end,

        count_players_by_job = function(job_names, check_on_duty) 
            local players = FW.Functions.GetPlayers()
            local total_with_job = 0
            local total_on_duty = 0

            for _, player_source in ipairs(players) do
                local player = FW.Functions.GetPlayer(player_source)
                
                if player then
                    local job = player.PlayerData.job
                    for _, job_name in ipairs(job_names) do
                        if job.name == job_name then
                            total_with_job = total_with_job + 1
                            if job.onduty then
                                total_on_duty = total_on_duty + 1
                            end
                            break
                        end
                    end
                end
            end

            return total_with_job, total_on_duty
        end,

        get_player_job_name = function(source) 
            local player = FW.Functions.GetPlayer(source)
            if not player then return nil end

            local job = player.PlayerData.job
            return job.name
        end,

        -- Statuses
        adjust_statuses = function(source, statuses) 
            local player = FW.Functions.GetPlayer(source)
            if not player then return false end

            local meta = player.PlayerData.metadata
            
            for key, mod in pairs(statuses) do
                local status_key = (key == "armor" and "armour") or key
                local add_value = (mod.add and mod.add.min and mod.add.max) and math.random(mod.add.min, mod.add.max) or 0
                local remove_value = (mod.remove and mod.remove.min and mod.remove.max) and math.random(mod.remove.min, mod.remove.max) or 0
                local change_value = add_value - remove_value
                local current = meta[status_key] or 0
                local new_value = math.min(100, math.max(0, current + change_value))

                if status_key == "stress" then
                    if change_value > 0 then
                        TriggerEvent("hud:server:GainStress", change_value, source)
                    else
                        TriggerEvent("hud:server:RelieveStress", -change_value, source)
                    end
                end

                if status_key == "hunger" or status_key == "thirst" then
                    TriggerClientEvent("hud:client:UpdateNeeds", source, meta.hunger, meta.thirst)
                end

                player.Functions.SetMetaData(status_key, new_value)
            end
            
            return true
        end
    }

    --- @section QBX Core

    IMPL.qbx_core = {
        -- Players
        get_players = function() 
            return FW.Functions.GetPlayers()
        end,

        get_player = function(source) 
            return FW.Functions.GetPlayer(source)
        end,

        -- Database
        get_id_params = function(source) 
            local player = FW.Functions.GetPlayer(source)
            if not player then return "1=1", {} end
            return "citizenid = ?", { player.PlayerData.citizenid }
        end,

        -- Identity
        get_player_id = function(source)
            local player = FW.Functions.GetPlayer(source)
            if not player then return false end
            return player.PlayerData.citizenid
        end,

        get_identity = function(source) 
            local player = FW.Functions.GetPlayer(source)
            if not player then return false end
            
            return {
                first_name = player.PlayerData.charinfo.firstname,
                last_name = player.PlayerData.charinfo.lastname,
                dob = player.PlayerData.charinfo.birthdate,
                sex = player.PlayerData.charinfo.gender,
                nationality = player.PlayerData.charinfo.nationality
            }
        end,

        get_identity_by_id = function(unique_id)
            local players = FW.Functions.GetPlayers()
            
            for _, player_source in ipairs(players) do
                local player = FW.Functions.GetPlayer(player_source)
                
                if player and player.PlayerData.citizenid == unique_id then
                    return {
                        first_name = player.PlayerData.charinfo.firstname,
                        last_name = player.PlayerData.charinfo.lastname,
                        dob = player.PlayerData.charinfo.birthdate,
                        sex = player.PlayerData.charinfo.gender,
                        nationality = player.PlayerData.charinfo.nationality
                    }
                end
            end
            
            return nil
        end,

        -- Inventory
        get_inventory = function(source)
            if INVENTORY_BRIDGE and INVENTORY_BRIDGE.get_inventory then
                return INVENTORY_BRIDGE.get_inventory(source)
            end

            print("[qbx_core] get_inventory - No native QBX inventory implementation")
            return {}
        end,

        get_item = function(source, item_name)
            if INVENTORY_BRIDGE and INVENTORY_BRIDGE.get_item then
                return INVENTORY_BRIDGE.get_item(source, item_name)
            end

            print("[qbx_core] get_item - No native QBX inventory implementation")
            return nil
        end,

        has_item = function(source, item_name, item_amount)
            if INVENTORY_BRIDGE and INVENTORY_BRIDGE.has_item then
                return INVENTORY_BRIDGE.has_item(source, item_name, item_amount)
            end

            print("[qbx_core] has_item - No native QBX inventory implementation")
            return false
        end,

        add_item = function(source, item_id, amount, data)
            if INVENTORY_BRIDGE and INVENTORY_BRIDGE.add_item then
                return INVENTORY_BRIDGE.add_item(source, item_id, amount, data)
            end

            print("[qbx_core] add_item - No native QBX inventory implementation")
            return false
        end,

        remove_item = function(source, item_id, amount)
            if INVENTORY_BRIDGE and INVENTORY_BRIDGE.remove_item then
                return INVENTORY_BRIDGE.remove_item(source, item_id, amount)
            end

            print("[qbx_core] remove_item - No native QBX inventory implementation")
            return false
        end,

        update_item_data = function(source, item_id, updates)
            if INVENTORY_BRIDGE and INVENTORY_BRIDGE.update_item_data then
                return INVENTORY_BRIDGE.update_item_data(source, item_id, updates)
            end

            print("[qbx_core] update_item_data - No native QBX inventory implementation")
            return false
        end,

        register_item = function(item, cb)
            if INVENTORY_BRIDGE and INVENTORY_BRIDGE.register_item then
                return INVENTORY_BRIDGE.register_item(item, cb)
            end
             
            if not item then return false end
            
            FW.Functions.CreateUseableItem(item, function(source)
                cb(source)
            end)
            return true
        end,

        -- Balances
        get_balances = function(source) 
            local player = FW.Functions.GetPlayer(source)
            if not player then return {} end
            return player.PlayerData.money or {}
        end,

        get_balance_by_type = function(source, balance_type) 
            local player = FW.Functions.GetPlayer(source)
            if not player then return 0 end

            local balances = player.PlayerData.money
            return balances and balances[balance_type] or 0
        end,

        add_balance = function(source, balance_type, amount) 
            local player = FW.Functions.GetPlayer(source)
            if not player then return false end

            player.Functions.AddMoney(balance_type, amount)
            return true
        end,

        remove_balance = function(source, balance_type, amount) 
            local player = FW.Functions.GetPlayer(source)
            if not player then return false end

            player.Functions.RemoveMoney(balance_type, amount)
            return true
        end,

        -- Jobs
        get_player_jobs = function(source) 
            local player = FW.Functions.GetPlayer(source)
            if not player then return {} end
            return player.PlayerData.job or {}
        end,

        player_has_job = function(source, job_names, check_on_duty) 
            local player = FW.Functions.GetPlayer(source)
            if not player then return false end

            local job = player.PlayerData.job
            
            for _, job_name in ipairs(job_names) do
                if job.name == job_name then
                    if check_on_duty then
                        return job.onduty == true
                    end
                    return true
                end
            end
            
            return false
        end,

        get_player_job_grade = function(source, job_id) 
            local player = FW.Functions.GetPlayer(source)
            if not player then return nil end

            local job = player.PlayerData.job
            if job.name == job_id then
                return job.grade.level
            end
            return nil
        end,

        count_players_by_job = function(job_names, check_on_duty) 
            local players = FW.Functions.GetPlayers()
            local total_with_job = 0
            local total_on_duty = 0

            for _, player_source in ipairs(players) do
                local player = FW.Functions.GetPlayer(player_source)
                
                if player then
                    local job = player.PlayerData.job
                    for _, job_name in ipairs(job_names) do
                        if job.name == job_name then
                            total_with_job = total_with_job + 1
                            if job.onduty then
                                total_on_duty = total_on_duty + 1
                            end
                            break
                        end
                    end
                end
            end

            return total_with_job, total_on_duty
        end,

        get_player_job_name = function(source) 
            local player = FW.Functions.GetPlayer(source)
            if not player then return nil end

            local job = player.PlayerData.job
            return job.name
        end,

        -- Statuses
        adjust_statuses = function(source, statuses) 
            local player = FW.Functions.GetPlayer(source)
            if not player then return false end

            local meta = player.PlayerData.metadata
            
            for key, mod in pairs(statuses) do
                local status_key = (key == "armor" and "armour") or key
                local add_value = (mod.add and mod.add.min and mod.add.max) and math.random(mod.add.min, mod.add.max) or 0
                local remove_value = (mod.remove and mod.remove.min and mod.remove.max) and math.random(mod.remove.min, mod.remove.max) or 0
                local change_value = add_value - remove_value
                local current = meta[status_key] or 0
                local new_value = math.min(100, math.max(0, current + change_value))

                if status_key == "stress" then
                    if change_value > 0 then
                        TriggerEvent("hud:server:GainStress", change_value, source)
                    else
                        TriggerEvent("hud:server:RelieveStress", -change_value, source)
                    end
                end

                if status_key == "hunger" or status_key == "thirst" then
                    TriggerClientEvent("hud:client:UpdateNeeds", source, meta.hunger, meta.thirst)
                end

                player.Functions.SetMetaData(status_key, new_value)
            end
            
            return true
        end
    }

end

--- @section Client

if not IS_SERVER then

    --- @section Standalone

    IMPL.standalone = {
        get_data = function() 
            return {
                source = GetPlayerServerId(PlayerId()),
                name = GetPlayerName(PlayerId())
            } 
        end,

        get_identity = function()
            return {
                first_name = GetPlayerName(PlayerId()),
                last_name = "",
                dob = "",
                sex = "",
                nationality = "LS, Los Santos"
            }
        end,

        get_player_id = function()
            return GetPlayerServerId(PlayerId())
        end
    }

    --- @section ESX

    IMPL.es_extended = {
        get_data = function() return FW.GetPlayerData() end,

        get_identity = function() 
            local player = FW.GetPlayerData()
            return {
                first_name = player.firstName,
                last_name = player.lastName,
                dob = player.dateofbirth,
                sex = player.sex,
                nationality = player.nationality or "LS, Los Santos"
            }
        end,

        get_player_id = function()
            local player = FW.GetPlayerData()
            return player.identifier
        end
    }

    --- @section ND Core

    IMPL.ND_Core = {
        get_data = function() return FW:getPlayer() end,

        get_identity = function()
            local player = FW:getPlayer()
            return {
                first_name = player.firstname,
                last_name = player.lastname,
                dob = player.dob,
                sex = player.gender,
                nationality = player.nationality or "LS, Los Santos"
            }
        end,

        get_player_id = function()
            local player = FW:getPlayer()
            return player.identifier
        end,
    }

    --- @section QBCore

    IMPL["qb-core"] = {
        get_data = function() return FW.Functions.GetPlayerData() end,

        get_identity = function()
            local player = FW.Functions.GetPlayerData()
            return {
                first_name = player.charinfo.firstname,
                last_name = player.charinfo.lastname,
                dob = player.charinfo.birthdate,
                sex = player.charinfo.gender,
                nationality = player.charinfo.nationality
            }
        end,

        get_player_id = function()
            local player = FW.Functions.GetPlayerData()
            return player.citizenid
        end,
    }

    --- @section QBX Core

    IMPL.qbx_core = {
        get_data = function() return FW.Functions.GetPlayerData() end,

        get_identity = function()
            local player = FW.Functions.GetPlayerData()
            return {
                first_name = player.charinfo.firstname,
                last_name = player.charinfo.lastname,
                dob = player.charinfo.birthdate,
                sex = player.charinfo.gender,
                nationality = player.charinfo.nationality
            }
        end,

        get_player_id = function()
            local player = FW.Functions.GetPlayerData()
            return player.citizenid
        end,
    }
end

_G.__bridges_fw_module = IMPL[ACTIVE_FRAMEWORK] or IMPL.standalone
return _G.__bridges_fw_module