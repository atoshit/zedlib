--- Context menu API: ALT-targeting entity menus with validation and model hash cache.

local fireCallback = ZedInternal.fireCallback
local assert = ZedInternal.assert
local log = ZedInternal.log

if not ZedState.modelHashCache then
    ZedState.modelHashCache = {}
end

local contextOptions = {}
local contextSubMenus = {}
local contextEntityOptions = {}
local contextEntitySubMenus = {}
local contextModelOptions = {}
local contextModelSubMenus = {}
local contextCallbacks = {}
local contextResourceMap = {}
local contextEnabled = true
local contextOpen = false
local contextEntity = nil
local contextEntityType = nil
local contextCoords = nil

local nextCtxId = 0

---@param prefix string
---@return string
local function genCtxId(prefix)
    nextCtxId = nextCtxId + 1
    return prefix .. '_ctx_' .. nextCtxId
end

--- Track a resource for a context menu item
---@param id string The item identifier
---@param kind string The item kind (option or submenu)
local function trackResource(id, kind)
    local res = GetInvokingResource() or 'unknown'
    if not contextResourceMap[res] then
        contextResourceMap[res] = {}
    end
    contextResourceMap[res][#contextResourceMap[res] + 1] = { id = id, kind = kind }
end

--- Get the entity type
---@param entity number The entity handle
---@return string|nil entityType The entity type
local function getEntityType(entity)
    if not DoesEntityExist(entity) then return nil end
    local ped = PlayerPedId()
    if entity == ped then return 'myself' end
    if IsEntityAVehicle(entity) then
        local myVeh = GetVehiclePedIsIn(ped, false)
        if myVeh ~= 0 and myVeh == entity then return 'mycar' end
        return 'vehicle'
    end
    if IsEntityAPed(entity) then
        if IsPedAPlayer(entity) then return 'player' end
        return 'ped'
    end
    if IsEntityAnObject(entity) then return 'object' end
    return nil
end

---@param model string|number
---@return number
local function resolveModelHash(model)
    if type(model) == 'string' then
        if ZedState.modelHashCache[model] == nil then
            ZedState.modelHashCache[model] = GetHashKey(model)
        end
        return ZedState.modelHashCache[model]
    end
    return model
end

---@param opts table
---@return string
function UI.AddContextOption(opts)
    assert("CONTEXT", type(opts) == 'table', "AddContextOption() — opts must be a table.", 2)
    local hasEntity = type(opts.entity) == 'number' and opts.entity ~= 0
    local hasModel = opts.model ~= nil
    local hasType = opts.type ~= nil
    assert("CONTEXT", not (hasEntity and hasModel), "AddContextOption() — Cannot use both entity and model.", 2)
    assert("CONTEXT", not (hasEntity and hasType), "AddContextOption() — Cannot use both entity and type.", 2)
    assert("CONTEXT", not (hasModel and hasType), "AddContextOption() — Cannot use both model and type.", 2)
    assert("CONTEXT", type(opts.label) == 'string' and opts.label ~= '', "AddContextOption() — opts.label is required (non-empty string).", 2)
    if opts.onSelect ~= nil then
        assert("CONTEXT", type(opts.onSelect) == 'function' or type(opts.onSelect) == 'string', "AddContextOption() — opts.onSelect must be a function or callback id (string) when provided.", 2)
    end
    if opts.entity ~= nil and (type(opts.entity) ~= 'number' or opts.entity == 0) then
        log("WARN", "CONTEXT", "AddContextOption() — opts.entity is invalid (0 or nil); option ignored.", nil)
        return opts.id or genCtxId('opt')
    end
    if opts.submenu ~= nil and opts.submenu ~= '' then
        local found = false
        for _, subs in pairs(contextSubMenus) do
            if subs[opts.submenu] then found = true break end
        end
        for _, subs in pairs(contextEntitySubMenus) do
            if subs[opts.submenu] then found = true break end
        end
        for _, subs in pairs(contextModelSubMenus) do
            if subs[opts.submenu] then found = true break end
        end
        assert("CONTEXT", found, "AddContextOption() — opts.submenu '" .. tostring(opts.submenu) .. "' must be registered with AddContextSubMenu first.", 2)
    end

    local id = opts.id or genCtxId('opt')
    local callbackAction = 'context:' .. id

    local option = {
        id = id,
        label = opts.label or '',
        icon = opts.icon or nil,
        disabled = opts.disabled or false,
        submenu = opts.submenu or nil,
        callbackAction = callbackAction,
    }

    if opts.entity then
        local ent = opts.entity
        if not contextEntityOptions[ent] then
            contextEntityOptions[ent] = {}
        end
        contextEntityOptions[ent][id] = option
    elseif opts.model then
        local hash = resolveModelHash(opts.model)
        if not contextModelOptions[hash] then
            contextModelOptions[hash] = {}
        end
        contextModelOptions[hash][id] = option
    else
        local entType = opts.type or 'all'
        option.type = entType
        if not contextOptions[entType] then
            contextOptions[entType] = {}
        end
        contextOptions[entType][id] = option
    end

    if opts.onSelect then
        contextCallbacks[callbackAction] = function(entity, entityType, coords)
            fireCallback(opts.onSelect, entity, entityType, coords)
        end
    end

    trackResource(id, 'option')
    return id
end

---@param opts table
---@return string submenuId
function UI.AddContextSubMenu(opts)
    local id = opts.id or genCtxId('sub')

    local sub = {
        id = id,
        label = opts.label or '',
        icon = opts.icon or nil,
    }

    if opts.entity then
        local ent = opts.entity
        if not contextEntitySubMenus[ent] then
            contextEntitySubMenus[ent] = {}
        end
        contextEntitySubMenus[ent][id] = sub
    elseif opts.model then
        local hash = resolveModelHash(opts.model)
        if not contextModelSubMenus[hash] then
            contextModelSubMenus[hash] = {}
        end
        contextModelSubMenus[hash][id] = sub
    else
        local entType = opts.type or 'all'
        if not contextSubMenus[entType] then
            contextSubMenus[entType] = {}
        end
        contextSubMenus[entType][id] = sub
    end

    trackResource(id, 'submenu')
    return id
end

---@param id string
function UI.RemoveContextOption(id)
    local function searchAndRemove(store)
        for key, options in pairs(store) do
            if options[id] then
                local opt = options[id]
                if opt.callbackAction then
                    contextCallbacks[opt.callbackAction] = nil
                end
                options[id] = nil
                return true
            end
        end
        return false
    end

    if searchAndRemove(contextOptions) then return end
    if searchAndRemove(contextEntityOptions) then return end
    searchAndRemove(contextModelOptions)
end

--- Remove a submenu
---@param id string The submenu identifier
local function removeSubmenu(id)
    local function searchAndRemove(store)
        for key, subs in pairs(store) do
            if subs[id] then
                subs[id] = nil
                return true
            end
        end
        return false
    end

    if searchAndRemove(contextSubMenus) then return end
    if searchAndRemove(contextEntitySubMenus) then return end
    searchAndRemove(contextModelSubMenus)
end

--- Clear the context menu
function UI.ClearContext()
    contextOptions = {}
    contextSubMenus = {}
    contextEntityOptions = {}
    contextEntitySubMenus = {}
    contextModelOptions = {}
    contextModelSubMenus = {}
    contextCallbacks = {}
end

---@param enabled boolean
function UI.SetContextEnabled(enabled)
    contextEnabled = enabled ~= false
end

---@return boolean
function UI.IsContextEnabled()
    return contextEnabled
end

---@return boolean
function UI.IsContextOpen()
    return contextOpen
end

--- Close the context menu
function UI.CloseContext()
    if contextOpen then
        contextOpen = false
        contextEntity = nil
        contextEntityType = nil
        contextCoords = nil
        SendUI('zedlib:closeContext', {})
    end
end

--- Build the options for an entity
---@param entity number The entity handle
---@param entType string The entity type
---@return table options The options for the entity
local function buildOptionsForEntity(entity, entType)
    local result = {}
    local subMenuItems = {}

    local function collectSubs(subs)
        if not subs then return end
        for subId, sub in pairs(subs) do
            if not subMenuItems[subId] then
                subMenuItems[subId] = {
                    id = sub.id,
                    label = sub.label,
                    icon = sub.icon,
                    children = {},
                }
            end
        end
    end

    local function collectOpts(opts)
        if not opts then return end
        for _, opt in pairs(opts) do
            local item = {
                id = opt.id,
                label = opt.label,
                icon = opt.icon,
                disabled = opt.disabled,
                onSelect = opt.callbackAction,
            }
            if opt.submenu and subMenuItems[opt.submenu] then
                table.insert(subMenuItems[opt.submenu].children, item)
            else
                table.insert(result, item)
            end
        end
    end

    collectSubs(contextSubMenus[entType])
    collectOpts(contextOptions[entType])
    if entType == 'mycar' then
        collectSubs(contextSubMenus['vehicle'])
        collectOpts(contextOptions['vehicle'])
    end
    if entType ~= 'all' then
        collectSubs(contextSubMenus['all'])
        collectOpts(contextOptions['all'])
    end

    collectSubs(contextEntitySubMenus[entity])
    collectOpts(contextEntityOptions[entity])

    local model = GetEntityModel(entity)
    if model then
        collectSubs(contextModelSubMenus[model])
        collectOpts(contextModelOptions[model])
    end

    for _, sub in pairs(subMenuItems) do
        if #sub.children > 0 then
            table.insert(result, sub)
        end
    end

    return result
end

--- Open the context menu for an entity
---@param entity number The entity handle
---@param entType string The entity type
---@param coords vector3 The entity coordinates
---@param screenX number The screen X position
---@param screenY number The screen Y position
function UI.OpenContextForEntity(entity, entType, coords, screenX, screenY)
    if not entity or entity == 0 then return end

    local options = buildOptionsForEntity(entity, entType)
    if #options == 0 then return end

    contextOpen = true
    contextEntity = entity
    contextEntityType = entType
    contextCoords = coords

    SendUI('zedlib:openContext', {
        options = options,
        entityType = entType,
        entityId = entity,
        position = { x = screenX, y = screenY },
    })
end

RegisterNUICallback('zedlib:contextAction', function(data, cb)
    local action = data.action
    if action and contextCallbacks[action] then
        local ok, err = pcall(contextCallbacks[action], contextEntity, contextEntityType, contextCoords)
        if not ok and ZedInternal and ZedInternal.log then
            ZedInternal.log("ERROR", "CONTEXT", "Context callback error: " .. tostring(err), nil)
        end
    end
    contextOpen = false
    contextEntity = nil
    contextEntityType = nil
    contextCoords = nil
    cb('ok')
end)

RegisterNUICallback('zedlib:contextClosed', function(_, cb)
    contextOpen = false
    contextEntity = nil
    contextEntityType = nil
    contextCoords = nil
    cb('ok')
end)

AddEventHandler('onResourceStop', function(resourceName)
    local entries = contextResourceMap[resourceName]
    if not entries then return end

    for _, entry in ipairs(entries) do
        if entry.kind == 'option' then
            UI.RemoveContextOption(entry.id)
        elseif entry.kind == 'submenu' then
            removeSubmenu(entry.id)
        end
    end

    contextResourceMap[resourceName] = nil
end)

ZedInternal.contextGetEntityType = getEntityType
ZedInternal.contextBuildOptions = buildOptionsForEntity
ZedInternal.contextIsEnabled = function() return contextEnabled and ZedConfig.enableContextMenu end
ZedInternal.contextIsOpen = function() return contextOpen end
ZedInternal.contextOpenForEntity = UI.OpenContextForEntity
ZedInternal.contextClose = UI.CloseContext
