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
---@field CopyToClipboard fun(text: string)
---@field ProgressBar fun(opts: ZedProgressBarOptions): boolean
---@field CancelProgressBar fun()
---@field IsProgressActive fun(): boolean
---@field SetInteract fun(opts: ZedInteractOptions): number|nil Returns id to clear this interact with ClearInteract(id). Nil if opts invalid.
---@field ClearInteract fun(id?: number) Clear one interact (pass id from SetInteract) or all (omit id).
---@field SetInteractProgress fun(opts: ZedInteractProgressOptions)
---@field ClearInteractProgress fun()
---@field AddContextOption fun(opts: ZedContextOptionData): string
---@field AddContextSubMenu fun(opts: ZedContextSubMenuData): string
---@field RemoveContextOption fun(id: string)
---@field ClearContext fun()
---@field SetContextEnabled fun(enabled: boolean)
---@field IsContextEnabled fun(): boolean
---@field IsContextOpen fun(): boolean
---@field CloseContext fun()

---@class ZedContextOptionData
---@field type? 'vehicle'|'ped'|'player'|'object'|'myself'|'mycar'|'all' Entity type filter (default: 'all')
---@field entity? number Specific entity handle to target (overrides type)
---@field model? string|number Model name or hash to target all props of this model (overrides type)
---@field label string Display label for the option
---@field icon? string FontAwesome icon name (e.g. 'wrench') or image URL
---@field id? string Custom unique identifier
---@field disabled? boolean Whether the option is disabled (default: false)
---@field submenu? string Submenu id to nest this option inside
---@field onSelect? fun(entity: number, entityType: string, coords: vector3) Callback when option is selected

---@class ZedContextSubMenuData
---@field type? 'vehicle'|'ped'|'player'|'object'|'myself'|'mycar'|'all' Entity type filter (default: 'all')
---@field entity? number Specific entity handle (overrides type)
---@field model? string|number Model name or hash (overrides type)
---@field id? string Custom unique identifier for the submenu
---@field label string Display label for the submenu
---@field icon? string FontAwesome icon name or image URL

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
---@field infoData? ZedInfoData[] Info panel data shown on the right when this item is focused
---@field onSelect? fun(data: table) Callback fired when the button is selected

---@class ZedCheckboxOptions
---@field label string Display label for the checkbox
---@field description? string Text shown in the description panel below the menu when this item is focused
---@field icon? string FontAwesome icon name or image URL
---@field id? string Custom unique identifier for this item
---@field disabled? boolean Whether the checkbox is disabled (default: false)
---@field category? string Category id: item is only visible when this category is expanded
---@field checked? boolean Initial checked state (default: false)
---@field infoData? ZedInfoData[] Info panel data shown on the right when this item is focused
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
---@field infoData? ZedInfoData[] Info panel data shown on the right when this item is focused

---@class ZedCategoryOptions
---@field label string Display label for the category header
---@field description? string Text shown in the description panel below the menu when this item is focused
---@field id string Category id (used in opts.category when adding items to this category)
---@field icon? string FontAwesome icon name or image URL
---@field disabled? boolean Whether the category header is disabled (default: false)
---@field infoData? ZedInfoData[] Info panel data shown on the right when this item is focused

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
---@field infoData? ZedInfoData[] Info panel data shown on the right when this item is focused
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
---@field infoData? ZedInfoData[] Info panel data shown on the right when this item is focused
---@field onChange? fun(value: number) Callback fired when the slider value changes

---@class ZedProgressBarOptions
---@field duration? number Duration in milliseconds (default: 5000)
---@field label? string Text displayed above the progress bar
---@field canCancel? boolean Whether the progress can be cancelled with ESC/Backspace (default: true)
---@field anim? ZedProgressAnim Animation to play during the progress
---@field prop? ZedProgressProp Prop to attach to the player during the progress
---@field disable? ZedProgressDisable Controls to disable during the progress

---@class ZedProgressAnim
---@field dict string Animation dictionary name
---@field clip string Animation clip name
---@field flag? number Animation flag (default: 49)

---@class ZedProgressProp
---@field model string|number Prop model name or hash
---@field pos? vector3 Offset position relative to the bone (default: vec3(0,0,0))
---@field rot? vector3 Rotation relative to the bone (default: vec3(0,0,0))
---@field bone? number Bone index to attach to (default: 60309 = right hand)

---@class ZedProgressDisable
---@field move? boolean Disable player movement
---@field car? boolean Disable vehicle controls
---@field combat? boolean Disable combat/firing
---@field mouse? boolean Disable camera/mouse

---@class ZedInteractOptions
---@field coords? vector3|fun():vector3 World position (or function returning it). Omit if using entity or type.
---@field entity? number Specific entity handle. Prompt is shown on this entity (coords + offset).
---@field type? 'ped'|'vehicle'|'object' Entity type: prompt is shown on the closest entity of this type in range.
---@field label string Text displayed next to the key
---@field key? string Key to show (e.g. 'E'). If omitted, no key box is shown
---@field distance? number Max distance to show the prompt (default: 2.0)
---@field onSelect? function Callback when the player presses the key: onSelect(entity). entity is the targeted entity (nil if using coords only).

