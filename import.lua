---@class ZedLib
---@field CreateMenu fun(id: string, title: string, subtitle?: string, opts?: ZedMenuOptions)
---@field AddButton fun(menuId: string, opts: ZedButtonOptions): string
---@field AddCheckbox fun(menuId: string, opts: ZedCheckboxOptions): string
---@field AddSubMenu fun(menuId: string, subMenuId: string, label: string, opts?: ZedSubMenuOptions): string
---@field AddSeparator fun(menuId: string, opts?: ZedSeparatorOptions): string
---@field AddCategory fun(menuId: string, opts: ZedCategoryOptions): string
---@field AddSearchButton fun(menuId: string, opts?: ZedSearchButtonOptions): string
---@field AddInfoButton fun(menuId: string, opts: ZedInfoButtonOptions): string
---@field AddList fun(menuId: string, opts: ZedListOptions): string
---@field AddSlider fun(menuId: string, opts: ZedSliderOptions): string
---@field OpenMenu fun(id: string)
---@field CloseMenu fun()
---@field IsMenuOpen fun(): boolean
---@field RemoveMenu fun(id: string)
---@field Notify fun(data: ZedNotifyData)
---@field ClearNotifications fun()
---@field Dialog fun(opts: ZedDialogOptions): string
---@field Confirm fun(title: string, message: string, onConfirm?: fun(), onCancel?: fun(), color?: string)
---@field CloseDialog fun()
---@field SetConfig fun(opts: ZedConfigOptions)

---@class ZedMenuOptions
---@field color? string Accent color for the menu (hex, e.g. '#e74c3c'). Inherited by submenus.
---@field banner? string URL of the banner image displayed in the menu header. Inherited by submenus.

---@class ZedButtonOptions
---@field label string Display label for the button
---@field description? string Text shown in the description panel below the menu when this item is focused
---@field icon? string FontAwesome icon name (e.g. 'gear') or image URL (png/jpg)
---@field id? string Custom unique identifier for this item
---@field disabled? boolean Whether the button is disabled (default: false)
---@field category? string Category id: item is only visible when this category is expanded
---@field metadata? table Arbitrary data passed to the onSelect callback
---@field rightLabel? string Text displayed on the right side of the button (e.g. a price like '$500')
---@field rightLabelColor? string Color of the rightLabel text (hex, e.g. '#22c55e')
---@field onSelect? fun(data: table) Callback fired when the button is selected

---@class ZedCheckboxOptions
---@field label string Display label for the checkbox
---@field description? string Text shown in the description panel below the menu when this item is focused
---@field icon? string FontAwesome icon name or image URL
---@field id? string Custom unique identifier for this item
---@field disabled? boolean Whether the checkbox is disabled (default: false)
---@field category? string Category id: item is only visible when this category is expanded
---@field checked? boolean Initial checked state (default: false)
---@field onChange? fun(checked: boolean) Callback fired when the checkbox is toggled

---@class ZedSubMenuOptions
---@field description? string Text shown in the description panel below the menu when this item is focused
---@field icon? string FontAwesome icon name or image URL
---@field id? string Custom unique identifier for this item
---@field disabled? boolean Whether the submenu button is disabled (default: false)
---@field category? string Category id: item is only visible when this category is expanded
---@field subtitle? string Title override for the submenu header (defaults to label)
---@field color? string Accent color override for this submenu
---@field banner? string Banner image URL override for this submenu

---@class ZedCategoryOptions
---@field label string Display label for the category header
---@field description? string Text shown in the description panel below the menu when this item is focused
---@field id string Category id (used in opts.category when adding items to this category)
---@field icon? string FontAwesome icon name or image URL
---@field disabled? boolean Whether the category header is disabled (default: false)

---@class ZedSeparatorOptions
---@field description? string Text shown in the description panel below the menu when this item is focused
---@field category? string Category id: separator is only visible when this category is expanded

---@class ZedSearchButtonOptions
---@field label? string Display label (default: 'Rechercher')
---@field description? string Text shown in the description panel below the menu when this item is focused
---@field icon? string FontAwesome icon name or image URL (default: 'magnifying-glass')
---@field placeholder? string Placeholder text shown when search is active (default: 'Tapez pour rechercher...')
---@field id? string Custom unique identifier for this item
---@field category? string Category id: item is only visible when this category is expanded

---@class ZedInfoData
---@field label string Display label for the data row
---@field value string|number Display value for the data row

---@class ZedInfoButtonOptions
---@field label string Display label for the info button
---@field description? string Text shown in the description panel below the menu when this item is focused
---@field icon? string FontAwesome icon name or image URL
---@field id? string Custom unique identifier for this item
---@field disabled? boolean Whether the info button is disabled (default: false)
---@field category? string Category id: item is only visible when this category is expanded
---@field data ZedInfoData[] Array of label/value pairs displayed in the info panel

