--- Menu API: CreateMenu, AddButton, AddCheckbox, AddList, AddSlider, etc. and menu state.

local generateId = ZedInternal.generateId
local fireCallback = ZedInternal.fireCallback
local counters = ZedInternal.menuItemCounters
local assert = ZedInternal.assert
local log = ZedInternal.log

local isMenuOpen = false

local function buildInfoData(raw)
    if not raw then return nil end
    if type(raw) == 'function' then return raw end
    local out = {}
    for i, row in ipairs(raw) do
        if type(row) == 'table' and row.label ~= nil and row.value ~= nil then
            out[#out + 1] = { label = tostring(row.label), value = tostring(row.value) }
        end
    end
    return #out > 0 and out or nil
end

local function resolveInfoData(raw)
    if type(raw) == 'function' then
        local ok, res = pcall(raw)
        return ok and buildInfoData(res) or nil
    end
    return buildInfoData(raw)
end

local function resolveValue(val)
    if type(val) == 'function' then
        local ok, res = pcall(val)
        return ok and res or nil
    end
    return val
end

---@param id string
---@param title string
---@param subtitle? string
---@param opts? table
function UI.CreateMenu(id, title, subtitle, opts)
    opts = opts or {}
    assert("MENU", type(id) == 'string' and id ~= '' and not id:match('%s'), "CreateMenu() — id must be a non-empty string with no spaces. (received: " .. type(id) .. ")", 2)
    assert("MENU", type(title) == 'string' and title ~= '', "CreateMenu() — title must be a non-empty string.", 2)
    assert("MENU", ZedState.menus[id] == nil, "CreateMenu() — menu '" .. tostring(id) .. "' already exists.", 2)
    if opts.color ~= nil then
        assert("MENU", ZedInternal.validateHex(opts.color), "CreateMenu() — opts.color must be a valid hex string (#RRGGBB or #RGB). (received: " .. type(opts.color) .. ")", 2)
    end
    if opts.banner ~= nil then
        assert("MENU", type(opts.banner) == 'string' and opts.banner ~= '', "CreateMenu() — opts.banner must be a non-empty string.", 2)
    end
    counters[id] = 0
    ZedState.menus[id] = {
        id = id,
        title = title,
        subtitle = subtitle or nil,
        color = opts.color or nil,
        banner = opts.banner or nil,
        items = {},
        categories = {},
    }
    if not ZedState.menuItemsById[id] then
        ZedState.menuItemsById[id] = {}
    end
    SendUI('zedlib:registerMenu', {
        id = id,
        title = title,
        subtitle = subtitle or nil,
        color = opts.color or nil,
        banner = opts.banner or nil,
        items = {},
    })
    if ZedConfig.debug then
        log("DEBUG", "MENU", "CreateMenu() — Menu '" .. id .. "' created.", { id = id, items = 0, color = opts.color })
    end
end

---@param menuId string
---@param opts table
---@return string
function UI.AddButton(menuId, opts)
    assert("MENU", ZedState.menus[menuId] ~= nil, "AddButton() — Menu '" .. tostring(menuId) .. "' does not exist. Create it first with CreateMenu().", 2)
    assert("MENU", type(opts) == 'table', "AddButton() — opts must be a table.", 2)
    local labelRaw = opts.label
    if labelRaw ~= nil and type(labelRaw) ~= 'string' and type(labelRaw) ~= 'function' then
        assert("MENU", false, "AddButton() — opts.label must be a string or function when provided.", 2)
    end
    if opts.onSelect ~= nil then
        assert("MENU", type(opts.onSelect) == 'function' or type(opts.onSelect) == 'string', "AddButton() — opts.onSelect must be a function or callback id (string) when provided.", 2)
    end
    if opts.icon ~= nil and opts.icon ~= '' then
        assert("MENU", type(opts.icon) == 'string', "AddButton() — opts.icon must be a non-empty string when provided.", 2)
    end
    if opts.category ~= nil and opts.category ~= '' then
        local menu = ZedState.menus[menuId]
        if menu and not menu.categories[opts.category] then
            log("WARN", "MENU", "AddButton() — Category '" .. tostring(opts.category) .. "' does not exist yet in '" .. menuId .. "'.", nil)
        end
    end
    if opts.infoData ~= nil and type(opts.infoData) ~= 'function' then
        assert("MENU", type(opts.infoData) == 'table', "AddButton() — opts.infoData must be a table of { label, value } or a function.", 2)
        for i, row in ipairs(opts.infoData) do
            assert("MENU", type(row) == 'table' and (row.label ~= nil and row.value ~= nil), "AddButton() — opts.infoData[" .. i .. "] must have label and value.", 2)
        end
    end
    local itemId = opts.id or generateId(menuId, 'btn')
    local callbackAction = 'menu:' .. menuId .. ':' .. itemId
    local labelResolved = (labelRaw == nil) and '' or (type(labelRaw) == 'string' and labelRaw or (resolveValue(labelRaw) or ''))
    local itemPayload = {
        id = itemId,
        type = 'button',
        label = type(labelResolved) == 'string' and labelResolved or tostring(labelResolved),
        description = opts.description or nil,
        icon = opts.icon or nil,
        disabled = opts.disabled or false,
        onSelect = callbackAction,
        metadata = opts.metadata or nil,
        category = opts.category or nil,
        rightLabel = resolveValue(opts.rightLabel),
        rightLabelColor = resolveValue(opts.rightLabelColor),
        infoData = resolveInfoData(opts.infoData),
    }
    if itemPayload.rightLabel ~= nil then itemPayload.rightLabel = tostring(itemPayload.rightLabel) end
    if itemPayload.rightLabelColor ~= nil then itemPayload.rightLabelColor = tostring(itemPayload.rightLabelColor) end

    ZedState.menus[menuId].items[#ZedState.menus[menuId].items + 1] = {
        id = itemId,
        type = 'button',
        opts = opts,
    }
    ZedState.menuItemsById[menuId][itemId] = ZedState.menus[menuId].items[#ZedState.menus[menuId].items]

    SendUI('zedlib:addMenuItem', {
        menuId = menuId,
        item = itemPayload,
    })

    if opts.onSelect then
        RegisterMenuCallback(callbackAction, function(data)
            fireCallback(opts.onSelect, data)
        end)
    end

    return itemId
end

---@param menuId string
---@param opts table
---@return string
function UI.AddCheckbox(menuId, opts)
    assert("MENU", ZedState.menus[menuId] ~= nil, "AddCheckbox() — Menu '" .. tostring(menuId) .. "' does not exist.", 2)
    assert("MENU", type(opts) == 'table', "AddCheckbox() — opts must be a table.", 2)
    if opts.label ~= nil and type(opts.label) ~= 'string' and type(opts.label) ~= 'function' then
        assert("MENU", false, "AddCheckbox() — opts.label must be a string or function when provided.", 2)
    end
    if opts.onChange ~= nil then
        assert("MENU", type(opts.onChange) == 'function' or type(opts.onChange) == 'string', "AddCheckbox() — opts.onChange must be a function or callback id (string) when provided.", 2)
    end
    if opts.category ~= nil and opts.category ~= '' then
        local menu = ZedState.menus[menuId]
        if menu and not menu.categories[opts.category] then
            log("WARN", "MENU", "AddCheckbox() — Category '" .. tostring(opts.category) .. "' does not exist yet in '" .. menuId .. "'.", nil)
        end
    end
    if opts.infoData ~= nil and type(opts.infoData) ~= 'function' then
        assert("MENU", type(opts.infoData) == 'table', "AddCheckbox() — opts.infoData must be a table of { label, value } or a function.", 2)
    end
    local itemId = opts.id or generateId(menuId, 'chk')
    local callbackAction = 'menu:' .. menuId .. ':' .. itemId
    local labelResolved = (opts.label == nil) and '' or (type(opts.label) == 'string' and opts.label or (resolveValue(opts.label) or ''))
    local checkedResolved = type(opts.checked) == 'function' and resolveValue(opts.checked) or opts.checked
    if checkedResolved ~= true then checkedResolved = false end

    ZedState.menus[menuId].items[#ZedState.menus[menuId].items + 1] = {
        id = itemId,
        type = 'checkbox',
        opts = opts,
    }
    ZedState.menuItemsById[menuId][itemId] = ZedState.menus[menuId].items[#ZedState.menus[menuId].items]

    SendUI('zedlib:addMenuItem', {
        menuId = menuId,
        item = {
            id = itemId,
            type = 'checkbox',
            label = type(labelResolved) == 'string' and labelResolved or tostring(labelResolved),
            description = opts.description or nil,
            icon = opts.icon or nil,
            disabled = opts.disabled or false,
            checked = checkedResolved,
            onChange = callbackAction,
            category = opts.category or nil,
            infoData = resolveInfoData(opts.infoData),
        }
    })

    if opts.onChange then
        RegisterMenuCallback(callbackAction, function(data)
            fireCallback(opts.onChange, data.checked)
        end)
    end

    return itemId
end

---@param menuId string
---@param subMenuId string
---@param label string
---@param opts? table
---@return string
function UI.AddSubMenu(menuId, subMenuId, label, opts)
    assert("MENU", ZedState.menus[menuId] ~= nil, "AddSubMenu() — Menu '" .. tostring(menuId) .. "' does not exist.", 2)
    opts = opts or {}
    local itemId = opts.id or generateId(menuId, 'sub')
    counters[subMenuId] = 0
    ZedState.menus[subMenuId] = {
        id = subMenuId,
        title = opts.subtitle or label,
        subtitle = nil,
        color = opts.color or nil,
        banner = opts.banner or nil,
        items = {},
        categories = {},
    }
    if not ZedState.menuItemsById[subMenuId] then
        ZedState.menuItemsById[subMenuId] = {}
    end

    SendUI('zedlib:registerMenu', {
        id = subMenuId,
        title = opts.subtitle or label,
        subtitle = nil,
        color = opts.color or nil,
        banner = opts.banner or nil,
        items = {}
    })

    ZedState.menus[menuId].items[#ZedState.menus[menuId].items + 1] = {
        id = itemId,
        type = 'submenu',
        targetMenu = subMenuId,
        label = label,
        opts = opts,
    }

    SendUI('zedlib:addMenuItem', {
        menuId = menuId,
        item = {
            id = itemId,
            type = 'submenu',
            label = label,
            description = opts.description or nil,
            icon = opts.icon or nil,
            disabled = opts.disabled or false,
            targetMenu = subMenuId,
            category = opts.category or nil,
            infoData = resolveInfoData(opts.infoData),
        }
    })

    return subMenuId
end

---@param menuId string
---@param opts table
---@return string
function UI.AddCategory(menuId, opts)
    assert("MENU", ZedState.menus[menuId] ~= nil, "AddCategory() — Menu '" .. tostring(menuId) .. "' does not exist.", 2)
    assert("MENU", type(opts) == 'table' and type(opts.id) == 'string' and opts.id ~= '', "AddCategory() — opts.id (category id) is required.", 2)
    assert("MENU", opts.label ~= nil and type(opts.label) == 'string' and opts.label ~= '', "AddCategory() — opts.label is required.", 2)
    local itemId = opts.id or generateId(menuId, 'cat')
    ZedState.menus[menuId].categories[opts.id] = true
    ZedState.menus[menuId].items[#ZedState.menus[menuId].items + 1] = {
        id = itemId,
        type = 'category',
        opts = opts,
    }
    ZedState.menuItemsById[menuId][itemId] = ZedState.menus[menuId].items[#ZedState.menus[menuId].items]

    SendUI('zedlib:addMenuItem', {
        menuId = menuId,
        item = {
            id = itemId,
            type = 'category',
            label = opts.label,
            description = opts.description or nil,
            icon = opts.icon or nil,
            disabled = opts.disabled or false,
            infoData = buildInfoData(opts.infoData),
        }
    })
    return itemId
end

---@param menuId string
---@param opts? table
---@return string
function UI.AddSeparator(menuId, opts)
    assert("MENU", ZedState.menus[menuId] ~= nil, "AddSeparator() — Menu '" .. tostring(menuId) .. "' does not exist.", 2)
    opts = opts or {}
    local itemId = generateId(menuId, 'sep')
    ZedState.menus[menuId].items[#ZedState.menus[menuId].items + 1] = {
        id = itemId,
        type = 'separator',
        opts = opts,
    }
    ZedState.menuItemsById[menuId][itemId] = ZedState.menus[menuId].items[#ZedState.menus[menuId].items]

    SendUI('zedlib:addMenuItem', {
        menuId = menuId,
        item = {
            id = itemId,
            type = 'separator',
            description = opts.description or nil,
            category = opts.category or nil,
        }
    })
    return itemId
end

---@param menuId string
---@param opts table
---@return string
function UI.AddList(menuId, opts)
    assert("MENU", ZedState.menus[menuId] ~= nil, "AddList() — Menu '" .. tostring(menuId) .. "' does not exist.", 2)
    assert("MENU", type(opts) == 'table', "AddList() — opts must be a table.", 2)
    if opts.label ~= nil and type(opts.label) ~= 'string' and type(opts.label) ~= 'function' then
        assert("MENU", false, "AddList() — opts.label must be a string or function when provided.", 2)
    end
    assert("MENU", type(opts.items) == 'table' and #opts.items > 0, "AddList() — opts.items must be a non-empty table.", 2)
    local idx = opts.currentIndex or 1
    assert("MENU", idx >= 1 and idx <= #opts.items, "AddList() — opts.currentIndex must be between 1 and #opts.items.", 2)
    if opts.onChange ~= nil then
        assert("MENU", type(opts.onChange) == 'function' or type(opts.onChange) == 'string', "AddList() — opts.onChange must be a function or callback id (string) when provided.", 2)
    end
    if opts.category ~= nil and opts.category ~= '' then
        local menu = ZedState.menus[menuId]
        if menu and not menu.categories[opts.category] then
            log("WARN", "MENU", "AddList() — Category '" .. tostring(opts.category) .. "' does not exist yet in '" .. menuId .. "'.", nil)
        end
    end
    local itemId = opts.id or generateId(menuId, 'list')
    local callbackAction = 'menu:' .. menuId .. ':' .. itemId
    local listItems = {}
    for i, item in ipairs(opts.items) do
        if type(item) == 'string' then
            listItems[i] = { label = item, value = item }
        else
            listItems[i] = item
        end
    end

    ZedState.menus[menuId].items[#ZedState.menus[menuId].items + 1] = {
        id = itemId,
        type = 'list',
        opts = opts,
    }
    ZedState.menuItemsById[menuId][itemId] = ZedState.menus[menuId].items[#ZedState.menus[menuId].items]

    SendUI('zedlib:addMenuItem', {
        menuId = menuId,
        item = {
            id = itemId,
            type = 'list',
            label = (opts.label == nil) and '' or (type(opts.label) == 'string' and opts.label or (resolveValue(opts.label) or '')),
            description = opts.description or nil,
            icon = opts.icon or nil,
            disabled = opts.disabled or false,
            items = listItems,
            currentIndex = (idx - 1),
            onChange = callbackAction,
            category = opts.category or nil,
            infoData = resolveInfoData(opts.infoData),
        }
    })

    if opts.onChange then
        RegisterMenuCallback(callbackAction, function(data)
            fireCallback(opts.onChange, data.index + 1, data.value)
        end)
    end

    return itemId
end

---@param menuId string
---@param opts table
---@return string
function UI.AddSlider(menuId, opts)
    assert("MENU", ZedState.menus[menuId] ~= nil, "AddSlider() — Menu '" .. tostring(menuId) .. "' does not exist.", 2)
    assert("MENU", type(opts) == 'table', "AddSlider() — opts must be a table.", 2)
    if opts.label ~= nil and type(opts.label) ~= 'string' and type(opts.label) ~= 'function' then
        assert("MENU", false, "AddSlider() — opts.label must be a string or function when provided.", 2)
    end
    local min = opts.min or 0
    local max = opts.max or 100
    local step = opts.step or 1
    local value = opts.value or min
    assert("SLIDER", min < max, "AddSlider() — opts.min must be less than opts.max.", 2)
    assert("SLIDER", step > 0, "AddSlider() — opts.step must be greater than 0.", 2)
    assert("SLIDER", value >= min and value <= max, "AddSlider() — opts.value must be between opts.min and opts.max.", 2)
    if opts.onChange ~= nil then
        assert("MENU", type(opts.onChange) == 'function' or type(opts.onChange) == 'string', "AddSlider() — opts.onChange must be a function or callback id (string) when provided.", 2)
    end
    if opts.category ~= nil and opts.category ~= '' then
        local menu = ZedState.menus[menuId]
        if menu and not menu.categories[opts.category] then
            log("WARN", "MENU", "AddSlider() — Category '" .. tostring(opts.category) .. "' does not exist yet in '" .. menuId .. "'.", nil)
        end
    end
    local itemId = opts.id or generateId(menuId, 'slider')
    local callbackAction = 'menu:' .. menuId .. ':' .. itemId

    ZedState.menus[menuId].items[#ZedState.menus[menuId].items + 1] = {
        id = itemId,
        type = 'slider',
        opts = opts,
    }
    ZedState.menuItemsById[menuId][itemId] = ZedState.menus[menuId].items[#ZedState.menus[menuId].items]

    SendUI('zedlib:addMenuItem', {
        menuId = menuId,
        item = {
            id = itemId,
            type = 'slider',
            label = (opts.label == nil) and '' or (type(opts.label) == 'string' and opts.label or (resolveValue(opts.label) or '')),
            description = opts.description or nil,
            icon = opts.icon or nil,
            disabled = opts.disabled or false,
            min = min,
            max = max,
            step = step,
            value = value,
            onChange = callbackAction,
            category = opts.category or nil,
            infoData = resolveInfoData(opts.infoData),
        }
    })

    if opts.onChange then
        RegisterMenuCallback(callbackAction, function(data)
            fireCallback(opts.onChange, data.value)
        end)
    end

    return itemId
end

---@param menuId string
---@param opts? table
---@return string
function UI.AddSearchButton(menuId, opts)
    assert("MENU", ZedState.menus[menuId] ~= nil, "AddSearchButton() — Menu '" .. tostring(menuId) .. "' does not exist.", 2)
    opts = opts or {}
    local itemId = opts.id or generateId(menuId, 'search')
    ZedState.menus[menuId].items[#ZedState.menus[menuId].items + 1] = {
        id = itemId,
        type = 'search',
        opts = opts,
    }
    ZedState.menuItemsById[menuId][itemId] = ZedState.menus[menuId].items[#ZedState.menus[menuId].items]

    SendUI('zedlib:addMenuItem', {
        menuId = menuId,
        item = {
            id = itemId,
            type = 'search',
            label = opts.label or 'Rechercher',
            description = opts.description or nil,
            icon = opts.icon or 'magnifying-glass',
            placeholder = opts.placeholder or 'Tapez pour rechercher...',
            category = opts.category or nil,
            infoData = resolveInfoData(opts.infoData),
        }
    })
    return itemId
end

---@param menuId string
---@param opts table
---@return string
function UI.AddInfoButton(menuId, opts)
    assert("MENU", ZedState.menus[menuId] ~= nil, "AddInfoButton() — Menu '" .. tostring(menuId) .. "' does not exist.", 2)
    assert("MENU", type(opts) == 'table' and type(opts.data) == 'table', "AddInfoButton() — opts.data (array of {label, value}) is required.", 2)
    local itemId = opts.id or generateId(menuId, 'info')
    local infoData = {}
    for i, row in ipairs(opts.data) do
        if type(row) == 'table' and row.label ~= nil and row.value ~= nil then
            infoData[#infoData + 1] = { label = tostring(row.label), value = tostring(row.value) }
        end
    end
    ZedState.menus[menuId].items[#ZedState.menus[menuId].items + 1] = {
        id = itemId,
        type = 'info',
        opts = opts,
    }
    ZedState.menuItemsById[menuId][itemId] = ZedState.menus[menuId].items[#ZedState.menus[menuId].items]

    SendUI('zedlib:addMenuItem', {
        menuId = menuId,
        item = {
            id = itemId,
            type = 'info',
            label = opts.label or '',
            description = opts.description or nil,
            icon = opts.icon or nil,
            disabled = opts.disabled or false,
            infoData = infoData,
            category = opts.category or nil,
        }
    })
    return itemId
end

---@return boolean
function UI.IsMenuOpen()
    return isMenuOpen
end

---@param state boolean
function UI.SetMenuOpenFlag(state)
    isMenuOpen = state
    ZedInternal.menuOpen = state
end

---@param id string
function UI.OpenMenu(id)
    assert("MENU", ZedState.menus[id] ~= nil, "OpenMenu() — Menu '" .. tostring(id) .. "' does not exist.", 2)
    local itemCount = #(ZedState.menus[id].items or {})
    if itemCount == 0 and ZedConfig.debug then
        log("WARN", "MENU", "OpenMenu() — Menu '" .. id .. "' has no items.", nil)
    end
    SendUI('zedlib:openMenu', { id = id })
    isMenuOpen = true
    ZedInternal.menuOpen = true
end

function UI.CloseMenu()
    SendUI('zedlib:closeMenu', {})
    isMenuOpen = false
    ZedInternal.menuOpen = false
end

---@param id string
function UI.RemoveMenu(id)
    SendUI('zedlib:removeMenu', { id = id })
    counters[id] = nil
    ZedState.menus[id] = nil
    ZedState.menuItemsById[id] = nil
    if ZedState.watcherCache then ZedState.watcherCache[id] = nil end
end

---@param menuId string
---@param itemId string
---@param patch table
function UI.RefreshItem(menuId, itemId, patch)
    ZedInternal.assert("MENU", ZedState.menus[menuId] ~= nil, "RefreshItem() — Menu '" .. tostring(menuId) .. "' does not exist.", 2)
    ZedInternal.assert("MENU", type(patch) == 'table' and next(patch) ~= nil, "RefreshItem() — patch must be a non-empty table.", 2)
    ZedInternal.SendNUI('zedlib:updateItem', { menuId = menuId, itemId = itemId, patch = patch })
end

---@param menuId string
function UI.RefreshMenu(menuId)
    ZedInternal.assert("MENU", ZedState.menus[menuId] ~= nil, "RefreshMenu() — Menu '" .. tostring(menuId) .. "' does not exist.", 2)
    local menu = ZedState.menus[menuId]
    local items = {}
    local resolveVal = function(v)
        if type(v) == 'function' then local ok, r = pcall(v); return ok and r or nil end
        return v
    end
    local function resolveInfo(r)
        if type(r) == 'function' then local ok, res = pcall(r); r = ok and res or nil end
        if not r or type(r) ~= 'table' then return nil end
        local out = {}
        for i, row in ipairs(r) do
            if type(row) == 'table' and row.label ~= nil and row.value ~= nil then
                out[#out + 1] = { label = tostring(row.label), value = tostring(row.value) }
            end
        end
        return #out > 0 and out or nil
    end
    for _, entry in ipairs(menu.items or {}) do
        local opts = entry.opts
        local labelSrc = entry.type == 'submenu' and entry.label or (opts and opts.label)
        local item = {
            id = entry.id,
            type = entry.type,
            label = (labelSrc == nil) and '' or (type(labelSrc) == 'string' and labelSrc or tostring(resolveVal(labelSrc) or '')),
            description = opts and opts.description or nil,
            icon = opts and opts.icon or nil,
            disabled = opts and opts.disabled or false,
            category = opts and opts.category or nil,
        }
        if entry.type == 'button' then
            item.onSelect = 'menu:' .. menuId .. ':' .. entry.id
            item.metadata = opts and opts.metadata or nil
            item.rightLabel = opts and resolveVal(opts.rightLabel)
            item.rightLabelColor = opts and resolveVal(opts.rightLabelColor)
            item.infoData = opts and resolveInfo(opts.infoData) or nil
        elseif entry.type == 'checkbox' then
            item.checked = opts and (type(opts.checked) == 'function' and resolveVal(opts.checked) or opts.checked) or false
            item.onChange = 'menu:' .. menuId .. ':' .. entry.id
            item.infoData = opts and resolveInfo(opts.infoData) or nil
        elseif entry.type == 'submenu' then
            item.targetMenu = entry.targetMenu
            item.infoData = opts and resolveInfo(opts.infoData) or nil
        elseif entry.type == 'list' then
            local rawItems = opts and opts.items or {}
            local listItems = {}
            for i, it in ipairs(rawItems) do
                if type(it) == 'string' then
                    listItems[i] = { label = it, value = it }
                else
                    listItems[i] = it
                end
            end
            item.items = listItems
            item.currentIndex = (opts and opts.currentIndex or 1) - 1
            item.onChange = 'menu:' .. menuId .. ':' .. entry.id
            item.infoData = opts and resolveInfo(opts.infoData) or nil
        elseif entry.type == 'slider' then
            item.min = opts and opts.min or 0
            item.max = opts and opts.max or 100
            item.step = opts and opts.step or 1
            item.value = opts and opts.value or 0
            item.onChange = 'menu:' .. menuId .. ':' .. entry.id
            item.infoData = opts and resolveInfo(opts.infoData) or nil
        elseif entry.type == 'search' then
            item.placeholder = opts and opts.placeholder or nil
        elseif entry.type == 'info' then
            item.infoData = opts and opts.data and buildInfoData(opts.data) or nil
        end
        items[#items + 1] = item
    end
    ZedInternal.SendNUI('zedlib:refreshMenu', { menuId = menuId, items = items })
end
