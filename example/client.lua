--- ZedLib — Exemple d'utilisation complète de la librairie (menus, notifications, dialogs, context, interact, progress).

---@type string
local MENU_ID <const> = "zedlib_demo"
---@type string
local BANNER_URL <const> = "https://imagedelivery.net/a01l0g2PBuSyl01US7o1cQ/86281e19-804f-4b41-6856-0341ea067e00/public"
---@type number
local demoMoney = 500
---@type number
local demoHealth = 200

---@param msg string
---@param typ? "success"|"error"|"warning"|"info"
local function notify(msg, typ)
    zed.Notify({ type = typ or "info", title = "ZedLib Demo", message = msg })
end

---@return nil
local function buildDemoMenu()
    zed.RemoveMenu(MENU_ID)
    zed.CreateMenu(MENU_ID, "ZedLib Demo", "Toutes les fonctionnalités", {
        color = "#e74c3c",
        banner = BANNER_URL,
    })

    zed.AddButton(MENU_ID, {
        label = "Bouton simple",
        description = "Description du bouton",
        rightLabel = "$500",
        rightLabelColor = "#22c55e",
        icon = "circle-check",
        onSelect = function()
            notify("Bouton cliqué")
        end,
    })

    zed.AddButton(MENU_ID, {
        label = "Joueurs en ligne (voir RefreshItem)",
        rightLabel = tostring(#GetActivePlayers()),
        infoData = {
            { label = "Server ID", value = tostring(GetPlayerServerId(PlayerId())) },
            { label = "Vie", value = demoHealth .. " / 200" },
        },
        icon = "users",
        onSelect = function() end,
    })

    zed.AddButton(MENU_ID, {
        label = "Bouton désactivé",
        icon = "ban",
        disabled = true,
        onSelect = function() end,
    })

    zed.AddButton(MENU_ID, {
        id = "zedlib_demo_btn_money",
        label = "Argent",
        rightLabel = "$" .. tostring(demoMoney),
        rightLabelColor = "#22c55e",
        icon = "wallet",
        onSelect = function() end,
    })
    zed.AddButton(MENU_ID, {
        label = "Refresh money",
        icon = "coins",
        onSelect = function()
            demoMoney = demoMoney + 100
            zed.RefreshItem(MENU_ID, "zedlib_demo_btn_money", {
                rightLabel = "$" .. tostring(demoMoney),
            })
            notify("+100 $ — Total : $" .. tostring(demoMoney), "success")
        end,
    })

    zed.AddSeparator(MENU_ID)

    zed.AddCheckbox(MENU_ID, {
        label = "God Mode",
        icon = "shield-halved",
        checked = false,
        onChange = function(checked)
            SetEntityInvincible(PlayerPedId(), checked)
            notify(checked and "God mode activé" or "God mode désactivé", checked and "success" or "warning")
        end,
    })

    zed.AddCheckbox(MENU_ID, {
        label = "Super vitesse",
        icon = "bolt",
        checked = false,
        onChange = function(checked)
            SetRunSprintMultiplierForPlayer(PlayerId(), checked and 2.5 or 1.0)
            notify(checked and "Vitesse x2.5" or "Vitesse normale")
        end,
    })

    zed.AddSeparator(MENU_ID)

    zed.AddList(MENU_ID, {
        label = "Météo",
        icon = "cloud-sun",
        items = {
            { label = "Clair", value = "CLEAR" },
            { label = "Nuageux", value = "CLOUDS" },
            { label = "Pluie", value = "RAIN" },
            { label = "Neige", value = "XMAS" },
        },
        currentIndex = 1,
        onChange = function(_, item)
            SetWeatherTypeNowPersist(item.value)
            notify("Météo : " .. item.label)
        end,
    })

    zed.AddSlider(MENU_ID, {
        label = "Heure",
        icon = "clock",
        min = 0,
        max = 23,
        step = 1,
        value = 12,
        onChange = function(value)
            NetworkOverrideClockTime(math.floor(value), 0, 0)
        end,
    })

    zed.AddSlider(MENU_ID, {
        label = "Santé",
        icon = "heart-pulse",
        min = 0,
        max = 200,
        step = 10,
        value = 200,
        onChange = function(value)
            SetEntityHealth(PlayerPedId(), math.floor(value))
        end,
    })

    zed.AddSeparator(MENU_ID)

    zed.AddSubMenu(MENU_ID, "zedlib_demo_search", "Recherche (SearchButton)", { icon = "magnifying-glass" })
    zed.AddSearchButton("zedlib_demo_search", { placeholder = "Filtrer les items..." })
    zed.AddSeparator("zedlib_demo_search")
    zed.AddButton("zedlib_demo_search", { label = "Item A", icon = "circle", onSelect = function() notify("Item A") end })
    zed.AddButton("zedlib_demo_search", { label = "Item B", icon = "circle", onSelect = function() notify("Item B") end })
    zed.AddButton("zedlib_demo_search", { label = "Item C", icon = "circle", onSelect = function() notify("Item C") end })

    zed.AddSubMenu(MENU_ID, "zedlib_demo_vehicles", "Véhicules", { icon = "car" })

    for _, v in ipairs({ { label = "Adder", model = "adder" }, { label = "Zentorno", model = "zentorno" }, { label = "Buzzard", model = "buzzard" } }) do
        zed.AddButton("zedlib_demo_vehicles", {
            label = v.label,
            icon = "car-side",
            onSelect = function()
                spawnVehicle(v.model)
            end,
        })
    end

    zed.AddButton("zedlib_demo_vehicles", {
        label = "Réparer",
        icon = "wrench",
        onSelect = function()
            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
            if veh ~= 0 then
                SetVehicleFixed(veh)
                notify("Véhicule réparé", "success")
            else
                notify("Pas dans un véhicule", "error")
            end
        end,
    })

    zed.AddSubMenu(MENU_ID, "zedlib_demo_teleport", "Téléportation", { icon = "location-dot" })

    for _, loc in ipairs({
        { label = "Aéroport", x = -1336.0, y = -3044.0, z = 13.9 },
        { label = "Maze Bank", x = -75.0, y = -818.0, z = 326.2 },
        { label = "Plage", x = -1600.0, y = -1008.0, z = 13.0 },
    }) do
        zed.AddButton("zedlib_demo_teleport", {
            label = loc.label,
            icon = "location-crosshairs",
            onSelect = function()
                SetEntityCoords(PlayerPedId(), loc.x, loc.y, loc.z, false, false, false, true)
                notify("Téléporté : " .. loc.label)
            end,
        })
    end

    zed.AddSubMenu(MENU_ID, "zedlib_demo_player", "Joueur", { icon = "user" })

    zed.AddInfoButton("zedlib_demo_player", {
        label = "Infos joueur",
        icon = "id-card",
        data = {
            { label = "ID", value = tostring(GetPlayerServerId(PlayerId())) },
            { label = "Vie", value = tostring(GetEntityHealth(PlayerPedId())) },
        },
    })

    zed.AddCategory("zedlib_demo_player", { id = "actions_player", label = "Actions", icon = "bolt" })
    zed.AddButton("zedlib_demo_player", {
        label = "Full vie + armure",
        icon = "heart",
        category = "actions_player",
        onSelect = function()
            local ped = PlayerPedId()
            SetEntityHealth(ped, GetEntityMaxHealth(ped))
            SetPedArmour(ped, 100)
            notify("Vie et armure au max", "success")
        end,
    })
    zed.AddButton("zedlib_demo_player", {
        label = "Toutes les armes",
        icon = "gun",
        category = "actions_player",
        onSelect = function()
            local ped = PlayerPedId()
            for _, w in ipairs({ "WEAPON_PISTOL", "WEAPON_CARBINERIFLE", "WEAPON_KNIFE" }) do
                GiveWeaponToPed(ped, GetHashKey(w), 999, false, true)
            end
            notify("Armes données", "success")
        end,
    })

    zed.AddSubMenu(MENU_ID, "zedlib_demo_dialogs", "Dialogs", { icon = "comment-dots" })

    zed.AddButton("zedlib_demo_dialogs", {
        label = "Confirm",
        icon = "circle-question",
        onSelect = function()
            zed.CloseMenu()
            zed.Confirm(
                "Confirmer",
                "Êtes-vous sûr ?",
                function() notify("Confirmé", "success") end,
                function() notify("Annulé") end
            )
        end,
    })

    zed.AddButton("zedlib_demo_dialogs", {
        label = "Dialog avec input",
        icon = "pen-to-square",
        onSelect = function()
            zed.CloseMenu()
            zed.Dialog({
                title = "Spawn véhicule",
                message = "Nom du modèle GTA",
                inputs = {
                    { id = "model", label = "Modèle", type = "text", placeholder = "adder", required = true },
                },
                buttons = {
                    { label = "Annuler", variant = "secondary", action = "cancel" },
                    {
                        label = "Spawner",
                        variant = "primary",
                        action = "spawn",
                        onPress = function(values)
                            if values.model and values.model ~= "" then
                                spawnVehicle(values.model)
                            else
                                notify("Modèle vide", "error")
                            end
                        end,
                    },
                },
            })
        end,
    })

    zed.AddButton("zedlib_demo_dialogs", {
        label = "Dialog formulaire",
        icon = "clipboard-list",
        onSelect = function()
            zed.CloseMenu()
            zed.Dialog({
                title = "Formulaire",
                inputs = {
                    { id = "name", label = "Nom", type = "text", required = true },
                    { id = "age", label = "Âge", type = "number", min = 18, max = 99 },
                    { id = "role", type = "select", label = "Rôle", options = { { value = "admin", label = "Admin" }, { value = "user", label = "User" } } },
                    { id = "agree", type = "checkbox", label = "CGU", checkboxLabel = "J'accepte", default = false },
                },
                buttons = {
                    { label = "Annuler", variant = "secondary", action = "cancel" },
                    { label = "Valider", variant = "primary", action = "ok", onPress = function(v) notify("Nom: " .. (v.name or "?") .. ", Âge: " .. (v.age or "?")) end },
                },
            })
        end,
    })

    zed.AddButton("zedlib_demo_dialogs", {
        label = "Dialog danger",
        icon = "triangle-exclamation",
        onSelect = function()
            zed.CloseMenu()
            zed.Dialog({
                title = "Action dangereuse",
                message = "Tapez CONFIRMER pour valider.",
                color = "#dc2626",
                inputs = { { id = "confirm", label = "Confirmation", type = "text", required = true } },
                buttons = {
                    { label = "Annuler", variant = "secondary", action = "cancel" },
                    { label = "Supprimer", variant = "danger", action = "delete", onPress = function() notify("Action exécutée", "error") end },
                },
            })
        end,
    })

    zed.AddSeparator(MENU_ID)

    zed.AddButton(MENU_ID, {
        label = "RefreshItem (un item)",
        icon = "arrows-rotate",
        onSelect = function()
            zed.RefreshItem(MENU_ID, "zedlib_demo_btn_reactive", { label = "Rafraîchi à " .. os.date("%H:%M:%S") })
            notify("Item rafraîchi")
        end,
    })
    zed.AddButton(MENU_ID, {
        label = "RefreshMenu (tout le menu)",
        icon = "rotate",
        onSelect = function()
            zed.RefreshMenu(MENU_ID)
            notify("Menu rafraîchi")
        end,
    })

    zed.AddButton(MENU_ID, {
        id = "zedlib_demo_btn_reactive",
        label = "Label réactif (Watcher)",
        icon = "wand-magic-sparkles",
        onSelect = function() end,
    })
end

---@param model string
---@return nil
function spawnVehicle(model)
    local hash = GetHashKey(model)
    RequestModel(hash)
    local t = GetGameTimer()
    while not HasModelLoaded(hash) and (GetGameTimer() - t) < 5000 do
        Wait(50)
    end
    if not HasModelLoaded(hash) then
        notify("Modèle introuvable : " .. model, "error")
        return
    end
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local veh = CreateVehicle(hash, coords.x, coords.y, coords.z, heading, true, false)
    SetPedIntoVehicle(ped, veh, -1)
    SetModelAsNoLongerNeeded(hash)
    notify(model .. " spawné", "success")
end

zed.AddContextSubMenu({ type = "vehicle", id = "veh_ctx", label = "Véhicule", icon = "car" })
zed.AddContextOption({ type = "vehicle", submenu = "veh_ctx", label = "Réparer", icon = "wrench", onSelect = function(entity) SetVehicleFixed(entity); notify("Véhicule réparé", "success") end })
zed.AddContextOption({ type = "vehicle", submenu = "veh_ctx", label = "Supprimer", icon = "trash", onSelect = function(entity) DeleteEntity(entity); notify("Véhicule supprimé") end })
zed.AddContextOption({ type = "vehicle", label = "Verrouiller", icon = "lock", onSelect = function(entity) SetVehicleDoorsLocked(entity, 2); notify("Verrouillé") end })
zed.AddContextOption({ type = "ped", label = "Saluer", icon = "hand", onSelect = function() notify("Salut !") end })
zed.AddContextOption({ type = "player", label = "Info", icon = "user", onSelect = function(entity) notify("Joueur ID: " .. GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))) end })
zed.AddContextOption({ type = "all", label = "Inspecter", onSelect = function(entity, entityType) notify("Type: " .. entityType .. ", Model: " .. GetEntityModel(entity)) end })
zed.AddContextOption({ type = "myself", label = "Heal", icon = "heart", onSelect = function(entity) SetEntityHealth(entity, 200); notify("Soigné", "success") end })
zed.AddContextOption({ type = "mycar", label = "Verrouiller mon véhicule", icon = "lock", onSelect = function(entity) SetVehicleDoorsLocked(entity, 2); notify("Véhicule verrouillé") end })

