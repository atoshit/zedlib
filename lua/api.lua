UI = {}

local menuItemCounters = {}

--- Generate a unique ID for a menu item
---@param menuId string The menu identifier
---@param prefix string The prefix for the ID
---@return string The generated ID
local function generateId(menuId, prefix)
    if not menuItemCounters[menuId] then
        menuItemCounters[menuId] = 0
    end
    menuItemCounters[menuId] = menuItemCounters[menuId] + 1
    return prefix .. '_' .. menuId .. '_' .. menuItemCounters[menuId]
end

--- Fire a callback
---@param cb function The callback function
---@param ... any The arguments to pass to the callback
local function fireCallback(cb, ...)
    if type(cb) == 'string' then
        TriggerEvent('zedlib:triggerCallback', cb, ...)
    elseif type(cb) == 'function' then
        cb(...)
    end
end

--- Create a menu
---@param id string The menu identifier
---@param title string The menu title
---@param subtitle string The menu subtitle
---@param opts table The menu options
---@return nil
function UI.CreateMenu(id, title, subtitle, opts)
    opts = opts or {}
    menuItemCounters[id] = 0
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
            metadata = opts.metadata or nil
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
            onChange = callbackAction
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

    menuItemCounters[subMenuId] = 0
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
            icon = opts.icon or nil,
            disabled = opts.disabled or false,
            targetMenu = subMenuId
        }
    })

    return subMenuId
end

--- Add a separator to a menu
---@param menuId string The menu identifier
---@return string The generated item ID
function UI.AddSeparator(menuId)
    local itemId = generateId(menuId, 'sep')

    SendUI('zedlib:addMenuItem', {
        menuId = menuId,
        item = {
            id = itemId,
            type = 'separator'
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
            onChange = callbackAction
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
            onChange = callbackAction
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
            icon = opts.icon or 'magnifying-glass',
            placeholder = opts.placeholder or 'Tapez pour rechercher...',
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
        }
    })

    return itemId
end

local isMenuOpen = false

--- Check if a menu is open
---@return boolean True if the menu is open, false otherwise
function UI.IsMenuOpen()
    return isMenuOpen
end

--- Set the menu open flag
---@param state boolean The state to set
---@return nil
function UI.SetMenuOpenFlag(state)
    isMenuOpen = state
end

--- Open a menu
---@param id string The menu identifier
---@return nil
function UI.OpenMenu(id)
    SendUI('zedlib:openMenu', { id = id })
    isMenuOpen = true
end

--- Close a menu
---@return nil
function UI.CloseMenu()
    SendUI('zedlib:closeMenu', {})
    isMenuOpen = false
end

--- Remove a menu
---@param id string The menu identifier
---@return nil
function UI.RemoveMenu(id)
    SendUI('zedlib:removeMenu', { id = id })
    menuItemCounters[id] = nil
end

--- Notify a user
---@param type string The notification type
---@param title string The notification title
---@param message string The notification message
---@param duration number The notification duration in milliseconds
---@param color string The accent color (hex)
---@return nil
function UI.Notify(type, title, message, duration, color)
    SendUI('zedlib:notify', {
        type = type,
        title = title,
        message = message or nil,
        duration = duration or 5000,
        color = color or nil,
    })
end

--- Notify a success message
---@param title string The notification title
---@param message string The notification message
---@param duration number The notification duration in milliseconds
---@param color string The accent color (hex)
---@return nil
function UI.NotifySuccess(title, message, duration, color)
    UI.Notify('success', title, message, duration, color)
end

--- Notify an error message
---@param title string The notification title
---@param message string The notification message
---@param duration number The notification duration in milliseconds
---@param color string The accent color (hex)
---@return nil
function UI.NotifyError(title, message, duration, color)
    UI.Notify('error', title, message, duration, color)
end

--- Notify a warning message
---@param title string The notification title
---@param message string The notification message
---@param duration number The notification duration in milliseconds
---@param color string The accent color (hex)
---@return nil
function UI.NotifyWarning(title, message, duration, color)
    UI.Notify('warning', title, message, duration, color)
end

--- Notify an info message
---@param title string The notification title
---@param message string The notification message
---@param duration number The notification duration in milliseconds
---@param color string The accent color (hex)
---@return nil
function UI.NotifyInfo(title, message, duration, color)
    UI.Notify('info', title, message, duration, color)
