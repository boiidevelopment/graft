--- @script require
--- @description Simple "safe require" function for mimicing require("path.to.your.module") in fivem/redm.
--- Place this file into `shared_scripts` of any resource your are working on and use it to require any additional files you use.
--- @example 
---
--- local framework_bridge = require("framework")
--- local player = framework_bridge.get_player(source)

--- @section Constants

local RESOURCE = GetCurrentResourceName()
local CACHE = {}

--- @section Functions

local function safe_require(key)
    if type(key) ~= "string" then
        return nil
    end

    local rel_path = key:gsub("%.", "/")
    if not rel_path:match("%.lua$") then
        rel_path = rel_path .. ".lua"
    end

    local cache_key = RESOURCE .. ":" .. rel_path
    local cached = CACHE[cache_key]
    if cached then
        return cached
    end

    local file = LoadResourceFile(RESOURCE, rel_path)
    if not file then
        print(("[require] module not found: %s"):format(rel_path))
        return nil
    end

    local env = setmetatable({}, { __index = _G })
    local chunk, err = load(file, ("@@%s/%s"):format(RESOURCE, rel_path), "t", env)

    if not chunk then
        print(("[require] compile error in %s:\n%s"):format(rel_path, err))
        return nil
    end

    local ok, result = pcall(chunk)
    if not ok then
        print(("[require] runtime error in %s:\n%s"):format(rel_path, result))
        return nil
    end

    if type(result) ~= "table" then
        print(("[require] module %s returned %s (expected table)"):format(rel_path, type(result)))
        return nil
    end

    CACHE[cache_key] = result
    return result
end

_G.require = safe_require
exports("require", safe_require)