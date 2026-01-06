--[[ 
    MIT License

    Copyright (c) 2025 CaseIRL

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
]]

--[[
    NOTES / DOCUMENTATION
    ----------------------

    This script provides a simple, self-contained zone creation tool.
    Its designed to be dropped into any resource and work immediately.
    Support honest development - keep the license above intact. Don't be that guy.

    Setup:
        - Add this file as a SHARED script in your resource.
        - Add ACE permissions to your server.cfg:
                add_ace group.admin zone_creator.use allow
                add_principal identifier.fivem:YOUR_IDENTIFIER group.admin

    Commands (server-side):
        /zones:create   -- Starts the zone creator (requires ACE permission)
        /zones:debug    -- Toggles the on-screen debug overlay (requires ACE permission)

    Zone creation controls:
        W/A/S/D     -- Move
        Q/E         -- Move up/down
        SHIFT       -- Fast movement
        CTRL        -- Slow movement
        F           -- Add a point
        X           -- Undo last point
        ENTER       -- Finish and save the zone
        G           -- Toggle debug overlay
        BACKSPACE   -- Exit creator

    When you finish a zone, the client triggers:
        TriggerEvent(resource_name .. ":zone_created", {
            name = zone_name,
            zone = { vector3(x, y, z), ... },
            player = {
                source = GetPlayerServerId(PlayerId()),
                name = GetPlayerName(PlayerId())
            }
        })

    Events available for use in your own scripts:
        resource_name .. ":zone_created"   -- when a zone is saved
        resource_name .. ":entered_zone"   -- when a player enters a zone
        resource_name .. ":inside_zone"    -- when a player remains inside a zone
        resource_name .. ":left_zone"      -- when a player leaves a zone

    Example usage:
        AddEventHandler("myRESOURCE_NAMEource:entered_zone", function(name)
            print("Player entered zone:", name)
        end)

    Notes:
        - All UI drawing is done with natives to keep it down to a single file.
        - Zone checks are lightweight and only run when the player moves.
        - If you want persistent zones, save the 'all_zones' table to the server.
        - Modify as needed, just keep the license and credit intact.
]]

--- @script zones
--- @description Straight forward zone creation system.

--- @section Constants

local RESOURCE_NAME = GetCurrentResourceName()
local IS_SERVER = IsDuplicityVersion()

local KEYS = {
    ["enter"] = 191,
    ["escape"] = 322,
    ["backspace"] = 177,
    ["tab"] = 37,
    ["arrowleft"] = 174,
    ["arrowright"] = 175,
    ["arrowup"] = 172,
    ["arrowdown"] = 173,
    ["space"] = 22,
    ["delete"] = 178,
    ["insert"] = 121,
    ["home"] = 213,
    ["end"] = 214,
    ["pageup"] = 10,
    ["pagedown"] = 11,
    ["leftcontrol"] = 36,
    ["leftshift"] = 21,
    ["leftalt"] = 19,
    ["rightcontrol"] = 70,
    ["rightshift"] = 70,
    ["rightalt"] = 70,
    ["numpad0"] = 108,
    ["numpad1"] = 117,
    ["numpad2"] = 118,
    ["numpad3"] = 60,
    ["numpad4"] = 107,
    ["numpad5"] = 110,
    ["numpad6"] = 109,
    ["numpad7"] = 117,
    ["numpad8"] = 111,
    ["numpad9"] = 112,
    ["numpad+"] = 96,
    ["numpad-"] = 97,
    ["numpadenter"] = 191,
    ["numpad."] = 108,
    ["f1"] = 288,
    ["f2"] = 289,
    ["f3"] = 170,
    ["f4"] = 168,
    ["f5"] = 166,
    ["f6"] = 167,
    ["f7"] = 168,
    ["f8"] = 169,
    ["f9"] = 56,
    ["f10"] = 57,
    ["a"] = 34,
    ["b"] = 29,
    ["c"] = 26,
    ["d"] = 30,
    ["e"] = 46,
    ["f"] = 49,
    ["g"] = 47,
    ["h"] = 74,
    ["i"] = 27,
    ["j"] = 36,
    ["k"] = 311,
    ["l"] = 182,
    ["m"] = 244,
    ["n"] = 249,
    ["o"] = 39,
    ["p"] = 199,
    ["q"] = 44,
    ["r"] = 45,
    ["s"] = 33,
    ["t"] = 245,
    ["u"] = 303,
    ["v"] = 0,
    ["w"] = 32,
    ["x"] = 73,
    ["y"] = 246,
    ["z"] = 20,
    ["mouse1"] = 24,
    ["mouse2"] = 25
}