---@class ZedInteractProgressOptions
---@field coords? vector3|fun():vector3 World position (or function returning it). Omit if using entity or type.
---@field entity? number Specific entity handle. Prompt is shown on this entity.
---@field type? 'ped'|'vehicle'|'object' Entity type: prompt is shown on the closest entity of this type in range.
---@field label string Text displayed in the prompt
---@field key? string Key to show (e.g. 'E'). If omitted, no key box is shown
---@field distance? number Max distance to show the prompt (default: 2.0)
---@field duration number Time in ms the player must hold the key
---@field removeOnComplete? boolean If true (default), the prompt is removed after the action. If false, it stays so the player can repeat the action.
---@field onSelect? function Callback when the player holds for the full duration: onSelect(entity). entity is the targeted entity (nil if using coords only).
---@field onCancel? function Callback when the player releases early or leaves range: onCancel(entity). entity is the entity that was being targeted when the hold started.

---@class ZedDialogButton
---@field label string Display label for the button
---@field variant? 'primary'|'secondary'|'danger' Visual style of the button (default: 'secondary')
---@field action? string Action identifier sent to the callback
---@field icon? string FontAwesome icon name displayed before the label (e.g. 'trash')
---@field backgroundColor? string Custom background color for the button (hex/rgba). Overrides variant background.
---@field onPress? fun(values: table) Callback fired when the button is pressed. Receives input values.

---@class ZedDialogSelectOption
---@field value string Value submitted when selected
---@field label string Display label in the list

---@class ZedDialogInput
---@field id? string Input field identifier (default: 'input_N')
---@field type? 'text'|'number'|'password'|'textarea'|'date'|'select'|'multiselect'|'checkbox' Input type (default: 'text')
---@field label string Display label for the input field
---@field placeholder? string Placeholder text (select: placeholder when nothing selected)
---@field default? string|boolean|string[] Default value. Checkbox: true/false. Multiselect: array of option values (e.g. {'a','b'}). Others: string.
---@field required? boolean Whether the input is required (default: false)
---@field maxLength? number Maximum character length
---@field min? number Minimum value (number type only)
---@field max? number Maximum value (number type only)
---@field options? ZedDialogSelectOption[] Options for select and multiselect (value + label)
---@field checkboxLabel? string Label next to the checkbox when type is 'checkbox' (default: 'Yes')

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

--- Register a context menu option for entities.
---@param opts ZedContextOptionData Option configuration
---@return string optionId The generated or custom option identifier
function zed.AddContextOption(opts)
    local o = {}
    for k, v in pairs(opts) do o[k] = v end
    o.onSelect = storeCb(opts.onSelect)
    return call('AddContextOption', o)
end

--- Register a context menu submenu for entities.
---@param opts ZedContextSubMenuData Submenu configuration
---@return string submenuId The generated or custom submenu identifier
function zed.AddContextSubMenu(opts)
    return call('AddContextSubMenu', opts)
end

--- Remove a context menu option by its id.
---@param id string Option identifier to remove
function zed.RemoveContextOption(id)
    call('RemoveContextOption', id)
end

--- Remove all context menu options and submenus.
function zed.ClearContext()
    call('ClearContext')
end

--- Enable or disable the context menu targeting system.
---@param enabled boolean Whether targeting is enabled
function zed.SetContextEnabled(enabled)
    call('SetContextEnabled', enabled)
end

--- Check whether the context menu targeting system is enabled.
---@return boolean
function zed.IsContextEnabled()
    return call('IsContextEnabled')
end

--- Check whether a context menu is currently open.
---@return boolean
function zed.IsContextOpen()
    return call('IsContextOpen')
end

--- Close the currently open context menu.
function zed.CloseContext()
    call('CloseContext')
end

--- Copy text to the clipboard.
---@param text string The text to copy
function zed.CopyToClipboard(text)
    call('CopyToClipboard', text)
end

--- Show a progress bar. Blocks until complete or cancelled.
---@param opts ZedProgressBarOptions
---@return boolean completed true if finished, false if cancelled
function zed.ProgressBar(opts)
    return call('ProgressBar', opts)
end

--- Cancel the active progress bar.
function zed.CancelProgressBar()
    call('CancelProgressBar')
end

--- Check if a progress bar is currently active.
---@return boolean
function zed.IsProgressActive()
    return call('IsProgressActive')
end

--- Add an interact prompt. Multiple interacts can exist; the closest one in range is shown. Returns id to clear with ClearInteract(id).
---@param opts ZedInteractOptions
---@return number|nil
function zed.Interact(opts)
    return call('SetInteract', opts)
end

--- Clear one interact (pass id from Interact) or all (omit id).
---@param id number|nil
function zed.ClearInteract(id)
    call('ClearInteract', id)
end

--- Set the current interact progress prompt (hold key for duration). onSelect when complete, onCancel when released early.
---@param opts ZedInteractProgressOptions
function zed.InteractProgress(opts)
    call('SetInteractProgress', opts)
end

--- Clear the current interact progress prompt.
function zed.ClearInteractProgress()
    call('ClearInteractProgress')
end
