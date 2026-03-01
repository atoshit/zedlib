local generateId = ZedInternal.generateId
local fireCallback = ZedInternal.fireCallback
local counters = ZedInternal.menuItemCounters

local isMenuOpen = false

--- Create a menu
---@param id string The menu identifier
---@param title string The menu title
---@param subtitle string The menu subtitle
---@param opts table The menu options
function UI.CreateMenu(id, title, subtitle, opts)
    opts = opts or {}
    counters[id] = 0
    SendUI('zedlib:registerMenu', {
        id = id,
        title = title,
        subtitle = subtitle or nil,
        color = opts.color or nil,
        banner = opts.banner or nil,
        items = {}
    })
end

--- Add a button to a menu
---@param menuId string The menu identifier
---@param opts table The button options
---@return string The generated item ID
function UI.AddButton(menuId, opts)
    local itemId = opts.id or generateId(menuId, 'btn')
    local callbackAction = 'menu:' .. menuId .. ':' .. itemId

    SendUI('zedlib:addMenuItem', {
        menuId = menuId,
        item = {
            id = itemId,
            type = 'button',
            label = opts.label,
            description = opts.description or nil,
            icon = opts.icon or nil,
            disabled = opts.disabled or false,
            onSelect = callbackAction,
            metadata = opts.metadata or nil,
            category = opts.category or nil,
            rightLabel = opts.rightLabel or nil,
            rightLabelColor = opts.rightLabelColor or nil,
        }
    })

    if opts.onSelect then
        RegisterMenuCallback(callbackAction, function(data)
            fireCallback(opts.onSelect, data)
        end)
    end

    return itemId
end

--- Add a checkbox to a menu
---@param menuId string The menu identifier
---@param opts table The checkbox options
---@return string The generated item ID
function UI.AddCheckbox(menuId, opts)
    local itemId = opts.id or generateId(menuId, 'chk')
    local callbackAction = 'menu:' .. menuId .. ':' .. itemId

    SendUI('zedlib:addMenuItem', {
        menuId = menuId,
        item = {
            id = itemId,
            type = 'checkbox',
            label = opts.label,
            description = opts.description or nil,
            icon = opts.icon or nil,
            disabled = opts.disabled or false,
            checked = opts.checked or false,
            onChange = callbackAction,
            category = opts.category or nil,
        }
    })

    if opts.onChange then
        RegisterMenuCallback(callbackAction, function(data)
            fireCallback(opts.onChange, data.checked)
        end)
    end

    return itemId
end

--- Add a submenu to a menu
---@param menuId string The menu identifier
---@param subMenuId string The submenu identifier
---@param label string The submenu label
---@param opts table The submenu options
---@return string The submenu identifier
function UI.AddSubMenu(menuId, subMenuId, label, opts)
    opts = opts or {}
    local itemId = opts.id or generateId(menuId, 'sub')

    counters[subMenuId] = 0
    SendUI('zedlib:registerMenu', {
        id = subMenuId,
        title = opts.subtitle or label,
        subtitle = nil,
        color = opts.color or nil,
        banner = opts.banner or nil,
        items = {}
    })

    SendUI('zedlib:addMenuItem', {
        menuId = menuId,
        item = {
            id = itemId,
            type = 'submenu',
            label = label,
            description = opts.description or nil,
            icon = opts.icon or nil,
            disabled = opts.disabled or false,
            targetMenu = subMenuId,
            category = opts.category or nil,
        }
    })

    return subMenuId
end

--- Add a category header to a menu. When selected, toggles visibility of items with the same category id.
---@param menuId string The menu identifier
---@param opts table The category options (label, icon?, id = category id, disabled?)
---@return string The category item id (use this id in opts.category when adding items)
function UI.AddCategory(menuId, opts)
    local itemId = opts.id or generateId(menuId, 'cat')
    SendUI('zedlib:addMenuItem', {
        menuId = menuId,
        item = {
            id = itemId,
            type = 'category',
            label = opts.label,
            description = opts.description or nil,
            icon = opts.icon or nil,
            disabled = opts.disabled or false,
        }
    })
    return itemId
end

--- Add a separator to a menu
---@param menuId string The menu identifier
---@param opts table Optional: category = string to show only when category is expanded
---@return string The generated item ID
function UI.AddSeparator(menuId, opts)
    opts = opts or {}
    local itemId = generateId(menuId, 'sep')

    SendUI('zedlib:addMenuItem', {
        menuId = menuId,
        item = {
            id = itemId,
            type = 'separator',
            description = opts.description or nil,
            category = opts.category or nil,
        }
    })

    return itemId
