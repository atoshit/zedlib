---@param opts table
function UI.SetConfig(opts)
    opts = opts or {}
    if opts.debug ~= nil then ZedConfig.debug = opts.debug == true end
    if opts.debugFilter ~= nil then ZedConfig.debugFilter = opts.debugFilter end
    if opts.refreshInterval ~= nil and type(opts.refreshInterval) == 'number' then
        ZedConfig.refreshInterval = opts.refreshInterval
    end
    SendUI('zedlib:setConfig', opts)
end

--- Copy text to the clipboard
---@param text string The text to copy
function UI.CopyToClipboard(text)
    SendUI('zedlib:copyToClipboard', { text = tostring(text) })
end
