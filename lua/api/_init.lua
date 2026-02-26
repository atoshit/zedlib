UI = {}

ZedInternal = {
    menuItemCounters = {},
}

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
