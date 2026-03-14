--- Watcher: reactive menu item refresh. Runs only when a menu is open and items have function-valued properties.

local log = ZedInternal.log

if not ZedState.watcherCache then
    ZedState.watcherCache = {}
end

local REACTIVE_KEYS = { label = true, rightLabel = true, rightLabelColor = true, infoData = true, checked = true }

local function deepEqual(a, b)
    if a == b then return true end
    if type(a) ~= 'table' or type(b) ~= 'table' then return false end
    local seen = {}
    local function eq(x, y)
        if x == y then return true end
        if type(x) ~= 'table' or type(y) ~= 'table' then return false end
        if seen[x] and seen[x] == y then return true end
        seen[x] = y
        for k, v in pairs(x) do
            if not eq(v, y[k]) then return false end
        end
        for k in pairs(y) do
            if x[k] == nil then return false end
        end
        return true
    end
    return eq(a, b)
end

local function hasReactiveProps(entry)
    if type(entry) ~= 'table' or type(entry.opts) ~= 'table' then return false end
    local opts = entry.opts
    for key in pairs(REACTIVE_KEYS) do
        if type(opts[key]) == 'function' then return true end
    end
    return false
end

local function anyMenuHasReactive()
    for menuId, menu in pairs(ZedState.menus or {}) do
        local items = menu.items
        if type(items) == 'table' then
            for _, entry in ipairs(items) do
                if hasReactiveProps(entry) then return true end
            end
        end
    end
    return false
end

local function resolveVal(opts, key)
    local v = opts and opts[key]
    if type(v) == 'function' then
        local ok, res = pcall(v)
        return ok and res or nil
    end
    return v
end

local function buildInfoDataForWatcher(raw)
    if type(raw) ~= 'table' then return raw end
    local out = {}
    for i, row in ipairs(raw) do
        if type(row) == 'table' and row.label ~= nil and row.value ~= nil then
            out[i] = { label = tostring(row.label), value = tostring(row.value) }
        end
    end
    return out
end

local function evaluateReactive(entry)
    local opts = entry.opts
    if not opts then return nil end
    local patch = {}
    if type(opts.label) == 'function' then
        local v = resolveVal(opts, 'label')
        if v ~= nil then patch.label = tostring(v) end
    end
    if type(opts.rightLabel) == 'function' then
        local v = resolveVal(opts, 'rightLabel')
        if v ~= nil then patch.rightLabel = tostring(v) end
    end
    if type(opts.rightLabelColor) == 'function' then
        local v = resolveVal(opts, 'rightLabelColor')
        if v ~= nil then patch.rightLabelColor = tostring(v) end
    end
    if type(opts.infoData) == 'function' then
        local ok, res = pcall(opts.infoData)
        if ok and res ~= nil then
            patch.infoData = buildInfoDataForWatcher(res)
        end
    end
    if entry.type == 'checkbox' and type(opts.checked) == 'function' then
        local v = resolveVal(opts, 'checked')
        patch.checked = v == true
    end
    return patch
end

CreateThread(function()
    while true do
        local interval = type(ZedConfig.refreshInterval) == 'number' and ZedConfig.refreshInterval > 0 and ZedConfig.refreshInterval or 100
        Wait(interval)
        if not ZedInternal.menuOpen then
            goto continue
        end
        if not anyMenuHasReactive() then
            goto continue
        end
        local inspected = 0
        local changes = 0
        for menuId, menu in pairs(ZedState.menus or {}) do
            local items = menu.items
            if type(items) ~= 'table' then goto nextmenu end
            if not ZedState.watcherCache[menuId] then
                ZedState.watcherCache[menuId] = {}
            end
            local cache = ZedState.watcherCache[menuId]
            for _, entry in ipairs(items) do
                if not hasReactiveProps(entry) then goto nextitem end
                inspected = inspected + 1
                local itemId = entry.id
                local patch = evaluateReactive(entry)
                if patch and next(patch) then
                    local prev = cache[itemId]
                    local changed = false
                    if not prev then
                        changed = true
                    else
                        for k, v in pairs(patch) do
                            if k == 'infoData' then
                                if not deepEqual(v, prev[k]) then changed = true break end
                            else
                                if v ~= prev[k] then changed = true break end
                            end
                        end
                    end
                    if changed then
                        cache[itemId] = patch
                        ZedInternal.SendNUI('zedlib:updateItem', { menuId = menuId, itemId = itemId, patch = patch })
                        changes = changes + 1
                        if ZedConfig.debug then
                            log("DEBUG", "WATCHER", "Item '" .. tostring(itemId) .. "' updated.", { menuId = menuId, changed = patch })
                        end
                    end
                end
                ::nextitem::
            end
            ::nextmenu::
        end
        if ZedConfig.debug and inspected > 0 then
            log("DEBUG", "WATCHER", "Tick.", { inspected = inspected, changes = changes })
        end
        ::continue::
    end
end)
