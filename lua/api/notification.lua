--- Display a notification
---@param data table Notification options
---@param data.type? string One of 'success'|'error'|'warning'|'info' (default: 'info')
---@param data.title string Notification title
---@param data.subtitle? string Subtitle below the title
---@param data.message? string Body text (description)
---@param data.duration? number Display duration in ms (default: 5000)
---@param data.color? string Accent color (hex)
---@param data.image? string Image URL at top-left of the notification
function UI.Notify(data)
    data = data or {}
    SendUI('zedlib:notify', {
        type = data.type or 'info',
        title = data.title or '',
        subtitle = data.subtitle or '',
        message = data.message or '',
        duration = data.duration or 5000,
        color = data.color,
        image = data.image,
    })
end

--- Clear all active notifications
function UI.ClearNotifications()
    SendUI('zedlib:clearNotifications', {})
end
