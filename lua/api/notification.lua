--- Display a notification
---@param type string The notification type ('success'|'error'|'warning'|'info')
---@param title string The notification title
---@param message? string The notification message
---@param duration? number The display duration in milliseconds (default: 5000)
---@param color? string The accent color (hex)
function UI.Notify(type, title, message, duration, color)
    SendUI('zedlib:notify', {
        type = type,
        title = title,
        message = message or nil,
        duration = duration or 5000,
        color = color or nil,
    })
end

--- Display a success notification
---@param title string
---@param message? string
---@param duration? number
---@param color? string
function UI.NotifySuccess(title, message, duration, color)
    UI.Notify('success', title, message, duration, color)
end

--- Display an error notification
---@param title string
---@param message? string
---@param duration? number
---@param color? string
function UI.NotifyError(title, message, duration, color)
    UI.Notify('error', title, message, duration, color)
end

--- Display a warning notification
---@param title string
---@param message? string
---@param duration? number
---@param color? string
function UI.NotifyWarning(title, message, duration, color)
    UI.Notify('warning', title, message, duration, color)
end

--- Display an info notification
---@param title string
---@param message? string
---@param duration? number
---@param color? string
function UI.NotifyInfo(title, message, duration, color)
    UI.Notify('info', title, message, duration, color)
end

--- Clear all active notifications
function UI.ClearNotifications()
    SendUI('zedlib:clearNotifications', {})
end
