local menuCallbacks = {}
local dialogCallbacks = {}

RegisterNUICallback('zedlib:menuAction', function(data, cb)
    local action = data.action
    if action and menuCallbacks[action] then
        local ok, err = pcall(menuCallbacks[action], data)
        if not ok then
            print('[ZedLib] ^1Menu callback error:^0 ' .. tostring(err))
        end
    end
    cb('ok')
end)

local isSearchActive = false

RegisterNUICallback('zedlib:menuClosed', function(_, cb)
    if UI and UI.SetMenuOpenFlag then
        UI.SetMenuOpenFlag(false)
    end
    if isSearchActive then
        isSearchActive = false
        SetNuiFocus(false, false)
    end
    cb('ok')
end)

RegisterNUICallback('zedlib:searchFocus', function(data, cb)
    isSearchActive = data.active
    SetNuiFocus(data.active, false)
    cb('ok')
end)

RegisterNUICallback('zedlib:dialogResult', function(data, cb)
    local dialogId = data.dialogId
    local action = data.action
    local callbackKey = dialogId .. ':' .. action

    local ok, err
    if dialogCallbacks[callbackKey] then
        ok, err = pcall(dialogCallbacks[callbackKey], data.values or {})
    elseif dialogCallbacks[dialogId] then
        ok, err = pcall(dialogCallbacks[dialogId], action, data.values or {})
    end

    if ok == false then
        print('[ZedLib] ^1Dialog callback error:^0 ' .. tostring(err))
    end

    SetNuiFocus(false, false)
    cb('ok')
end)

function RegisterMenuCallback(action, callback)
    menuCallbacks[action] = callback
end

function RegisterDialogCallback(dialogId, action, callback)
    if callback then
        dialogCallbacks[dialogId .. ':' .. action] = callback
    else
        dialogCallbacks[dialogId] = action
    end
end

function SendUI(action, data)
    SendNUIMessage({
        action = action,
        data = data or {}
    })
end

exports('SendUI', SendUI)

local INITIAL_DELAY = 300
local REPEAT_DELAY = 80

local holdState = {}

--- Check if a control is pressed
---@param control number The control to check
---@return boolean Whether the control is pressed
local function isPressed(control)
    return IsDisabledControlPressed(0, control) or IsControlPressed(0, control)
end

--- Check if a control is just pressed
---@param control number The control to check
---@return boolean Whether the control is just pressed
local function isJustPressed(control)
    return IsDisabledControlJustPressed(0, control) or IsControlJustPressed(0, control)
end

--- Handle the hold of a control
---@param control number The control to handle
---@param action function The action to perform when the control is held
local function handleHold(control, action)
    local now = GetGameTimer()
    if isJustPressed(control) then
        holdState[control] = { start = now, lastFire = now, fired = false }
        action()
        return
    end
    if isPressed(control) and holdState[control] then
        local state = holdState[control]
        local held = now - state.start
        if held > INITIAL_DELAY then
            if now - state.lastFire >= REPEAT_DELAY then
                state.lastFire = now
                action()
            end
        end
    else
        holdState[control] = nil
    end
end

-- Control IDs:
-- 172 = Arrow Up, 173 = Arrow Down
-- 174 = Arrow Left, 175 = Arrow Right
-- 176 = Enter, 177 = Backspace

local disabledControls = {
    24, 25,     -- Attack / Aim
    47,         -- Weapon
    58,         -- Weapon throw
}

CreateThread(function()
    while true do
        if UI and UI.IsMenuOpen() then

            for i = 1, #disabledControls do
                DisableControlAction(0, disabledControls[i], true)
            end

            if not isSearchActive then
                handleHold(172, function() SendUI('zedlib:menuMoveUp') end)
                handleHold(173, function() SendUI('zedlib:menuMoveDown') end)
                handleHold(174, function() SendUI('zedlib:menuLeft') end)
                handleHold(175, function() SendUI('zedlib:menuRight') end)

                if isJustPressed(176) then
                    SendUI('zedlib:menuSelect')
                end

                if isJustPressed(177) then
                    SendUI('zedlib:menuGoBack')
                end
            end

            Wait(0)
        else
            holdState = {}
            Wait(200)
        end
    end
end)