end

--- Clear all notifications
---@return nil
function UI.ClearNotifications()
    SendUI('zedlib:clearNotifications', {})
end

--- Open a dialog
---@param opts table The dialog options
---@return string The dialog identifier
function UI.Dialog(opts)
    local dialogId = opts.id or ('dialog_' .. GetGameTimer())

    local inputs = {}
    if opts.inputs then
        for i, input in ipairs(opts.inputs) do
            inputs[i] = {
                id = input.id or ('input_' .. i),
                type = input.type or 'text',
                label = input.label,
                placeholder = input.placeholder or nil,
                defaultValue = input.default or nil,
                required = input.required or false,
                maxLength = input.maxLength or nil,
                min = input.min or nil,
                max = input.max or nil
            }
        end
    end

    local buttons = {}
    if opts.buttons then
        for i, btn in ipairs(opts.buttons) do
            buttons[i] = {
                label = btn.label,
                variant = btn.variant or 'secondary',
                action = btn.action or ('action_' .. i),
                icon = btn.icon or nil,
            }

            if btn.onPress then
                RegisterDialogCallback(dialogId, btn.action or ('action_' .. i), function(values)
                    fireCallback(btn.onPress, values)
                end)
            end
        end
    end

    SendUI('zedlib:openDialog', {
        id = dialogId,
        type = opts.type or 'input',
        title = opts.title,
        message = opts.message or nil,
        inputs = inputs,
        buttons = buttons,
        closable = opts.closable ~= false,
        color = opts.color or nil,
        icon = opts.icon or nil,
    })

    SetNuiFocus(true, true)

    if opts.onResult then
        RegisterDialogCallback(dialogId, function(action, values)
            fireCallback(opts.onResult, action, values)
            SetNuiFocus(false, false)
        end)
    end

    return dialogId
end

--- Open a confirm dialog
---@param title string The dialog title
---@param message string The dialog message
---@param onConfirm function The callback function to fire when the user confirms
---@param onCancel function The callback function to fire when the user cancels
---@param color string The accent color (hex)
---@return string The dialog identifier
function UI.Confirm(title, message, onConfirm, onCancel, color)
    UI.Dialog({
        title = title,
        message = message,
        type = 'confirm',
        color = color or nil,
        buttons = {
            {
                label = 'Cancel',
                variant = 'secondary',
                action = 'cancel',
                onPress = function()
                    if onCancel then fireCallback(onCancel) end
                end
            },
            {
                label = 'Confirm',
                variant = 'primary',
                action = 'confirm',
                onPress = function()
                    if onConfirm then fireCallback(onConfirm) end
                end
            }
        }
    })
end

--- Close a dialog
---@return nil
function UI.CloseDialog()
    SendUI('zedlib:closeDialog', {})
    SetNuiFocus(false, false)
end

--- Set the configuration
---@param opts table The configuration options
---@return nil
function UI.SetConfig(opts)
    SendUI('zedlib:setConfig', opts or {})
end

exports('CreateMenu', UI.CreateMenu)
exports('AddButton', UI.AddButton)
exports('AddCheckbox', UI.AddCheckbox)
exports('AddSubMenu', UI.AddSubMenu)
exports('AddSeparator', UI.AddSeparator)
exports('AddList', UI.AddList)
exports('AddSlider', UI.AddSlider)
exports('AddSearchButton', UI.AddSearchButton)
exports('AddInfoButton', UI.AddInfoButton)
exports('OpenMenu', UI.OpenMenu)
exports('CloseMenu', UI.CloseMenu)
exports('IsMenuOpen', UI.IsMenuOpen)
exports('RemoveMenu', UI.RemoveMenu)
exports('Notify', UI.Notify)
exports('NotifySuccess', UI.NotifySuccess)
exports('NotifyError', UI.NotifyError)
exports('NotifyWarning', UI.NotifyWarning)
exports('NotifyInfo', UI.NotifyInfo)
exports('ClearNotifications', UI.ClearNotifications)
exports('Dialog', UI.Dialog)
exports('Confirm', UI.Confirm)
exports('CloseDialog', UI.CloseDialog)
exports('SetConfig', UI.SetConfig)