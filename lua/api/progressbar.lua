local progressActive = false
local progressCancelled = false
local progressPromise = nil

RegisterNUICallback('zedlib:progressComplete', function(data, cb)
    if progressActive then
        progressCancelled = data.cancelled == true
        progressActive = false
    end
    cb('ok')
end)

local function loadAnimDict(dict)
    if HasAnimDictLoaded(dict) then return end
    RequestAnimDict(dict)
    local timeout = GetGameTimer() + 5000
    while not HasAnimDictLoaded(dict) and GetGameTimer() < timeout do
        Wait(0)
    end
end

local function loadModel(model)
    local hash = type(model) == 'string' and GetHashKey(model) or model
    if HasModelLoaded(hash) then return hash end
    RequestModel(hash)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(hash) and GetGameTimer() < timeout do
        Wait(0)
    end
    return hash
end

--- Show a progress bar. Blocks the current thread until complete or cancelled.
---@param opts table Progress bar options
---@return boolean completed true if finished, false if cancelled
function UI.ProgressBar(opts)
    if progressActive then return false end

    opts = opts or {}
    local duration = opts.duration or 5000
    local label = opts.label or ''
    local canCancel = opts.canCancel ~= false
    local anim = opts.anim
    local prop = opts.prop
    local disable = opts.disable or {}

    progressActive = true
    progressCancelled = false

    local ped = PlayerPedId()
    local propEntity = nil

    if anim and anim.dict and anim.clip then
        loadAnimDict(anim.dict)
        local flag = anim.flag or 49
        TaskPlayAnim(ped, anim.dict, anim.clip, 8.0, -8.0, -1, flag, 0, false, false, false)
    end

    if prop and prop.model then
        local hash = loadModel(prop.model)
        if HasModelLoaded(hash) then
            local pos = prop.pos or vector3(0.0, 0.0, 0.0)
            local rot = prop.rot or vector3(0.0, 0.0, 0.0)
            local bone = prop.bone or 60309
            propEntity = CreateObject(hash, 0.0, 0.0, 0.0, true, true, true)
            AttachEntityToEntity(propEntity, ped, GetPedBoneIndex(ped, bone),
                pos.x, pos.y, pos.z, rot.x, rot.y, rot.z,
                true, true, false, true, 1, true)
            SetModelAsNoLongerNeeded(hash)
        end
    end

    SendUI('zedlib:startProgress', {
        label = label,
        duration = duration,
        canCancel = canCancel,
    })

    local startTime = GetGameTimer()

    while progressActive do
        if canCancel and (IsControlJustPressed(0, 177) or IsDisabledControlJustPressed(0, 177)) then
            progressCancelled = true
            progressActive = false
            break
        end

        if disable.move then
            DisableControlAction(0, 30, true)
            DisableControlAction(0, 31, true)
            DisableControlAction(0, 32, true)
            DisableControlAction(0, 33, true)
            DisableControlAction(0, 34, true)
            DisableControlAction(0, 35, true)
        end

        if disable.car then
            DisableControlAction(0, 63, true)
            DisableControlAction(0, 64, true)
            DisableControlAction(0, 71, true)
            DisableControlAction(0, 72, true)
            DisableControlAction(0, 75, true)
        end

        if disable.combat then
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisablePlayerFiring(ped, true)
        end

        if disable.mouse then
            DisableControlAction(0, 1, true)
            DisableControlAction(0, 2, true)
        end

        if GetGameTimer() - startTime >= duration then
            progressActive = false
            break
        end

        Wait(0)
    end

    SendUI('zedlib:stopProgress', {})

    if anim and anim.dict and anim.clip then
        StopAnimTask(ped, anim.dict, anim.clip, 1.0)
        RemoveAnimDict(anim.dict)
    end

    if propEntity and DoesEntityExist(propEntity) then
        DeleteObject(propEntity)
    end

    local completed = not progressCancelled
    progressCancelled = false
    return completed
end

--- Cancel the active progress bar.
function UI.CancelProgressBar()
    if progressActive then
        progressCancelled = true
        progressActive = false
    end
end

--- Check if a progress bar is currently active.
---@return boolean
function UI.IsProgressActive()
    return progressActive
end