---@class ZedListItem
---@field label string Display label for the option
---@field value string Value identifier for the option

---@class ZedListOptions
---@field label string Display label for the list
---@field description? string Text shown in the description panel below the menu when this item is focused
---@field icon? string FontAwesome icon name or image URL
---@field id? string Custom unique identifier for this item
---@field disabled? boolean Whether the list is disabled (default: false)
---@field category? string Category id: item is only visible when this category is expanded
---@field items ZedListItem[]|string[] Array of options (strings are auto-converted to {label, value})
---@field currentIndex? number Initial selected index, 1-based (default: 1)
---@field onChange? fun(index: number, item: ZedListItem) Callback fired when the selected option changes. Index is 1-based.

---@class ZedSliderOptions
---@field label string Display label for the slider
---@field description? string Text shown in the description panel below the menu when this item is focused
---@field icon? string FontAwesome icon name or image URL
---@field id? string Custom unique identifier for this item
---@field disabled? boolean Whether the slider is disabled (default: false)
---@field category? string Category id: item is only visible when this category is expanded
---@field min? number Minimum value (default: 0)
---@field max? number Maximum value (default: 100)
---@field step? number Step increment (default: 1)
---@field value? number Initial value (default: 0)
---@field onChange? fun(value: number) Callback fired when the slider value changes

---@class ZedDialogButton
---@field label string Display label for the button
---@field variant? 'primary'|'secondary'|'danger' Visual style of the button (default: 'secondary')
---@field action? string Action identifier sent to the callback
---@field icon? string FontAwesome icon name displayed before the label (e.g. 'trash')
---@field onPress? fun(values: table) Callback fired when the button is pressed. Receives input values.

---@class ZedDialogInput
---@field id? string Input field identifier (default: 'input_N')
---@field type? 'text'|'number'|'password' Input type (default: 'text')
---@field label string Display label for the input field
---@field placeholder? string Placeholder text
---@field default? string|number Default value
---@field required? boolean Whether the input is required (default: false)
---@field maxLength? number Maximum character length
---@field min? number Minimum value (number type only)
---@field max? number Maximum value (number type only)

---@class ZedDialogOptions
---@field id? string Custom dialog identifier
---@field type? 'input'|'confirm' Dialog type (default: 'input')
---@field title string Dialog title
---@field message? string Dialog description message
---@field inputs? ZedDialogInput[] Array of input fields
---@field buttons? ZedDialogButton[] Array of action buttons
---@field closable? boolean Whether the dialog can be dismissed (default: true)
---@field color? string Accent color for the dialog (hex, e.g. '#e74c3c')
---@field icon? string FontAwesome icon name displayed in the dialog header (e.g. 'circle-question')
---@field onResult? fun(action: string, values: table) Global callback receiving the action and all input values

---@class ZedNotifyData
---@field title string Notification title (required)
---@field type? 'success'|'error'|'warning'|'info' Notification type (default: 'info', omit for shortcuts)
---@field subtitle? string Subtitle below the title
---@field message? string Body text (description)
---@field duration? number Display duration in milliseconds (default: 5000)
---@field color? string Accent color (hex)
---@field image? string Image URL shown at top-left of the notification

---@class ZedConfigOptions
---@field sounds? boolean Enable or disable UI sounds (default: true)

---@type ZedLib
zed = {}

local _callbacks = {}
local _nextId = 0
local _resName = GetCurrentResourceName()

local function call(fn, ...)
    return exports.zedlib[fn](exports.zedlib, ...)
end

local function storeCb(fn)
    if type(fn) ~= 'function' then return fn end
    _nextId = _nextId + 1
    local id = _resName .. ':cb:' .. _nextId
    _callbacks[id] = fn
    return id
end

AddEventHandler('zedlib:triggerCallback', function(cbId, ...)
    if _callbacks[cbId] then
        _callbacks[cbId](...)
    end
end)

--- Create a new menu. Must be called before adding items.
---@param id string Unique menu identifier
---@param title string Menu title displayed in the header
---@param subtitle? string Subtitle displayed below the title (only shown when no banner)
---@param opts? ZedMenuOptions Additional menu options (color, banner)
function zed.CreateMenu(id, title, subtitle, opts)
    call('CreateMenu', id, title, subtitle, opts)
end

--- Add a button item to a menu.
---@param menuId string Target menu identifier
---@param opts ZedButtonOptions Button configuration
---@return string itemId The generated or custom item identifier
function zed.AddButton(menuId, opts)
    local o = {}
    for k, v in pairs(opts) do o[k] = v end
    o.onSelect = storeCb(opts.onSelect)
    return call('AddButton', menuId, o)
end

--- Add a checkbox item to a menu.
---@param menuId string Target menu identifier
---@param opts ZedCheckboxOptions Checkbox configuration
---@return string itemId The generated or custom item identifier
function zed.AddCheckbox(menuId, opts)
    local o = {}
    for k, v in pairs(opts) do o[k] = v end
    o.onChange = storeCb(opts.onChange)
    return call('AddCheckbox', menuId, o)
