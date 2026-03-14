local menuCallbacks = {}
local dialogCallbacks = {}

RegisterNUICallback('zedlib:menuAction', function(data, cb)
    local action = data.action
    if action and menuCallbacks[action] then
        local ok, err = pcall(menuCallbacks[action], data)
        if not ok and ZedInternal and ZedInternal.log then
            ZedInternal.log("ERROR", "MENU", "Menu callback error: " .. tostring(err), nil)
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

    if ok == false and ZedInternal and ZedInternal.log then
        ZedInternal.log("ERROR", "DIALOG", "Dialog callback error: " .. tostring(err), nil)
    end

    SetNuiFocus(false, false)
    cb('ok')
end)

--- Register a menu callback
---@param action string The action to register
---@param callback function The callback function
function RegisterMenuCallback(action, callback)
    menuCallbacks[action] = callback
end

--- Register a dialog callback
---@param dialogId string The dialog identifier
---@param action string The action to register
---@param callback function The callback function
function RegisterDialogCallback(dialogId, action, callback)
    if callback then
        dialogCallbacks[dialogId .. ':' .. action] = callback
    else
        dialogCallbacks[dialogId] = action
    end
end

exports('SendUI', SendUI)

--- Convert a rotation to a direction
---@param rot vector3 The rotation
---@return vector3 direction The direction
local function rotationToDirection(rot)
    local x = rot.x * math.pi / 180.0
    local z = rot.z * math.pi / 180.0
    local num = math.abs(math.cos(x))
    return vector3(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
end

--- Convert a world position to a screen position
---@param pos vector3 The world position
---@return vector2 point2D The screen position
local function world3DToScreen2D(pos)
    local _, sX, sY = GetScreenCoordFromWorldCoord(pos.x, pos.y, pos.z)
    return vector2(sX, sY)
end

--- Convert a screen position to a world position
---@param camPos vector3 The camera position
---@param camRot vector3 The camera rotation
---@param cursor vector2 The mouse position
---@return vector3 point3Dret The world position
---@return vector3 forwardDir The forward direction
local function screenRelToWorld(camPos, camRot, cursor)
    local camForward = rotationToDirection(camRot)
    local rotUp = vector3(camRot.x + 1.0, camRot.y, camRot.z)
    local rotDown = vector3(camRot.x - 1.0, camRot.y, camRot.z)
    local rotLeft = vector3(camRot.x, camRot.y, camRot.z - 1.0)
    local rotRight = vector3(camRot.x, camRot.y, camRot.z + 1.0)
    local camRight = rotationToDirection(rotRight) - rotationToDirection(rotLeft)
    local camUp = rotationToDirection(rotUp) - rotationToDirection(rotDown)
    local rollRad = -(camRot.y * math.pi / 180.0)
    local camRightRoll = camRight * math.cos(rollRad) - camUp * math.sin(rollRad)
    local camUpRoll = camRight * math.sin(rollRad) + camUp * math.cos(rollRad)
    local point3DZero = camPos + camForward * 1.0
    local point3D = point3DZero + camRightRoll + camUpRoll
    local point2D = world3DToScreen2D(point3D)
    local point2DZero = world3DToScreen2D(point3DZero)
    local scaleX = (cursor.x - point2DZero.x) / (point2D.x - point2DZero.x)
    local scaleY = (cursor.y - point2DZero.y) / (point2D.y - point2DZero.y)
    local point3Dret = point3DZero + camRightRoll * scaleX + camUpRoll * scaleY
    local forwardDir = camForward + camRightRoll * scaleX + camUpRoll * scaleY
    return point3Dret, forwardDir
end

--- Convert a screen position to a world position
---@param distance number The distance to cast the ray
---@param flags number The flags to use for the raycast
---@return boolean hit Whether the raycast hit an entity
---@return number entity The entity that was hit
---@return vector3 endCoords The end coordinates of the raycast
---@return vector2 mouse The mouse position
local function screenToWorld(distance, flags)
    local camRot = GetGameplayCamRot(0)
    local camPos = GetGameplayCamCoord()
    local mouse = vector2(GetControlNormal(2, 239), GetControlNormal(2, 240))
    local cam3DPos, forwardDir = screenRelToWorld(camPos, camRot, mouse)
    local direction = camPos + forwardDir * distance
    local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(cam3DPos, direction, flags, 0, 0)
    local _, hit, endCoords, _, entityHit = GetShapeTestResult(rayHandle)
    return hit == 1, entityHit, endCoords, mouse
end

local isContextTargeting = false
local highlightedEntity = nil

local function clearHighlight()
    if highlightedEntity and DoesEntityExist(highlightedEntity) then
        ResetEntityAlpha(highlightedEntity)
        highlightedEntity = nil
    end
end

CreateThread(function()
    while true do
        local contextReady = ZedInternal and ZedInternal.contextIsEnabled and ZedInternal.contextIsEnabled()

        if contextReady and not (UI and UI.IsMenuOpen()) then
            DisableControlAction(0, 19, true)
            -- Use Pressed so we still detect ALT after a 150ms wait (JustPressed would be missed)
            if IsDisabledControlPressed(0, 19) then
                isContextTargeting = true

                while IsDisabledControlPressed(0, 19) do
                    DisableControlAction(0, 19, true)
                    DisableAllControlActions(2)
                    EnableControlAction(0, 239, true)
                    EnableControlAction(0, 240, true)
                    EnableControlAction(0, 24, true)
                    EnableControlAction(0, 25, true)
                    EnableControlAction(0, 30, true)  -- Move LR
                    EnableControlAction(0, 31, true)  -- Move UD
                    EnableControlAction(0, 32, true)  -- Move Up
                    EnableControlAction(0, 33, true)  -- Move Down
                    EnableControlAction(0, 34, true)  -- Move Left
                    EnableControlAction(0, 35, true)  -- Move Right
                    EnableControlAction(0, 21, true)  -- Sprint
                    EnableControlAction(0, 22, true)  -- Jump
                    EnableControlAction(0, 23, true)  -- Enter vehicle
                    EnableControlAction(0, 36, true)  -- Sneak
                    EnableControlAction(0, 44, true)  -- Cover
                    EnableControlAction(0, 71, true)  -- Vehicle accelerate
                    EnableControlAction(0, 72, true)  -- Vehicle brake
                    EnableControlAction(0, 59, true)  -- Vehicle steer LR
                    EnableControlAction(0, 60, true)  -- Vehicle steer UD
                    EnableControlAction(0, 76, true)  -- Vehicle handbrake
                    EnableControlAction(0, 75, true)  -- Vehicle exit
                    EnableControlAction(0, 63, true)  -- Vehicle steer left
                    EnableControlAction(0, 64, true)  -- Vehicle steer right
                    DisablePlayerFiring(PlayerPedId(), true)

                    if not ZedInternal.contextIsOpen() then
                        SetNuiFocus(false, false)
                        SetNuiFocusKeepInput(false)
                        SetMouseCursorActiveThisFrame()
                        SetMouseCursorSprite(1)

                        local hit, entity, coords, mouse = screenToWorld(35.0, 31)

                        if hit and entity and entity ~= 0 and DoesEntityExist(entity) then
                            local entType = ZedInternal.contextGetEntityType(entity)
                            if entType then
                                SetMouseCursorSprite(5)

                                if highlightedEntity ~= entity then
                                    clearHighlight()
                                    highlightedEntity = entity
                                    SetEntityAlpha(entity, 200, false)
                                end

                                if IsControlJustPressed(0, 24) or IsDisabledControlJustPressed(0, 24) then
                                    local resX, resY = GetActiveScreenResolution()
                                    local screenPx = math.floor(mouse.x * resX)
                                    local screenPy = math.floor(mouse.y * resY)
                                    ZedInternal.contextOpenForEntity(entity, entType, coords, screenPx, screenPy)
                                    SetNuiFocus(true, true)
                                    SetNuiFocusKeepInput(true)
                                end
                            else
                                clearHighlight()
                            end
                        else
                            clearHighlight()
                        end
                    end

                    Wait(0)
                end

                clearHighlight()
                if ZedInternal.contextIsOpen() then
                    ZedInternal.contextClose()
                end
                SetNuiFocusKeepInput(false)
                SetNuiFocus(false, false)
                isContextTargeting = false
            end
        end

        Wait(contextReady and 100 or 500)
    end
end)

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
-- 14 = Scroll down (weapon wheel next), 15 = Scroll up (weapon wheel prev)

local disabledControls <const> = {
    24, 25,     -- Attack / Aim
    47,         -- Weapon
    58,         -- Weapon throw
    14, 15,     -- Mouse wheel (weapon wheel next/prev) - used for menu navigation
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

                if isJustPressed(15) then
                    SendUI('zedlib:menuMoveUp')
                elseif isJustPressed(14) then
                    SendUI('zedlib:menuMoveDown')
                end
            end

            Wait(0)
        else
            holdState = {}
            Wait(200)
        end
    end
end)
