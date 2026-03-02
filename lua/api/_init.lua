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

ZedInternal = {
    menuItemCounters = {},
}

CreateThread(function()
    Wait(500)
    SendUI('zedlib:setLibConfig', {
        accentColor = ZedConfig.accentColor,
        showTitle = ZedConfig.showTitle,
        showItemCount = ZedConfig.showItemCount,
    })
end)

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
        TriggerEvent('zedlib:triggerCallback', cb, ...)
    elseif type(cb) == 'function' then
        cb(...)
    end
end
