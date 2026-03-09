local fireCallback = ZedInternal.fireCallback

--- Open a dialog with input fields and/or action buttons
---@param opts table The dialog options
---@return string The dialog identifier
function UI.Dialog(opts)
    local dialogId = opts.id or ('dialog_' .. GetGameTimer())

    local inputs = {}
    if opts.inputs then
        for i, input in ipairs(opts.inputs) do
            local defaultVal = input.default
            if input.type == 'checkbox' then
                if defaultVal == nil then defaultVal = 'false' end
                if type(defaultVal) == 'boolean' then defaultVal = defaultVal and 'true' or 'false' end
            elseif input.type == 'multiselect' and type(defaultVal) == 'table' then
                defaultVal = json.encode(defaultVal)
            end
            inputs[i] = {
                id = input.id or ('input_' .. i),
                type = input.type or 'text',
                label = input.label,
                placeholder = input.placeholder or nil,
                defaultValue = defaultVal and tostring(defaultVal) or nil,
                required = input.required or false,
                maxLength = input.maxLength or nil,
                min = input.min or nil,
                max = input.max or nil,
                options = input.options or nil,
                checkboxLabel = input.checkboxLabel or nil,
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
                backgroundColor = btn.backgroundColor or nil,
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

--- Open a simple confirm/cancel dialog
---@param title string The dialog title
---@param message string The dialog message
---@param onConfirm? function Callback fired on confirm
---@param onCancel? function Callback fired on cancel
---@param color? string The accent color (hex)
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

--- Close the active dialog
function UI.CloseDialog()
    SendUI('zedlib:closeDialog', {})
    SetNuiFocus(false, false)
end