---@type number|nil
local interactId = zed.Interact({
    coords = vector3(2117.2, 4814.7, 41.2),
    label = "Point d'interaction (E)",
    key = "E",
    distance = 2.0,
    onSelect = function()
        notify("Interact déclenché")
    end,
})

zed.InteractProgress({
    coords = vector3(2115.0, 4810.2, 41.2),
    label = "Maintenir E (2s)",
    key = "E",
    distance = 2.0,
    duration = 2000,
    removeOnComplete = false,
    onSelect = function()
        notify("Action terminée", "success")
    end,
    onCancel = function()
        notify("Annulé", "warning")
    end,
})

RegisterCommand("zedlibdemo", function()
    buildDemoMenu()
    zed.OpenMenu(MENU_ID)
    notify("Menu démo ouvert (F5)", "success")
end, false)
RegisterKeyMapping("zedlibdemo", "ZedLib — Ouvrir le menu démo", "keyboard", "F5")

RegisterCommand("zedlibnotif", function(_, args)
    local t = args[1] or "info"
    zed.Notify({ type = t, title = "Test", subtitle = "ZedLib", message = "Notification type " .. t, duration = 3000 })
end, false)

RegisterCommand("zedlibdialog", function()
    zed.Confirm("Test", "Dialog de confirmation.", function() notify("Confirmé") end, function() notify("Annulé") end)
end, false)

