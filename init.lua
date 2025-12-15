--[[ 
    This file is part of GRAFT (General Runtime Abstraction & Framework Toolkit) and is licensed under the MIT License.
    See the LICENSE file in the root directory for full terms.

    © 2025 Case @ Playing In Traffic

    Support honest development — retain this credit. Don"t be that guy...
]]

--- @script init.lua
--- Handles graft initialization for graft.

--- @section Object

graft = setmetatable({}, { __index = _G })

--- @section General

graft.dev_mode = GetConvar("graft:dev_mode", "false") == "true"
graft.resource_name = GetCurrentResourceName()
graft.version = GetResourceMetadata(graft.resource_name, "version", 0) or "unknown"
graft.is_server = IsDuplicityVersion()
graft.debug_enabled = GetConvar("graft:debug_mode", "false") == "true"
graft.deferals_updates = GetConvar("graft:deferals_updates", "true") == "true"
graft.unique_id_prefix = GetConvar("graft:unique_id_prefix", "USER_")
graft.unique_id_chars = tonumber(GetConvar("graft:unique_id_chars", "5"))
graft.debug_colours = {
    reset = "^7",
    debug = "^6",
    info = "^5",
    success = "^2",
    warn = "^3",
    error = "^8",
    critical = "^1",
    dev = "^9"
}

--- @section Cache

graft.cache = graft.cache or {}

--- @section Framework Bridge

graft.framework_map = {
    { key = "esx", resource = "es_extended" },
    { key = "boii", resource = "boii_core" },
    { key = "nd", resource = "ND_Core" },
    { key = "ox", resource = "ox_core" },
    { key = "qb", resource = "qb-core" },
    { key = "qbx", resource = "qbx_core" },
}
graft.auto_detect_framework = GetConvar("graft:auto_detect_framework", "true") == "true"
graft.framework = GetConvar("graft:framework", "standalone")

--- @section UI Bridges

graft.drawtext_ui_map = {
    { key = "boii_ui", resource = "boii_ui" },
    { key = "esx", resource = "es_extended" },
    { key = "okok", resource = "okokTextUi" },
    { key = "ox", resource = "ox_lib" },
    { key = "qb", resource = "qb-core" }
}
graft.auto_detect_drawtext_ui = GetConvar("graft:auto_detect_drawtext_ui", "true") == "true"
graft.drawtext_ui = GetConvar("graft:drawtext_ui", "standalone")

graft.notify_map = {
    { key = "boii_ui", resource = "boii_ui" },
    { key = "esx", resource = "es_extended" },
    { key = "okok", resource = "okokNotify" },
    { key = "ox", resource = "ox_lib" },
    { key = "qb", resource = "qb-core" }
}
graft.auto_detect_notify = GetConvar("graft:auto_detect_notify", "true") == "true"
graft.notify = GetConvar("graft:notify", "standalone")

--- @section Timers

graft.clear_expired_cooldowns = tonumber(GetConvar("graft:clear_expired_cooldowns", "5"))

--- @section Helpers

--- Print logs
local function log_err(fmt, ...) print(("^1[graft]^7 " .. fmt):format(...)) end
local function log_ok(fmt, ...) print(("^2[graft]^7 " .. fmt):format(...)) end

--- Builds relative paths
local function build_path(tpl, name)
    return tpl:find("%%s") and tpl:format(name) or ("%s/%s.lua"):format(tpl, name)
end

--- @section Resource Auto Detection

--- Auto detects active resource for framework, drawtext, or notify layer.
--- @param flag_key string: graft flag key, e.g., "auto_detect_framework"
--- @param option_key string: graft option key, e.g., "framework"
--- @param list table: resource list (e.g., graft.frameworks)
--- @param default_value string: default fallback value
--- @param label string: optional log label
local function auto_detect(flag_key, option_key, list, default_value, label)
    if not graft[flag_key] or graft[option_key] ~= default_value then return end
    for _, res in ipairs(list) do
        if GetResourceState(res.resource) == "started" then
            graft[option_key] = res.key
            if label then log_ok("%s detected: %s", label, res.resource) end
            return
        end
    end
end

auto_detect("auto_detect_framework", "framework", graft.framework_map, "standalone", "Framework")
auto_detect("auto_detect_drawtext", "drawtext_ui", graft.drawtext_ui_map, "default")
auto_detect("auto_detect_notify", "notify", graft.notify_map, "default")

--- @section Safe Require Function

--- Loads and caches a module file from graft or another resource.
--- @param key string: Dotted path (e.g. "core.player.manager")
--- @param env table|nil: Optional environment table.
--- @return table|nil
function graft.get(key, external, env)
    if not key or type(key) ~= "string" then return nil end

    local external = external or false
    local resource = external and GetInvokingResource() or graft.resource_name
    local rel_path = key:gsub("%.", "/")
    if not rel_path:match("%.lua$") then rel_path = rel_path .. ".lua" end

    local cache_key = ("%s:%s"):format(resource, rel_path)
    if not external and graft.cache[cache_key] then return graft.cache[cache_key] end

    local file = LoadResourceFile(resource, rel_path)
    if not file then return nil end

    local env = setmetatable(env or {}, { __index = _G })
    local chunk, err = load(file, "@@" .. resource .. "/" .. rel_path, "t", env)
    if not chunk then print(("[graft] compile error in %s: %s"):format(rel_path, err)) return nil end

    local ok, result = pcall(chunk)
    if not ok then print(("[graft] runtime error in %s: %s"):format(rel_path, result)) return nil end
    if type(result) ~= "table" then print(("[graft] expected table return from: %s"):format(rel_path)) return nil end

    if not external then graft.cache[cache_key] = result end
    return result
end

exports("require", graft.get)
exports("get", graft.get)

--- @section Dot Access Helpers

graft.data = setmetatable({}, {
    __index = function(_, k) return graft.get("lib.data." .. k) end
})

--- @section Export Namespace

--- Returns the full graft object for plugin usage.
--- @return table: graft core object.
exports("import", function()
    return graft
end)