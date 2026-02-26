--- Send a notification to a specific player.
---@param source number Player server ID
---@param data table Same as ZedNotifyData (title, type?, subtitle?, message?, duration?, color?, image?)
function NotifyPlayer(source, data)
    if type(source) ~= 'number' or source < 0 then return end
    if type(data) ~= 'table' then return end
    TriggerClientEvent('zedlib:notify', source, data)
end

--- Send a notification to all connected players.
---@param data table Same as ZedNotifyData (title, type?, subtitle?, message?, duration?, color?, image?)
function NotifyAll(data)
    if type(data) ~= 'table' then return end
    TriggerClientEvent('zedlib:notify', -1, data)
end

exports('Notify', NotifyPlayer)
exports('NotifyToAll', NotifyAll)
