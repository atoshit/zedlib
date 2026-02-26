--- Update the runtime configuration
---@param opts table The configuration options
function UI.SetConfig(opts)
    SendUI('zedlib:setConfig', opts or {})
end