local FLYING_SPEEDS = { 
    base = 0.25, 
    fast_multiplier = 3.0, 
    slow_multiplier = 0.25 
}

local HELP_TEXT = {
    "~b~[W/A/S/D]~s~ - Move", 
    "~b~[Q/E]~s~ - Up/Down", 
    "~b~[SHIFT]~s~ - Fast", 
    "~b~[CTRL]~s~ - Slow",
    "~g~[F]~s~ - Add Point", 
    "~r~[X]~s~ - Undo Point", 
    "~y~[ENTER]~s~ - Finish Zone",
    "~o~[G]~s~ - Toggle Debug", 
    "~r~[BACKSPACE]~s~ - Exit"
}

--- @section Client

if not IS_SERVER then

    --- @section Variables

    local is_active, is_typing, debug_mode = false, false, false
    local current_zone, current_zone_state, all_zones, zone_index = {}, {}, {}, 1
    local fly_speed = false
    local last_debug_text = ""
    local last_pos = vector3(0, 0, 0)

    --- @section Functions

    --- Gets a key from keys table.
    --- @param k string The key to get.
    --- @return number The numeric key code.
    local function get_key(k) 
        return KEYS[k] or 0 
    end

    --- Handles rotation to direction.
    --- @param rot vector3 The rotation vector.
    --- @return vector3 The direction vector.
    local function rot_to_dir(rot)
        local rad_x, rad_z = math.rad(rot.x), math.rad(rot.z)
        local mult = math.abs(math.cos(rad_x))
        return vector3(-math.sin(rad_z) * mult, math.cos(rad_z) * mult, math.sin(rad_x))
    end

    --- Gets the coordinate the camera is aiming at.
    --- @return vector3|nil Returns the hit coordinate or nil.
    local function get_aim_coord()
        local cam_rot = GetGameplayCamRot(2)
        local cam_pos = GetGameplayCamCoord()
        local direction = rot_to_dir(cam_rot)
        local dest = cam_pos + (direction * 300.0)
        local ray = StartShapeTestRay(cam_pos, dest, -1, PlayerPedId(), 0)
        local _, hit, end_pos = GetShapeTestResult(ray)
        return hit and end_pos or nil
    end

    --- Handles noclip fly movement.
    local function fly_tick()
        if is_typing then return end

        local ped = PlayerPedId()
        local cam_rot = GetGameplayCamRot(2)

        DisableControlAction(0, get_key("w"))
        DisableControlAction(0, get_key("a"))
        DisableControlAction(0, get_key("s"))
        DisableControlAction(0, get_key("d"))
        DisableControlAction(0, get_key("q"))
        DisableControlAction(0, get_key("e"))
        DisableControlAction(0, get_key("leftshift"))
        DisableControlAction(0, get_key("leftcontrol"))

        local move_dir = vector3(0, 0, 0)
        local forward = rot_to_dir(cam_rot)
        local right = rot_to_dir(vector3(0, 0, cam_rot.z - 90))
        local up = vector3(0, 0, 1)

        if IsDisabledControlPressed(0, get_key("w")) then move_dir = move_dir + forward end
        if IsDisabledControlPressed(0, get_key("s")) then move_dir = move_dir - forward end
        if IsDisabledControlPressed(0, get_key("a")) then move_dir = move_dir - right end
        if IsDisabledControlPressed(0, get_key("d")) then move_dir = move_dir + right end
        if IsDisabledControlPressed(0, get_key("q")) then move_dir = move_dir + up end
        if IsDisabledControlPressed(0, get_key("e")) then move_dir = move_dir - up end

        fly_speed = FLYING_SPEEDS.base
        if IsDisabledControlPressed(0, get_key("leftshift")) then 
            fly_speed = fly_speed * FLYING_SPEEDS.fast_multiplier
        elseif IsDisabledControlPressed(0, get_key("leftcontrol")) then 
            fly_speed = fly_speed * FLYING_SPEEDS.slow_multiplier 
        end

        if #(move_dir) > 0 then
            move_dir = move_dir / #(move_dir)
            SetEntityCoordsNoOffset(ped, GetEntityCoords(ped) + move_dir * fly_speed, true, true, true)
        end
    end

    --- Draws on-screen help text for controls.
    local function draw_help_text()
        local start_x, start_y = 0.015, 0.25
        local line_height = 0.022
        local padding_x, padding_y = 0.006, 0.008
        local header_height = 0.028
        local box_width = 0.17
        local box_height = (#HELP_TEXT * line_height) + (padding_y * 2) + header_height
        local center_x = start_x + (box_width / 2)
        local center_y = start_y + (box_height / 2)

        DrawRect(center_x, center_y + 0.01, box_width, box_height, 0, 0, 0, 170)
        DrawRect(center_x, center_y + 0.01, box_width - 0.002, box_height - 0.002, 255, 255, 255, 20)

        local header_center_y = start_y + (header_height / 2)
        DrawRect(center_x, header_center_y + 0.01, box_width, header_height, 0, 0, 0, 255)

        SetTextFont(4)
        SetTextScale(0.36, 0.36)
        SetTextColour(255, 255, 255, 255)
        SetTextCentre(1)
        SetTextEntry("STRING")
        AddTextComponentString("CONTROLS")
        DrawText(center_x, header_center_y - 0.004)

        for i = 1, #HELP_TEXT do
            SetTextFont(0)
            SetTextScale(0.32, 0.32)
            SetTextColour(255, 255, 255, 230)
            SetTextEntry("STRING")
            AddTextComponentString(HELP_TEXT[i])
            DrawText(start_x + padding_x, start_y + (header_height - 0.008) + (i * line_height))
        end
    end

    --- Draws text in 3D space.
    --- @param x number The X coordinate.
    --- @param y number The Y coordinate.
    --- @param z number The Z coordinate.
    --- @param text string The text to display.
    local function draw_text_3d(x, y, z, text)
        local on_screen, _x, _y = World3dToScreen2d(x, y, z)
        if not on_screen then return end
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
    end

    --- Draws a zone's connecting lines and point numbers.
    --- @param points table The list of vector3 points.
    --- @param r number Red color value.
    --- @param g number Green color value.
    --- @param b number Blue color value.
    local function draw_zone(points, r, g, b)
        for i = 1, #points do
            local a = points[i]
            local bpt = points[i + 1] or points[1]
            DrawLine(a.x, a.y, a.z + 0.2, bpt.x, bpt.y, bpt.z + 0.2, r, g, b, 255)
            draw_text_3d(a.x, a.y, a.z + 0.25, tostring(i))
        end
    end

    --- Draws zone debug text on screen.
    --- @param text string The text to draw.
    local function draw_zone_debug_text(text)
        local lines = {}
        for line in string.gmatch(text or "", "[^\n]+") do
            lines[#lines + 1] = line
        end

        local start_x, start_y = 0.015, 0.025
        local line_height = 0.022
        local padding_x, padding_y = 0.006, 0.008
        local header_height = 0.028
        local max_width = 0.25
        local box_width = 0.12 + (math.min(#text, 35) * 0.0018)
        box_width = math.min(box_width, max_width)

        local box_height = (#lines * line_height) + (padding_y * 2) + header_height
        local center_x = start_x + (box_width / 2)
        local center_y = start_y + (box_height / 2)

        DrawRect(center_x, center_y + 0.01, box_width, box_height, 0, 0, 0, 170)
        DrawRect(center_x, center_y + 0.01, box_width - 0.002, box_height - 0.002, 255, 255, 255, 20)

        local header_center_y = start_y + (header_height / 2)
        DrawRect(center_x, header_center_y + 0.01, box_width, header_height, 0, 0, 0, 255)

        SetTextFont(4)
        SetTextScale(0.36, 0.36)
        SetTextColour(255, 255, 255, 255)
        SetTextCentre(1)
        SetTextEntry("STRING")
        AddTextComponentString("ZONE DEBUG")
        DrawText(center_x, header_center_y - 0.004)

        for i = 1, #lines do
            SetTextFont(0)
            SetTextScale(0.32, 0.32)
            SetTextColour(255, 255, 255, 230)
            SetTextEntry("STRING")
            AddTextComponentString(lines[i])
            DrawText(start_x + padding_x, start_y + (header_height - 0.008) + (i * line_height))
        end
    end

    --- Checks whether a point is inside a convex polygon.
    --- @param p vector2 The point to check.
    --- @param poly table The polygon vertices.
    --- @return boolean True if inside, false otherwise.
    local function is_point_in_convex_polygon(p, poly)
        local sign = nil
        for i = 1, #poly do
            local dx1 = poly[i].x - p.x
            local dy1 = poly[i].y - p.y
            local dx2 = poly[(i % #poly) + 1].x - p.x
            local dy2 = poly[(i % #poly) + 1].y - p.y
            local cross = dx1 * dy2 - dx2 * dy1
            if i == 1 then sign = cross > 0
            elseif sign ~= (cross > 0) then return false end
        end
        return true
    end

    --- Prompts user to input a custom zone name using native on-screen keyboard.
    --- @param default_name string The default name suggested.
    --- @return string|nil The name entered, or nil if cancelled.
    local function prompt_zone_name(default_name)
        is_typing = true
        AddTextEntry("ZONE_NAME_PROMPT", "Enter a name for this zone:")
        DisplayOnscreenKeyboard(1, "ZONE_NAME_PROMPT", "", default_name, "", "", "", 25)

        while UpdateOnscreenKeyboard() == 0 do
            Wait(0)
        end

        local status = UpdateOnscreenKeyboard()
        is_typing = false

        if status == 1 then
            local result = GetOnscreenKeyboardResult()
            if result and result ~= "" then
                return result
            end
        end
        return nil
    end

    --- @section Zone Creator

    --- Handles drawing, movement, and debug visuals each frame.
    local function zone_creator_tick()
        while is_active do
            Wait(0)
            fly_tick()
            draw_help_text()

            if debug_mode then
                for _, zone in ipairs(all_zones) do
                    draw_zone(zone.coords, 255, 0, 0)
                end
            end

            draw_zone(current_zone, 255, 255, 0)

            local aim = get_aim_coord()
            if aim then
                DrawMarker(28, aim.x, aim.y, aim.z, 0, 0, 0, 0, 0, 0, 0.4, 0.4, 0.4, 0, 200, 0, 150, false, false, 2, false)
            end
        end
    end

    --- Handles user controls for adding/removing/saving points.
    local function zone_creator_controls()
        while is_active do
            Wait(0)

            if not is_typing then
                if IsControlJustPressed(0, get_key("f")) then
                    local hit = get_aim_coord()
                    if hit then
                        current_zone[#current_zone + 1] = hit
                        print(("Added point #%d: %.2f %.2f %.2f"):format(#current_zone, hit.x, hit.y, hit.z))
                    end

                elseif IsControlJustPressed(0, get_key("x")) then
                    if #current_zone > 0 then
                        current_zone[#current_zone] = nil
                        print("Removed last point.")
                    end

                elseif IsControlJustPressed(0, get_key("enter")) then
                    if #current_zone >= 3 then
                        local default_name = ("zone_%d"):format(zone_index)
                        local custom_name = prompt_zone_name(default_name) or default_name
                        local poly2d = {}
                        for i = 1, #current_zone do
                            poly2d[i] = vector2(current_zone[i].x, current_zone[i].y)
                        end

                        all_zones[#all_zones + 1] = { name = custom_name, coords = current_zone, poly2d = poly2d }

                        TriggerEvent(RESOURCE_NAME .. ":zone_created", {
                            name = custom_name,
                            zone = current_zone,
                            player = {
                                source = GetPlayerServerId(PlayerId()),
                                name = GetPlayerName(PlayerId())
                            }
                        })
                        print(("Saved zone '%s' with %d points."):format(custom_name, #current_zone))

                        current_zone = {}
                        zone_index = zone_index + 1
                    else
                        print("Need at least 3 points to save zone.")
                    end

                elseif IsControlJustPressed(0, get_key("backspace")) then
                    stop_zone_creator()
                elseif IsControlJustPressed(0, get_key("g")) then
                    debug_mode = not debug_mode
                    print("Debug mode: " .. tostring(debug_mode))
                end
            end
        end
    end

    --- Starts the zone creation mode.
    function start_zone_creator()
        if is_active then 
            stop_zone_creator()
            return 
        end

        current_zone = {}
        is_active = true

        local ped = PlayerPedId()
        SetEntityInvincible(ped, true)
        SetEntityVisible(ped, false, false)
        FreezeEntityPosition(ped, true)

        CreateThread(zone_creator_tick)
        CreateThread(zone_creator_controls)
    end

    --- Stops zone creation mode and resets player.
    function stop_zone_creator()
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local _, ground_z = GetGroundZFor_3dCoord(pos.x, pos.y, pos.z + 2.0, 0)
        SetEntityCoords(ped, pos.x, pos.y, ground_z, false, false, false, false)
        SetEntityInvincible(ped, false)
        SetEntityVisible(ped, true, false)
        FreezeEntityPosition(ped, false)
        is_active = false
    end

    function toggle_debug()
        debug_mode = not debug_mode
    end

    --- @section Events

    RegisterNetEvent(RESOURCE_NAME .. ":create_zone", function()
        start_zone_creator()
    end)

    RegisterNetEvent(RESOURCE_NAME .. ":toggle_debug_zones", function()
        toggle_debug()
    end)

    --- @section Clean Up

    AddEventHandler("onResourceStop", function(res)
        if RESOURCE_NAME == res then 
            stop_zone_creator() 
        end
    end)

    --- @section Threads

    --- Draw debug overlay and zones
    CreateThread(function()
        while true do
            if debug_mode or is_active then
                Wait(0)
                if debug_mode then
                    for _, zone in ipairs(all_zones) do
                        draw_zone(zone.coords, 255, 0, 0)
                    end

                    if last_debug_text ~= "" then
                        draw_zone_debug_text(last_debug_text)
                    end
                end
            else
                Wait(500)
            end
        end
    end)

    --- Zone state tracking
    CreateThread(function()
        while true do
            if #all_zones == 0 then
                Wait(1000)
            else
                Wait(250)

                local ped = PlayerPedId()
                local pos = GetEntityCoords(ped)
                local moved = #(pos - last_pos) >= 0.5
                if moved then
                    last_pos = pos
                    local lines = {}

                    for _, zone in ipairs(all_zones) do
                        local name, poly2d = zone.name, zone.poly2d
                        local inside = is_point_in_convex_polygon(vector2(pos.x, pos.y), poly2d)
                        local was_inside = current_zone_state[name] or false

                        if inside and not was_inside then
                            current_zone_state[name] = true
                            TriggerEvent(RESOURCE_NAME .. ":entered_zone", name)
                            if debug_mode then table.insert(lines, "Entered zone: " .. name) end

                        elseif not inside and was_inside then
                            current_zone_state[name] = false
                            TriggerEvent(RESOURCE_NAME .. ":left_zone", name)
                            if debug_mode then table.insert(lines, "Left zone: " .. name) end

                        elseif inside then
                            TriggerEvent(RESOURCE_NAME .. ":inside_zone", name)
                            if debug_mode then table.insert(lines, "Inside zone: " .. name) end
                        end
                    end

                    if debug_mode then
                        last_debug_text = #lines > 0 and table.concat(lines, "\n") or "Outside all zones"
                    end
                end
            end
        end
    end)

    --- @section Event Testing

    AddEventHandler(RESOURCE_NAME .. ":zone_created", function(data)
        print("Zone created:", json.encode(data))
    end)

    AddEventHandler(RESOURCE_NAME .. ":entered_zone", function(name)
        print(("Entered: %s"):format(name))
    end)

    AddEventHandler(RESOURCE_NAME .. ":inside_zone", function(name)
        print(("Inside: %s"):format(name))
    end)

    AddEventHandler(RESOURCE_NAME .. ":left_zone", function(name)
        print(("Left: %s"):format(name))
    end)

end

--- @section Server

if IS_SERVER then

    --[[
        Make sure to add the following aceperms into `server.cfg`

        add_ace group.admin zonecreator.use allow
        add_principal identifier.fivem:YOUR_IDENTIFIER group.admin
    ]]

    RegisterCommand("zones:create", function(_src)
        if IsPlayerAceAllowed(_src, "zone_creator.use") then
            TriggerClientEvent(RESOURCE_NAME .. ":create_zone", _src)
        else
            TriggerClientEvent("chat:addMessage", _src, {
                args = {"^1ZONE CREATOR", "You dont have permission to use this command, make sure to add aceperms."}
            })
        end
    end, false)

    RegisterCommand("zones:debug", function(_src)
        if IsPlayerAceAllowed(_src, "zone_creator.use") then
            TriggerClientEvent(RESOURCE_NAME .. ":toggle_debug_zones", _src)
        else
            TriggerClientEvent("chat:addMessage", _src, {
                args = {"^1ZONE CREATOR", "You dont have permission to use this command, make sure to add aceperms."}
            })
        end
    end, false)

end