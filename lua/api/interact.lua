local interactConfigs = {}
local interactNextId = 0
local interactShownId = nil
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

local function findClosestEntityOfType(typeStr, maxDist)
    local ped = PlayerPedId()
    local myCoords = GetEntityCoords(ped)
    local closest, minDist = nil, maxDist

    if typeStr == 'ped' then
        for _, e in ipairs(GetGamePool('CPed')) do
            if e ~= ped and DoesEntityExist(e) and not IsPedDeadOrDying(e, true) then
                local d = #(myCoords - GetEntityCoords(e))
                if d < minDist then
                    minDist = d
                    closest = e
                end
            end
        end
    elseif typeStr == 'vehicle' then
        for _, e in ipairs(GetGamePool('CVehicle')) do
            if DoesEntityExist(e) then
                local d = #(myCoords - GetEntityCoords(e))
                if d < minDist then
                    minDist = d
                    closest = e
                end
            end
        end
    elseif typeStr == 'object' then
        for _, e in ipairs(GetGamePool('CObject')) do
            if DoesEntityExist(e) then
                local d = #(myCoords - GetEntityCoords(e))
                if d < minDist then
                    minDist = d
                    closest = e
                end
            end
        end
    end

    return closest
end

--- Resolve world position and target entity from opts. Returns coords, entity (entity is nil when using coords only).
---@param opts table { coords? = vector3|function, entity? = number, type? = 'ped'|'vehicle'|'object', label = string, key? = string, distance? = number, onSelect? = function }
---@return vector3|nil coords
---@return number|nil entity
local function getInteractPosition(opts)
    if opts.entity and DoesEntityExist(opts.entity) then
        return GetEntityCoords(opts.entity) + vector3(0, 0, 1.0), opts.entity
    end
    if opts.type then
        local dist = opts.distance or 2.0
        local closest = findClosestEntityOfType(opts.type, dist)
        if closest then
            return GetEntityCoords(closest) + vector3(0, 0, 1.0), closest
        end
        return nil, nil
    end
    return getCoords(opts), nil
end

--- Get the control key for a given key string.
---@param key string|number Key to get the control for.
---@return number control Control key.
local function getControlForKey(key)
    if type(key) == 'number' then return key end
    local k = type(key) == 'string' and key:upper():sub(1, 1) or nil
    return k and KEY_TO_CONTROL[k] or 38
end

--- Add an interact prompt. Multiple interacts can exist; the one closest to the player (in range and on screen) is shown.
---@param opts table { coords? = vector3|function, entity? = number, type? = 'ped'|'vehicle'|'object', label = string, key? = string, distance? = number, onSelect? = function }
---@return number|nil id Optional handle to clear this interact with ClearInteract(id). Nil if opts invalid.
function UI.SetInteract(opts)
    if not opts or not opts.label or not (opts.coords or opts.entity or opts.type) then
        return nil
    end
    interactNextId = interactNextId + 1
    local id = interactNextId
    interactConfigs[id] = opts
    return id
end

--- Clear one or all interact prompt(s). Pass id from SetInteract to clear that one; pass nil to clear all.
---@param id number|nil Interact id to remove, or nil to clear all.
function UI.ClearInteract(id)
    if id then
        interactConfigs[id] = nil
        if interactShownId == id then
            interactShownId = nil
            SendUI('zedlib:interactHide', {})
        end
    else
        interactConfigs = {}
        interactShownId = nil
        SendUI('zedlib:interactHide', {})
    end
end

-- InteractProgress: hold key for duration, progress bar, onSelect when done / onCancel when released
local interactProgressConfig = nil
local progressElapsed = 0
local progressHolding = false

--- Set the current interact progress prompt. Player must hold the key for duration; onSelect when complete, onCancel when released early or leaving range.
---@param opts table { coords?, entity?, type?, label, key?, distance?, duration, removeOnComplete?, onSelect?, onCancel? }
function UI.SetInteractProgress(opts)
    local hasTarget = opts and opts.label and opts.duration and (opts.coords or opts.entity or opts.type)
    interactProgressConfig = hasTarget and opts or nil
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
    local waitMs = 200
    while true do
        if next(interactConfigs) == nil then
            waitMs = 200
        else
            local ped = PlayerPedId()
            local pedCoords = GetEntityCoords(ped)
            -- Remove configs whose entity no longer exists
            for id, cfg in pairs(interactConfigs) do
                if cfg.entity and not DoesEntityExist(cfg.entity) then
                    interactConfigs[id] = nil
                    if interactShownId == id then
                        interactShownId = nil
                        SendUI('zedlib:interactHide', {})
                    end
                end
            end
            -- Find best candidate: in range, on screen, closest
            local bestId, bestDist, bestSX, bestSY, bestEntity = nil, nil, nil, nil, nil
            for id, cfg in pairs(interactConfigs) do
                local coords, entity = getInteractPosition(cfg)
                if coords then
                    local dist = #(pedCoords - coords)
                    local distance = cfg.distance or 2.0
                    if dist <= distance then
                        local onScreen, sX, sY = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z + 0.5)
                        if onScreen and (bestId == nil or dist < bestDist) then
                            bestId = id
                            bestDist = dist
                            bestSX = sX
                            bestSY = sY
                            bestEntity = entity
                        end
                    end
                end
            end
            if bestId then
                waitMs = 0
                local cfg = interactConfigs[bestId]
                cfg._currentEntity = bestEntity
                if interactShownId ~= bestId then
                    interactShownId = bestId
                    SendUI('zedlib:interactShow', {
                        x = bestSX,
                        y = bestSY,
                        label = cfg.label,
                        key = cfg.key,
                    })
                else
                    SendUI('zedlib:interactUpdatePos', { x = bestSX, y = bestSY })
                end
                local control = getControlForKey(cfg.key or 'E')
                if IsControlJustPressed(0, control) or IsDisabledControlJustPressed(0, control) then
                    SendUI('zedlib:interactKeyPressed', {})
                    if cfg.onSelect then
                        local ok, err = pcall(cfg.onSelect, cfg._currentEntity)
                        if not ok and ZedInternal and ZedInternal.log then
                            ZedInternal.log("ERROR", "INTERACT", "Interact onSelect error: " .. tostring(err), nil)
                        end
                    end
                end
            else
                if interactShownId then
                    interactShownId = nil
                    SendUI('zedlib:interactHide', {})
                end
                waitMs = next(interactConfigs) and 200 or 200
            end
        end
        Wait(waitMs)
    end
