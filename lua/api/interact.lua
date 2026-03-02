local interactConfig = nil
local KEY_TO_CONTROL = {
    ['E'] = 38,
    ['G'] = 47,
    ['F'] = 23,
    ['R'] = 45,
    ['Q'] = 44,
    ['Z'] = 20,
    ['X'] = 73,
    ['C'] = 26,
    ['T'] = 245,
    ['Y'] = 246,
}

local function getCoords(opts)
    local c = opts.coords
    if type(c) == 'function' then return c() end
    return c
end

local function getControlForKey(key)
    if type(key) == 'number' then return key end
    local k = type(key) == 'string' and key:upper():sub(1, 1) or nil
    return k and KEY_TO_CONTROL[k] or 38
end

--- Set the current interact prompt. When the player is within distance, the prompt is shown at coords. When they press the key, onSelect is called.
---@param opts table { coords = vector3|function, label = string, key? = string, distance? = number, onSelect? = function }
function UI.SetInteract(opts)
    interactConfig = opts and (opts.coords and opts.label) and opts or nil
end

--- Clear the current interact prompt.
function UI.ClearInteract()
    interactConfig = nil
    SendUI('zedlib:interactHide', {})
end

-- InteractProgress: hold key for duration, progress bar, onSelect when done / onCancel when released
local interactProgressConfig = nil
local progressElapsed = 0
local progressHolding = false

--- Set the current interact progress prompt. Player must hold the key for duration; onSelect when complete, onCancel when released early or leaving range.
---@param opts table { coords, label, key?, distance?, duration, onSelect?, onCancel? }
function UI.SetInteractProgress(opts)
    interactProgressConfig = opts and (opts.coords and opts.label and opts.duration) and opts or nil
    progressElapsed = 0
    progressHolding = false
    if not interactProgressConfig then
        SendUI('zedlib:interactProgressHide', {})
    end
end

--- Clear the current interact progress prompt.
function UI.ClearInteractProgress()
    interactProgressConfig = nil
    progressElapsed = 0
    progressHolding = false
    SendUI('zedlib:interactProgressHide', {})
end

CreateThread(function()
    while true do
        if interactConfig then
            local coords = getCoords(interactConfig)
            if coords then
                local ped = PlayerPedId()
                local pedCoords = GetEntityCoords(ped)
                local dist = #(pedCoords - coords)
                local distance = interactConfig.distance or 2.0

                if dist <= distance then
                    local onScreen, sX, sY = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z + 0.5)
                    if onScreen then
                        if not interactConfig._shown then
                            interactConfig._shown = true
                            SendUI('zedlib:interactShow', {
                                x = sX,
                                y = sY,
                                label = interactConfig.label,
                                key = interactConfig.key,
                            })
                        else
                            SendUI('zedlib:interactUpdatePos', { x = sX, y = sY })
                        end

                        local control = getControlForKey(interactConfig.key or 'E')
                        if IsControlJustPressed(0, control) or IsDisabledControlJustPressed(0, control) then
                            SendUI('zedlib:interactKeyPressed', {})
                            if interactConfig.onSelect then
                                local ok, err = pcall(interactConfig.onSelect)
                                if not ok then
                                    print('[ZedLib] ^1Interact onSelect error:^0 ' .. tostring(err))
                                end
                            end
                        end
                    else
                        if interactConfig._shown then
                            interactConfig._shown = nil
                            SendUI('zedlib:interactHide', {})
                        end
                    end
                else
                    if interactConfig._shown then
                        interactConfig._shown = nil
                        SendUI('zedlib:interactHide', {})
                    end
                end
            end
            Wait(0)
        else
            Wait(500)
        end
    end
end)