RegisterCommand("zedlibprogress", function()
    local completed = zed.ProgressBar({
        duration = 5000,
        label = "Chargement...",
        canCancel = true,
        disable = { car = true, combat = true },
        anim = { dict = "mp_player_intdrink", clip = "loop_bottle" },
        prop = { model = "prop_ld_flow_bottle", pos = vector3(0.03, 0.03, 0.02), rot = vector3(0, 0, -1.5) },
    })
    notify(completed and "Terminé" or "Annulé", completed and "success" or "warning")
end, false)

RegisterCommand("zedlibcontext", function()
    notify("Maintenez ALT puis clic sur une entité (véhicule, PNJ, joueur)")
end, false)

RegisterCommand("zedlibclear", function()
    zed.CloseMenu()
    zed.CloseDialog()
    zed.ClearNotifications()
    if interactId then zed.ClearInteract(interactId) end
    zed.ClearInteractProgress()
    notify("Tout fermé / nettoyé")
end, false)

RegisterCommand("zedlibdebug", function()
    notify("Debug : zed.SetConfig({ debug = true }) ou commande /zeddebug (zedlib)")
end, false)

RegisterCommand("zedlibcopy", function()
    zed.CopyToClipboard("Texte copié depuis ZedLib Demo")
    notify("Texte copié dans le presse-papier")
end, false)
