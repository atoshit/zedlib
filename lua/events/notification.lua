local NOTIF_TYPES <const> = { success = true, error = true, warning = true, info = true }

RegisterNetEvent('zedlib:notify', function(data)
    if type(data) ~= 'table' then return end

    local t = data.type
    if type(t) ~= 'string' or not NOTIF_TYPES[t] then
        t = 'info'
    end

    SendUI('zedlib:notify', {
        type = t,
        title = type(data.title) == 'string' and data.title or '',
        subtitle = data.subtitle,
        message = data.message,
        duration = type(data.duration) == 'number' and data.duration > 0 and data.duration or 5000,
        color = type(data.color) == 'string' and data.color or nil,
        image = type(data.image) == 'string' and data.image or nil,
    })
end)
