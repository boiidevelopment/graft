--[[ 
    This file is part of GRAFT (General Runtime Abstraction & Framework Toolkit) and is licensed under the MIT License.
    See the LICENSE file in the root directory for full terms.

    © 2025 Case @ Playing In Traffic

    Support honest development — retain this credit. Don"t be that guy...
]]

if graft.framework ~= "esx" then return end

local bridge = {}

local tables <const> = graft.get("lib.modules.tables")

if graft.is_server then
    
    --- @section Players

    --- Retrieves all players
    --- @return players table
    function bridge.get_players()
        local players = exports.ND_Core:getPlayers()
        if not players then return false end

        return players
    end

    --- Retrieves player data from the server based on the framework.
    --- @param source number: Player source identifier.
    --- @return Player data object.
    function bridge.get_player(source)
        local player = exports.ND_Core:getPlayer(source)
        if not player then return false end

        return player
    end

    --- @section Database

    --- Prepares query parameters for database operations.
    --- @param source number: Player source identifier.
    --- @return Query part and parameters.
    function bridge.get_id_params(source)
        local player = bridge.get_player(source)

        local query, params = "identifier = ?", { player.identifier }

        return query, params
    end

    --- @section Identity

    --- Retrieves player character unique id.
    --- @param source number: Player source identifier.
    --- @return Players main identifier.
    function bridge.get_player_id(source)
        local player = bridge.get_player(source)
        if not player then return false end

        local player_id = player.identifier
        return player_id
    end

    --- Retrieves a players identity information.
    --- @param source number: Player source identifier.
    --- @return Table of players identity information.
    function bridge.get_identity(source)
        local player = bridge.get_player(source)
        if not player then return false end

        local identity = {
            first_name = player.firstname,
            last_name = player.lastname,
            dob = player.dob,
            sex = player.gender,
            nationality = "LS, Los Santos" 
        }

        return player_data
    end

    --- Retrieves a players identity information by their id (citizenid, unique_id+char_id, etc..)
    --- @param unique_id string: The id of the user to retrieve identity information for.
    --- @return Table of identity information.
    function get_identity_by_id(unique_id)
        local players = bridge.get_players()

        for _, player in ipairs(players) do
            if type(player) == "table" then
                p_source = player.source
            else
                p_source = player
            end

            local p_id = bridge.get_player_id(p_source)
            if p_id == unique_id then
                local identity = bridge.get_identity(p_source)
                return identity
            end
        end

        return nil
    end

    --- @section Inventory

    --- Gets a players inventory data
    --- @param source Player source identifier.
    --- @return The players inventory.
    function bridge.get_inventory(source)
        if GetResourceState("ox_inventory") == "started" then
            return exports.ox_inventory:GetInventory(source, false)
        end

        if GetResourceState("list_inventory") == "started" then
            local inv = exports.list_inventory:get_player(source)
            return inv and inv:get_items() or {}
        end

        local player = bridge.get_player(source)
        if not player then return false end
    end

    --- Retrieves an item from the players inventory.
    --- @param source number: Player source identifier.
    --- @param item_name string: Name of the item to retrieve.
    --- @return Item object if found, nil otherwise.
    function bridge.get_item(source, item_name)
        if GetResourceState("ox_inventory") == "started" then
            local item = exports.ox_inventory:GetItem(source, item_name, nil, false)
            return item and item.count and item.count > 0 and item or nil
        end

        if GetResourceState("list_inventory") == "started" then
            local inv = exports.list_inventory:get_player(source)
            return inv and inv:get_item(item_name) or nil
        end

        return nil
    end

    --- Checks if a player has a specific item in their inventory.
    --- @param source number: Player source identifier.
    --- @param item_name string: Name of the item to check.
    --- @param item_amount number: (Optional) Amount of the item to check for.
    --- @return True if the player has the item (and amount), False otherwise.
    function bridge.has_item(source, item_name, item_amount)
        local required_amount = item_amount or 1

        if GetResourceState("ox_inventory") == "started" then
            local count = exports.ox_inventory:Search(source, "count", item_name)
            return count and count >= required_amount
        end

        if GetResourceState("list_inventory") == "started" then
            local inv = exports.list_inventory:get_player(source)
            return inv and inv:has_item(item_name, required_amount) == true
        end

        local player = bridge.get_player(source)
        if not player then return false end
    end

    --- Adds an item to a players inventory.
    --- @param source number: Player source identifier.
    --- @param item_id string: The ID of the item to add.
    --- @param amount number: The amount of the item to add.
    --- @param data table|nil: Optional metadata for the item.
    function bridge.add_item(source, item_id, amount, data)
        if GetResourceState("ox_inventory") == "started" then
            return exports.ox_inventory:AddItem(source, item_id, amount, data)
        end

        if GetResourceState("list_inventory") == "started" then
            local inv = exports.list_inventory:get_player(source)
            return inv and inv:add_item(item_id, amount, data)
        end

        local player = bridge.get_player(source)
        if not player then return false end
    end

    --- Removes an item from a players inventory.
    --- @param source number: Player source identifier.
    --- @param item_id string: The ID of the item to remove.
    --- @param amount number: The amount of the item to remove.
    function bridge.remove_item(source, item_id, amount)
        if GetResourceState("ox_inventory") == "started" then
            return exports.ox_inventory:RemoveItem(source, item_id, amount)
        end

        if GetResourceState("list_inventory") == "started" then
            local inv = exports.list_inventory:get_player(source)
            return inv and inv:remove_item(item_id, amount)
        end

        local player = bridge.get_player(source)
        if not player then return false end
    end

    --- Updates the item data for a player.
    --- @param source number: The players source identifier.
    --- @param item_id string: The ID of the item to update.
    --- @param updates table: Table containing updates like ammo count, attachments etc.
    function bridge.update_item_data(source, item_id, updates)
        if GetResourceState("ox_inventory") == "started" then
            local items = exports.ox_inventory:Search(source, 1, item_id)
            for _, v in pairs(items) do
                for key, value in pairs(updates) do
                    v.metadata[key] = value
                end
                exports.ox_inventory:SetMetadata(source, v.slot, v.metadata)
                break
            end
            return
        end

        if GetResourceState("list_inventory") == "started" then
            local inv = exports.list_inventory:get_player(source)
            if not inv then return end

            for slot, item in pairs(inv:get_items()) do
                if item.id == item_id then
                    return inv:update_item_data(slot, updates)
                end
            end
            return
        end

        local player = bridge.get_player(source)
        if not player then return false end
    end

    --- @section Balances

    --- Retrieves the balances of a player.
    --- @param source number: Player source identifier.
    --- @return A table of balances by type.
    function bridge.get_balances(source)
        local player = bridge.get_player(source)
        if not player then return false end

        return { 
            cash = player.cash, 
            bank = player.bank 
        }
    end

    --- Retrieves a specific balance of a player by type.
    --- @param source number: Player source identifier.
    --- @param balance_type string: The type of balance to retrieve.
    --- @return The balance amount for the specified type.
    function bridge.get_balance_by_type(source, balance_type)
        local balances = bridge.get_balances(source)
        if not balances then print("no balances") return false end

        local balance

        if balance_type == "cash" then
            local cash_item = bridge.get_item(source, "money")
            local cash_balance = cash_item and cash_item.count or 0
            balance = cash_balance
        else
            balance = balances[balance_type]
        end

        return balance
    end

    --- Adds money to a players balance.
    --- @param source number: Player source identifier.
    --- @param balance_type string: The type of balance to adjust.
    --- @param amount number: The amount to add.
    function bridge.add_balance(source, balance_type, amount)
        local player = bridge.get_player(source)
        if not player then return false end

        if balance_type == "cash" or balance_type == "money" then
            exports.ox_inventory:AddItem(source, "money", amount)
        else
            player.addMoney(balance_type, amount)
        end
    end

    --- Removes money from a players balance.
    --- @param source number: Player source identifier.
    --- @param balance_type string: The type of balance to adjust.
    --- @param amount number: The amount to remove.
    function bridge.remove_balance(source, balance_type, amount)
        local player = bridge.get_player(source)
        if not player then return false end

        if balance_type == "cash" or balance_type == "money" then
            exports.ox_inventory:RemoveItem(source, "money", amount)
        else
            player.deductMoney(balance_type, amount)
        end
    end

    --- @section Jobs

    --- Retrieves the job(s) of a player by their source identifier.
    --- @param source number: The players source identifier.
    --- @return A table containing the players jobs and their on-duty status.
    function bridge.get_player_jobs(source)
        local player = bridge.get_player(source)

        local player_jobs = player.getJob()
        return player_jobs
    end

    --- Checks if a player has one of the specified jobs and optionally checks their on-duty status.
    --- @param source number: The players source identifier.
    --- @param job_names table: An array of job names to check against the players jobs.
    --- @param check_on_duty boolean: Optional boolean to also check if the player is on-duty for the job.
    --- @return Boolean indicating if the player has any of the specified jobs and meets the on-duty condition.
    function bridge.player_has_job(source, job_names)
        local player_jobs = bridge.get_player_jobs(source)
        if not player_jobs then return false end

        local job_found = false
        local on_duty_status = false

        if tables.table_contains(job_names, player_jobs.name) then
            job_found = true
            on_duty_status = true
        end

        return job_found and (not check_on_duty or on_duty_status)
    end

    --- Retrieves a players job grade for a specified job.
    --- @param source number: The players source identifier.
    --- @param job_id string: The job ID to retrieve the grade for.
    --- @return The grade of the player for the specified job, or nil if not found.
    function bridge.get_player_job_grade(source, job_id)
        local player_jobs = bridge.get_player_jobs(source)
        if not player_jobs then return nil end

        if player_jobs.name == job_id then
            return player_jobs.rank
        end
        return nil
    end

    --- Counts players with a specific job and optionally filters by on-duty status.
    --- @param job_names table: Table of job names to check against the players jobs.
    --- @param check_on_duty boolean: Optional boolean to also check if the player is on-duty for the job.
    --- @return Two numbers: total players with the job, and total players with the job who are on-duty.
    function count_players_by_job(job_names, check_on_duty)
        local players = bridge.get_players()
        if not players then return nil end

        local total_with_job = 0
        local total_on_duty = 0

        for _, p_source in ipairs(players) do
            if bridge.player_has_job(p_source, job_names, false) then
                total_with_job = total_with_job + 1
                if bridge.player_has_job(p_source, job_names, true) then
                    total_on_duty = total_on_duty + 1
                end
            end
        end

        return total_with_job, total_on_duty
    end

    --- Returns a players job name.
    --- @param source number: The players source identifier.
    function bridge.get_player_job_name(source)
        local player_jobs = bridge.get_player_jobs(source)
        if not player_jobs then return nil end

        local job_name

        if player_jobs then
            job_name = player_jobs.name
        end

        return job_name
    end

    --- @section Statuses

    --- Modifies a players server-side statuses.
    --- @param source The players source identifier.
    --- @param statuses The statuses to modify.
    function bridge.adjust_statuses(source, statuses)
        local player = bridge.get_player(source)
        if not player then return false end

        --- @todo nd status logic
    end

    --- @section Usable Items
    
    --- Register an item as usable for different frameworks.
    --- @param item string: The item identifier.
    --- @param cb function: The callback function to execute when the item is used.
    function bridge.register_item(item, cb)
        if not item or type(cb) ~= "function" then return false end
    
        exports(item, function(event, itemData, inventory, slot, data)
            local src = inventory.id or source
            if event == "usingItem" then
                return
            elseif event == "usedItem" then
                cb(src, itemData, slot, data)
            elseif event == 'buying' then
            end
        end)
    
        return true
    end

else

    --- @section Player Data

    --- Retrieves a players client-side data based on the active framework.
    --- @param key string (optional): The key of the data to retrieve.
    --- @return table: The requested player data.
    function bridge.get_data()
        local player_data = ESX.GetPlayerData()

        return player_data
    end

    --- Retrieves a players identity information.
    --- @return table: The players identity information (first name, last name, date of birth, sex, nationality).
    function bridge.get_identity()
        local player = bridge.get_data()
        if not player then return false end

        local identity = {
            first_name = player.firstName or "firstName missing",
            last_name = player.lastName or "lastName missing",
            dob = player.dateofbirth or "dateofbirth missing",
            sex = player.sex or "sex missing",
            nationality = player.nationality or "LS, Los Santos"
        }
    
        return identity
    end

    --- Retrieves player unique id.
    --- @return Players main identifier.
    function bridge.get_player_id()
        local player = bridge.get_data()
        if not player then return false end

        local player_id = player.identifier
        if not player_id then return false end

        return player_id
    end

end


return bridge

