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

--- @script cfx_require
--- @description Simple "safe require" function for mimicing require("path.to.your.module") in fivem/redm.
--- Place this file into `shared_scripts` of any resource you are working on and use it to require any additional files you use.
--- @example
---
--- local framework_bridge = require("framework")
--- local player = framework_bridge.get_player(source)

--- @section Constants

local RESOURCE = GetCurrentResourceName()
local CACHE = {}
local HOT_PATHS = {
    ["lib.modules."] = "graft.fivem.modules."
}
local MODULE_ALIASES = {
    ["bridges.framework.loader"] = "graft.fivem.bridges.framework",
    ["bridges.drawtext_ui.loader"] = "graft.fivem.bridges.drawtext_ui",
    ["bridges.notify.loader"] = "graft.fivem.bridges.notify",
    ["lib.modules.maths"] = "graft.standalone.modules.maths",
    ["lib.modules.strings"] = "graft.standalone.modules.strings",
    ["lib.modules.tables"] = "graft.standalone.modules.tables",
    ["lib.modules.player"] = "graft.fivem.modules.animations"
}

--- @section Functions

local function resolve_key(key)
    if MODULE_ALIASES[key] then return MODULE_ALIASES[key] end
    for prefix, replacement in pairs(HOT_PATHS) do
        if key:sub(1, #prefix) == prefix then
            return replacement .. key:sub(#prefix + 1)
        end
    end
    return key
end

local function safe_require(key, external, env)
    if type(key) ~= "string" then return nil end
    local resolved_key = resolve_key(key)
    local resource = external and GetInvokingResource() or RESOURCE
    local rel_path = resolved_key:gsub("%.", "/")
    if not rel_path:match("%.lua$") then rel_path = rel_path .. ".lua" end
    local cache_key = ("%s:%s"):format(resource, rel_path)
    if not external and CACHE[cache_key] then return CACHE[cache_key] end
    local file = LoadResourceFile(resource, rel_path)
    if not file then print(("[require] module not found: %s"):format(rel_path)) return nil end
    local env = setmetatable(env or {}, { __index = _G })
    local chunk, err = load(file, ("@@%s/%s"):format(resource, rel_path), "t", env)
    if not chunk then print(("[require] compile error in %s:\n%s"):format(rel_path, err)) return nil end
    local ok, result = pcall(chunk)
    if not ok then print(("[require] runtime error in %s:\n%s"):format(rel_path, result)) return nil end
    if type(result) ~= "table" then print(("[require] module %s returned %s (expected table)"):format(rel_path, type(result))) return nil end
    if not external then CACHE[cache_key] = result end
    return result
end

_G.require = safe_require
exports("require", safe_require)
exports("get", safe_require)