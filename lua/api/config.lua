--- Update the runtime configuration
---@param opts table The configuration options
function UI.SetConfig(opts)
    SendUI('zedlib:setConfig', opts or {})
end

--- Copy text to the clipboard
---@param text string The text to copy
function UI.CopyToClipboard(text)
    SendUI('zedlib:copyToClipboard', { text = tostring(text) })
end