end)

-- InteractProgress thread: show prompt, track hold duration, progress bar, onSelect/onCancel
CreateThread(function()
    local waitMs = 150
    while true do
        if interactProgressConfig then
            if interactProgressConfig.entity and not DoesEntityExist(interactProgressConfig.entity) then
                interactProgressConfig = nil
                progressElapsed = 0
                progressHolding = false
                SendUI('zedlib:interactProgressHide', {})
                waitMs = 150
            else
                local coords, entity = getInteractPosition(interactProgressConfig)
                if coords then
                    local ped = PlayerPedId()
                    local pedCoords = GetEntityCoords(ped)
                    local dist = #(pedCoords - coords)
                    local distance = interactProgressConfig.distance or 2.0
                    local duration = interactProgressConfig.duration or 3000
                    local control = getControlForKey(interactProgressConfig.key or 'E')
                    local keyPressed = IsControlPressed(0, control) or IsDisabledControlPressed(0, control)

                    if dist <= distance then
                        waitMs = 0
                        interactProgressConfig._currentEntity = entity
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
                                    -- Player must release key before starting again (when removeOnComplete = false)
                                else
                                    if not progressHolding then
                                        progressHolding = true
                                        interactProgressConfig._holdEntity = entity
                                        interactProgressConfig._lastTick = GetGameTimer()
                                        SendUI('zedlib:interactProgressKeyPressed', {})
                                    end
                                    local now = GetGameTimer()
                                    progressElapsed = progressElapsed + (now - interactProgressConfig._lastTick)
                                    interactProgressConfig._lastTick = now
                                    local pct = math.min(100, (progressElapsed / duration) * 100)
                                    SendUI('zedlib:interactProgressUpdateProgress', { progress = pct })

                                    if progressElapsed >= duration then
                                        local targetEntity = interactProgressConfig._holdEntity
                                        if interactProgressConfig.onSelect then
                                            local ok, err = pcall(interactProgressConfig.onSelect, targetEntity)
                                            if not ok and ZedInternal and ZedInternal.log then
                                                ZedInternal.log("ERROR", "INTERACT", "InteractProgress onSelect error: " .. tostring(err), nil)
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
                                            interactProgressConfig._holdEntity = nil
                                            interactProgressConfig._mustRelease = true
                                            SendUI('zedlib:interactProgressUpdateProgress', { progress = 0 })
                                        end
                                    end
                                end
                            else
                                interactProgressConfig._mustRelease = nil
                                if progressHolding then
                                    local targetEntity = interactProgressConfig._holdEntity
                                    progressHolding = false
                                    SendUI('zedlib:interactProgressHide', {})
                                    if interactProgressConfig.onCancel then
                                        local ok, err = pcall(interactProgressConfig.onCancel, targetEntity)
                                        if not ok and ZedInternal and ZedInternal.log then
                                            ZedInternal.log("ERROR", "INTERACT", "InteractProgress onCancel error: " .. tostring(err), nil)
                                        end
                                    end
                                    interactProgressConfig._shown = nil
                                    progressElapsed = 0
                                end
                                interactProgressConfig._lastTick = nil
                                interactProgressConfig._holdEntity = nil
                            end
                        else
                            -- Not on screen
                            if progressHolding and interactProgressConfig.onCancel then
                                pcall(interactProgressConfig.onCancel, interactProgressConfig._holdEntity)
                            end
                            progressHolding = false
                            progressElapsed = 0
                            interactProgressConfig._shown = nil
                            SendUI('zedlib:interactProgressHide', {})
                            waitMs = 100
                        end
                    else
                        -- Out of range (dist > distance)
                        if progressHolding and interactProgressConfig.onCancel then
                            pcall(interactProgressConfig.onCancel, interactProgressConfig._holdEntity)
                        end
                        progressHolding = false
                        progressElapsed = 0
                        interactProgressConfig._shown = nil
                        SendUI('zedlib:interactProgressHide', {})
                        waitMs = 100
                    end
                else
                    -- No coords resolved
                    if progressHolding and interactProgressConfig.onCancel then
                        pcall(interactProgressConfig.onCancel, interactProgressConfig._holdEntity)
                    end
                    progressHolding = false
                    progressElapsed = 0
                    interactProgressConfig._shown = nil
                    SendUI('zedlib:interactProgressHide', {})
                    waitMs = 150
                end
            end
        else
            waitMs = 150
        end
        Wait(waitMs)
    end
end)