end

--- Add a submenu item and automatically register the target submenu.
---@param menuId string Parent menu identifier
---@param subMenuId string Unique identifier for the new submenu
---@param label string Display label for the submenu button
---@param opts? ZedSubMenuOptions Submenu configuration
---@return string subMenuId The submenu identifier (use to add items to it)
function zed.AddSubMenu(menuId, subMenuId, label, opts)
    return call('AddSubMenu', menuId, subMenuId, label, opts)
end

--- Add a visual separator line to a menu.
---@param menuId string Target menu identifier
---@param opts? ZedSeparatorOptions Optional: category to show separator only when category is expanded
---@return string itemId The generated item identifier
function zed.AddSeparator(menuId, opts)
    return call('AddSeparator', menuId, opts)
end

--- Add a category header. When selected, toggles visibility of items that have opts.category equal to this category id.
---@param menuId string Target menu identifier
---@param opts ZedCategoryOptions Category label and id (id is used in other items' category option)
---@return string categoryId The category id (use in opts.category when adding items)
function zed.AddCategory(menuId, opts)
    return call('AddCategory', menuId, opts)
end

--- Add a search/filter button to a menu. Filters items in real-time when activated.
---@param menuId string Target menu identifier
---@param opts? ZedSearchButtonOptions Search button configuration
---@return string itemId The generated or custom item identifier
function zed.AddSearchButton(menuId, opts)
    return call('AddSearchButton', menuId, opts)
end

--- Add an info button to a menu. Displays a panel with label/value pairs when hovered.
---@param menuId string Target menu identifier
---@param opts ZedInfoButtonOptions Info button configuration
---@return string itemId The generated or custom item identifier
function zed.AddInfoButton(menuId, opts)
    return call('AddInfoButton', menuId, opts)
end

--- Add a list selector item to a menu.
---@param menuId string Target menu identifier
---@param opts ZedListOptions List configuration
---@return string itemId The generated or custom item identifier
function zed.AddList(menuId, opts)
    local o = {}
    for k, v in pairs(opts) do o[k] = v end
    o.onChange = storeCb(opts.onChange)
    return call('AddList', menuId, o)
end

--- Add a slider item to a menu.
---@param menuId string Target menu identifier
---@param opts ZedSliderOptions Slider configuration
---@return string itemId The generated or custom item identifier
function zed.AddSlider(menuId, opts)
    local o = {}
    for k, v in pairs(opts) do o[k] = v end
    o.onChange = storeCb(opts.onChange)
    return call('AddSlider', menuId, o)
end

--- Open a registered menu by its identifier.
---@param id string Menu identifier to open
function zed.OpenMenu(id)
    call('OpenMenu', id)
end

--- Close the currently open menu.
function zed.CloseMenu()
    call('CloseMenu')
end

--- Check whether a menu is currently open.
---@return boolean isOpen True if a menu is currently visible
function zed.IsMenuOpen()
    return call('IsMenuOpen')
end

--- Remove a registered menu and free its resources.
---@param id string Menu identifier to remove
function zed.RemoveMenu(id)
    call('RemoveMenu', id)
end

--- Display a notification.
---@param data ZedNotifyData Table with title and optional type, subtitle, message, duration, color, image
function zed.Notify(data)
    call('Notify', data)
end

--- Clear all active notifications.
function zed.ClearNotifications()
    call('ClearNotifications')
end

--- Open a dialog with input fields and/or action buttons.
---@param opts ZedDialogOptions Dialog configuration
---@return string dialogId The dialog identifier
function zed.Dialog(opts)
    local o = {}
    for k, v in pairs(opts) do o[k] = v end
    o.onResult = storeCb(opts.onResult)
    if opts.buttons then
        o.buttons = {}
        for i, btn in ipairs(opts.buttons) do
            local b = {}
            for k, v in pairs(btn) do b[k] = v end
            b.onPress = storeCb(btn.onPress)
            o.buttons[i] = b
        end
    end
    return call('Dialog', o)
end

--- Open a simple confirm/cancel dialog.
---@param title string Dialog title
---@param message string Dialog message
---@param onConfirm? fun() Callback fired when the user confirms
---@param onCancel? fun() Callback fired when the user cancels
---@param color? string Accent color override (hex, e.g. '#e74c3c')
function zed.Confirm(title, message, onConfirm, onCancel, color)
    call('Confirm', title, message, storeCb(onConfirm), storeCb(onCancel), color)
end

--- Close the currently open dialog.
function zed.CloseDialog()
    call('CloseDialog')
end

--- Update the ZedLib runtime configuration.
---@param opts ZedConfigOptions Configuration options to update
function zed.SetConfig(opts)
    call('SetConfig', opts)
end