end

--- Add a list to a menu
---@param menuId string The menu identifier
---@param opts table The list options
---@return string The generated item ID
function UI.AddList(menuId, opts)
    local itemId = opts.id or generateId(menuId, 'list')
    local callbackAction = 'menu:' .. menuId .. ':' .. itemId

    local listItems = {}
    for i, item in ipairs(opts.items) do
        if type(item) == 'string' then
            listItems[i] = { label = item, value = item }
        else
            listItems[i] = item
        end
    end

    SendUI('zedlib:addMenuItem', {
        menuId = menuId,
        item = {
            id = itemId,
            type = 'list',
            label = opts.label,
            description = opts.description or nil,
            icon = opts.icon or nil,
            disabled = opts.disabled or false,
            items = listItems,
            currentIndex = (opts.currentIndex or 1) - 1,
            onChange = callbackAction,
            category = opts.category or nil,
        }
    })

    if opts.onChange then
        RegisterMenuCallback(callbackAction, function(data)
            fireCallback(opts.onChange, data.index + 1, data.value)
        end)
    end

    return itemId
end

--- Add a slider to a menu
---@param menuId string The menu identifier
---@param opts table The slider options
---@return string The generated item ID
function UI.AddSlider(menuId, opts)
    local itemId = opts.id or generateId(menuId, 'slider')
    local callbackAction = 'menu:' .. menuId .. ':' .. itemId

    SendUI('zedlib:addMenuItem', {
        menuId = menuId,
        item = {
            id = itemId,
            type = 'slider',
            label = opts.label,
            description = opts.description or nil,
            icon = opts.icon or nil,
            disabled = opts.disabled or false,
            min = opts.min or 0,
            max = opts.max or 100,
            step = opts.step or 1,
            value = opts.value or 0,
            onChange = callbackAction,
            category = opts.category or nil,
        }
    })

    if opts.onChange then
        RegisterMenuCallback(callbackAction, function(data)
            fireCallback(opts.onChange, data.value)
        end)
    end

    return itemId
end

--- Add a search button to a menu
---@param menuId string The menu identifier
---@param opts table The search button options
---@return string The generated item ID
function UI.AddSearchButton(menuId, opts)
    opts = opts or {}
    local itemId = opts.id or generateId(menuId, 'search')

    SendUI('zedlib:addMenuItem', {
        menuId = menuId,
        item = {
            id = itemId,
            type = 'search',
            label = opts.label or 'Rechercher',
            description = opts.description or nil,
            icon = opts.icon or 'magnifying-glass',
            placeholder = opts.placeholder or 'Tapez pour rechercher...',
            category = opts.category or nil,
        }
    })

    return itemId
end

--- Add an info button to a menu
---@param menuId string The menu identifier
---@param opts table The info button options
---@return string The generated item ID
function UI.AddInfoButton(menuId, opts)
    local itemId = opts.id or generateId(menuId, 'info')

    local infoData = {}
    if opts.data then
        for i, row in ipairs(opts.data) do
            infoData[i] = {
                label = row.label,
                value = tostring(row.value),
            }
        end
    end

    SendUI('zedlib:addMenuItem', {
        menuId = menuId,
        item = {
            id = itemId,
            type = 'info',
            label = opts.label,
            description = opts.description or nil,
            icon = opts.icon or nil,
            disabled = opts.disabled or false,
            infoData = infoData,
            category = opts.category or nil,
        }
    })

    return itemId
end

--- Check if a menu is open
---@return boolean
function UI.IsMenuOpen()
    return isMenuOpen
end

--- Set the menu open flag (internal)
---@param state boolean
function UI.SetMenuOpenFlag(state)
    isMenuOpen = state
end

--- Open a menu
---@param id string The menu identifier
function UI.OpenMenu(id)
    SendUI('zedlib:openMenu', { id = id })
    isMenuOpen = true
end

--- Close the current menu
function UI.CloseMenu()
    SendUI('zedlib:closeMenu', {})
    isMenuOpen = false
end

--- Remove a menu
---@param id string The menu identifier
function UI.RemoveMenu(id)
    SendUI('zedlib:removeMenu', { id = id })
    counters[id] = nil
end
