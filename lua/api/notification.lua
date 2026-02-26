--- Display a notification
---@param type string The notification type ('success'|'error'|'warning'|'info')
---@param title string The notification title
---@param subtitle? string Optional subtitle below the title
---@param message? string The notification message (description)
---@param duration? number The display duration in milliseconds (default: 5000)
---@param color? string The accent color (hex)
---@param image? string Optional image URL shown at top-left of the notification
function UI.Notify(type, title, subtitle, message, duration, color, image)
    SendUI('zedlib:notify', {
        type = type,
        title = title,
        subtitle = subtitle or nil,
        message = message or nil,
        duration = duration or 5000,
        color = color or nil,
        image = image or nil,
    })
end

--- Display a success notification
---@param title string
---@param subtitle? string
---@param message? string
---@param duration? number
---@param color? string
---@param image? string
function UI.NotifySuccess(title, subtitle, message, duration, color, image)
    UI.Notify('success', title, subtitle, message, duration, color, image)
end

--- Display an error notification
---@param title string
---@param subtitle? string
---@param message? string
---@param duration? number
---@param color? string
---@param image? string
function UI.NotifyError(title, subtitle, message, duration, color, image)
    UI.Notify('error', title, subtitle, message, duration, color, image)
end

--- Display a warning notification
---@param title string
---@param subtitle? string
---@param message? string
---@param duration? number
---@param color? string
---@param image? string
function UI.NotifyWarning(title, subtitle, message, duration, color, image)
    UI.Notify('warning', title, subtitle, message, duration, color, image)
end

--- Display an info notification
---@param title string
---@param subtitle? string
---@param message? string
---@param duration? number
---@param color? string
---@param image? string
function UI.NotifyInfo(title, subtitle, message, duration, color, image)
    UI.Notify('info', title, subtitle, message, duration, color, image)
end

--- Clear all active notifications
function UI.ClearNotifications()
    SendUI('zedlib:clearNotifications', {})
end