-- InteractProgress thread: show prompt, track hold duration, progress bar, onSelect/onCancel
CreateThread(function()
    while true do
        if interactProgressConfig then
            local coords = getCoords(interactProgressConfig)
            if coords then
                local ped = PlayerPedId()
                local pedCoords = GetEntityCoords(ped)
                local dist = #(pedCoords - coords)
                local distance = interactProgressConfig.distance or 2.0
                local duration = interactProgressConfig.duration or 3000
                local control = getControlForKey(interactProgressConfig.key or 'E')
                local keyPressed = IsControlPressed(0, control) or IsDisabledControlPressed(0, control)

                if dist <= distance then
                    local onScreen, sX, sY = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z + 0.5)
                    if onScreen then
                        if not interactProgressConfig._shown then
                            interactProgressConfig._shown = true
                            progressElapsed = 0
                            progressHolding = false
                            SendUI('zedlib:interactProgressShow', {
                                x = sX,
                                y = sY,
                                label = interactProgressConfig.label,
                                key = interactProgressConfig.key,
                                duration = duration,
                            })
                        else
                            SendUI('zedlib:interactProgressUpdatePos', { x = sX, y = sY })
                        end

                        if keyPressed then
                            if interactProgressConfig._mustRelease then
                                -- Player must release E before starting again (when removeOnComplete = false)
                            else
                                if not progressHolding then
                                    progressHolding = true
                                    interactProgressConfig._lastTick = GetGameTimer()
                                    SendUI('zedlib:interactProgressKeyPressed', {})
                                end
                                local now = GetGameTimer()
                                progressElapsed = progressElapsed + (now - interactProgressConfig._lastTick)
                                interactProgressConfig._lastTick = now
                                local pct = math.min(100, (progressElapsed / duration) * 100)
                                SendUI('zedlib:interactProgressUpdateProgress', { progress = pct })

                                if progressElapsed >= duration then
                                    if interactProgressConfig.onSelect then
                                        local ok, err = pcall(interactProgressConfig.onSelect)
                                        if not ok then
                                            print('[ZedLib] ^1InteractProgress onSelect error:^0 ' .. tostring(err))
                                        end
                                    end
                                    local removeOnComplete = interactProgressConfig.removeOnComplete ~= false
                                    if removeOnComplete then
                                        SendUI('zedlib:interactProgressHide', {})
                                        interactProgressConfig._shown = nil
                                        progressElapsed = 0
                                        progressHolding = false
                                        interactProgressConfig = nil
                                    else
                                        progressElapsed = 0
                                        progressHolding = false
                                        interactProgressConfig._lastTick = nil
                                        interactProgressConfig._mustRelease = true
                                        SendUI('zedlib:interactProgressUpdateProgress', { progress = 0 })
                                    end
                                end
                            end
                        else
                            interactProgressConfig._mustRelease = nil
                            if progressHolding then
                                progressHolding = false
                                SendUI('zedlib:interactProgressHide', {})
                                if interactProgressConfig.onCancel then
                                    local ok, err = pcall(interactProgressConfig.onCancel)
                                    if not ok then
                                        print('[ZedLib] ^1InteractProgress onCancel error:^0 ' .. tostring(err))
                                    end
                                end
                                interactProgressConfig._shown = nil
                                progressElapsed = 0
                            end
                            interactProgressConfig._lastTick = nil
                        end
                    else
                        if interactProgressConfig._shown then
                            if progressHolding and interactProgressConfig.onCancel then
                                pcall(interactProgressConfig.onCancel)
                            end
                            progressHolding = false
                            progressElapsed = 0
                            interactProgressConfig._shown = nil
                            SendUI('zedlib:interactProgressHide', {})
                        end
                    end
                else
                    if interactProgressConfig._shown then
                        if progressHolding and interactProgressConfig.onCancel then
                            pcall(interactProgressConfig.onCancel)
                        end
                        progressHolding = false
                        progressElapsed = 0
                        interactProgressConfig._shown = nil
                        SendUI('zedlib:interactProgressHide', {})
                    end
                end
            end
            Wait(0)
        else
            Wait(150)
        end
    end
end)
