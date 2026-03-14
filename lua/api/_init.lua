--- Internal state and shared utilities for ZedLib. Loaded before client and API modules.

UI = {}

if not ZedConfig then
    ZedConfig = {}
end
ZedConfig.accentColor = ZedConfig.accentColor or '#e74c3c'
if ZedConfig.accentColor:sub(1, 1) ~= '#' then
    ZedConfig.accentColor = '#' .. ZedConfig.accentColor
end
if #ZedConfig.accentColor > 7 then
    ZedConfig.accentColor = ZedConfig.accentColor:sub(1, 7)
end
ZedConfig.showTitle = ZedConfig.showTitle ~= false
ZedConfig.showItemCount = ZedConfig.showItemCount ~= false
ZedConfig.enableContextMenu = ZedConfig.enableContextMenu ~= false
ZedConfig.refreshInterval = ZedConfig.refreshInterval or 100
ZedConfig.debug = ZedConfig.debug == true
ZedConfig.debugFilter = ZedConfig.debugFilter

ZedState = {
    nuiBuffer = {},
    menus = {},
    menuItemsById = {},
}

ZedConst = {
    HEX_PATTERN = '^#%x%x%x%x%x%x$',
    HEX_PATTERN_SHORT = '^#%x%x%x$',
}

ZedInternal = {
    menuItemCounters = {},
    menuOpen = false,
}

---@param component string
---@param condition boolean
---@param message string
---@param level? number
function ZedInternal.assert(component, condition, message, level)
    if not condition then
        error(string.format("[ZedLib] [%s] %s", component, message), (level or 2) + 1)
    end
end

---@param level string
---@param component string
---@param message string
---@param data? table
function ZedInternal.log(level, component, message, data)
    if not ZedConfig.debug then return end
    if ZedConfig.debugFilter and type(ZedConfig.debugFilter) == 'table' then
        local found = false
        for _, c in ipairs(ZedConfig.debugFilter) do
            if c == component then found = true break end
        end
        if not found then return end
    end
    local extra = (data and next(data)) and (" " .. json.encode(data)) or ""
    print(string.format("[ZedLib:%s] [%s] %s%s", level, component, message, extra))
end

---@param action string
---@param data table
function ZedInternal.SendNUI(action, data)
    table.insert(ZedState.nuiBuffer, { action = action, data = data or {} })
    if ZedConfig.debug then
        local sz = 0
        local raw = json.encode(data or {})
        if raw then sz = #raw end
        ZedInternal.log("DEBUG", "NUI", "SendNUI() — queued. " .. action, { size = sz })
    end
end

CreateThread(function()
    while true do
        if #ZedState.nuiBuffer > 0 then
            local messages = ZedState.nuiBuffer
            ZedState.nuiBuffer = {}
            local payload = { action = "zedlib:batch", data = { messages = messages } }
            SendNUIMessage(payload)
            if ZedConfig.debug then
                local raw = json.encode(payload)
                ZedInternal.log("DEBUG", "NUI", "batch flushed.", { count = #messages, size = raw and #raw or 0 })
            end
            Wait(0)
        else
            Wait(100)
        end
    end
end)

function SendUI(action, data)
    ZedInternal.SendNUI(action, data)
end

---@param s string
---@return boolean
function ZedInternal.validateHex(s)
    if type(s) ~= 'string' or #s == 0 then return false end
    return s:match('^#%x%x%x%x%x%x$') or s:match('^#%x%x%x$') ~= nil
end

---@param opts table
---@return string|nil id
---@return any label
---@return string|nil icon
---@return boolean disabled
---@return string|nil category
function ZedInternal.parseBaseItem(opts)
    if type(opts) ~= 'table' then return nil, nil, nil, false, nil end
    local id = type(opts.id) == 'string' and opts.id ~= '' and opts.id or nil
    local label = opts.label
    local icon = (type(opts.icon) == 'string' and opts.icon ~= '') and opts.icon or nil
    local disabled = opts.disabled == true
    local category = (type(opts.category) == 'string' and opts.category ~= '') and opts.category or nil
    return id, label, icon, disabled, category
end

---@param menuId string
---@param prefix string
---@return string
function ZedInternal.generateId(menuId, prefix)
    if not ZedInternal.menuItemCounters[menuId] then
        ZedInternal.menuItemCounters[menuId] = 0
    end
    ZedInternal.menuItemCounters[menuId] = ZedInternal.menuItemCounters[menuId] + 1
    return prefix .. '_' .. menuId .. '_' .. ZedInternal.menuItemCounters[menuId]
end

---@param cb function|string
---@param ... any
function ZedInternal.fireCallback(cb, ...)
    if type(cb) == 'string' then
        local res, num = cb:match('^(.+):cb:(%d+)$')
        if res and num then
            TriggerEvent('__zedlib_cb_' .. res .. '_' .. num, ...)
        else
            TriggerEvent('zedlib:triggerCallback', cb, ...)
        end
    elseif type(cb) == 'function' then
        cb(...)
    end
end

RegisterCommand('zeddebug', function()
    ZedConfig.debug = not ZedConfig.debug
    if ZedInternal.log then
        ZedInternal.log("INFO", "CONFIG", "Debug mode " .. (ZedConfig.debug and "enabled" or "disabled") .. ".", nil)
    end
end, false)

CreateThread(function()
    Wait(500)
    SendUI('zedlib:setLibConfig', {
        accentColor = ZedConfig.accentColor,
        showTitle = ZedConfig.showTitle,
        showItemCount = ZedConfig.showItemCount,
    })
end)
