local fireCallback = ZedInternal.fireCallback

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
--- Generate a context menu item identifier
---@param prefix string The prefix for the identifier
---@return string id The generated identifier
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

--- Resolve a model hash
---@param model string|number The model name or hash
---@return number hash The model hash
local function resolveModelHash(model)
    if type(model) == 'string' then
        return GetHashKey(model)
    end
    return model
end

---@param opts table
---@return string optionId
function UI.AddContextOption(opts)
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
        if not ok then
            print('[ZedLib] ^1Context callback error:^0 ' .. tostring(err))
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
