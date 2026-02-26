<img width="427" height="559" alt="image" src="https://github.com/user-attachments/assets/de2d8a0b-0032-4a53-9da7-98853dee5e2b" />

# ZedLib - Modern FiveM UI Library

A production-ready, modular UI library for FiveM featuring a React-based NUI frontend and a clean Lua API. Build beautiful menus, notifications, and dialogs with minimal code.

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Installation](#installation)
- [Usage Methods](#usage-methods)
- [Usage](#usage)
  - [Menus](#menus)
  - [Notifications](#notifications)
  - [Dialogs](#dialogs)
  - [Configuration](#configuration)
- [Keyboard Navigation](#keyboard-navigation)
- [Full API Reference](#full-api-reference)
- [Complete Example](#complete-example)
- [Development](#development)
- [Project Structure](#project-structure)
- [License](#license)

---

## Features

### Menu System
- Fully navigable menus with keyboard controls
- **Button**, **checkbox**, **list** selector, **slider**, **separator**, **submenu**, **category**, and **info** items
- **Categories**: expand/collapse groups of items in-place (e.g. "Actions on player" → Freeze, Kick, Ban); items can be assigned to a category and only show when it is expanded
- **Info button**: hover or focus to show a side panel with label/value pairs (e.g. player name, group, job)
- Search/filter functionality for large menus
- Submenu stack navigation with back support
- Custom accent colors and banner images (default accent: red)
- Icon support (FontAwesome names or image URLs)
- Optional **category** on any item so it appears only when that category is expanded

### Notifications
- Four notification types: success, error, warning, info
- Optional **custom accent color** per notification
- Configurable display duration
- Optional body message and icon
- Bulk clear support
- Black background with colored accent bar and icon badge

### Dialogs
- Input dialogs with field types: **text**, **number**, **password**, **textarea**
- Optional **accent color** and **header icon** per dialog
- Confirm/cancel dialogs with one-liner shortcut (with optional color)
- Customizable buttons with primary, secondary, danger variants and optional **icon**
- Field validation (required, maxLength, min/max)
- Closable toggle
- Default accent color: red when not specified

### General
- UI sound effects (hover, select, toggle) with global toggle
- Smooth animations and hover shine effects
- Plugin system for extensibility
- Hot reload dev playground (no FiveM required)
- Optimized production build
- **Lua API split by component**: `lua/api/` (menu, notification, dialog, config, exports)

---

## Tech Stack

| Layer     | Technology                              |
|-----------|-----------------------------------------|
| Frontend  | React 19, TypeScript (strict), Vite 6   |
| State     | Zustand 5                               |
| Styling   | TailwindCSS 3                           |
| Animation | Framer Motion 11                        |
| Backend   | FiveM Lua (client-side)                 |

---

## Installation

### 1. Build the UI

```bash
cd zedlib/web
npm install
npm run build
```

### 2. Add to your FiveM server

Copy the `zedlib` folder into your server's `resources/` directory, then add it to your `server.cfg`:

```cfg
ensure zedlib
```

### 3. Set up your resource

**Option A — Import file (recommended)**

Add zedlib as a dependency and include `import.lua` in your `fxmanifest.lua`. This gives you the `zed.*` API with automatic cross-resource callback support:

```lua
fx_version 'cerulean'
game 'gta5'

dependencies { 'zedlib' }

shared_scripts {
    '@zedlib/import.lua',
}

client_scripts {
    'client.lua',
}
```

You can then use the `zed.*` namespace in your scripts:

```lua
zed.CreateMenu("my_menu", "My Menu")
```

**Option B — Exports**

Add zedlib as a dependency and call functions through FiveM exports. No extra file needed:

```lua
fx_version 'cerulean'
game 'gta5'

dependencies { 'zedlib' }

client_scripts {
    'client.lua',
}
```

You can then call any function via `exports.zedlib`:

```lua
exports.zedlib:CreateMenu("my_menu", "My Menu")
```

> Both methods provide the exact same functionality. The `zed.*` import is generally more convenient for scripts with many callbacks.

---

## Usage Methods

ZedLib exposes every function through **three equivalent interfaces**. Pick whichever suits your project:

| Interface | Scope | Example |
|-----------|-------|---------|
| `zed.*` | Any resource that imports `@zedlib/import.lua` | `zed.OpenMenu("main")` |
| `exports.zedlib:*` | Any resource with `zedlib` as dependency | `exports.zedlib:OpenMenu("main")` |
| `UI.*` | Internal to the zedlib resource itself | `UI.OpenMenu("main")` |

All code examples below use the `zed.*` style. Replace with `exports.zedlib:` if you prefer exports.

---

## Usage

### Menus

#### Creating a Menu

```lua
zed.CreateMenu("main", "Main Menu", "Select an option", {
    color = "#3498db",   -- accent color (hex)
    banner = "https://example.com/banner.png" -- header banner image URL
})
```

| Parameter  | Type   | Required | Description |
|------------|--------|----------|-------------|
| `id`       | string | yes      | Unique menu identifier |
| `title`    | string | yes      | Title displayed in the menu header |
| `subtitle` | string | no       | Subtitle below the title (hidden when a banner is set) |
| `opts`     | table  | no       | Additional options: `color` (hex string), `banner` (image URL). Default accent color when not set: red (`#e74c3c`). |

---

#### Adding a Button

```lua
zed.AddButton("main", {
    label = "Teleport to Marker",
    description = "Teleports you to your map marker",
    icon = "location-dot",
    onSelect = function()
        local blip = GetFirstBlipInfoId(8)
        if DoesBlipExist(blip) then
            local coords = GetBlipInfoIdCoord(blip)
            SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
            zed.NotifySuccess("Teleported", "You have been teleported to the marker")
        end
    end
})
```

| Option     | Type     | Default | Description |
|------------|----------|---------|-------------|
| `label`    | string   | —       | Display text for the button |
| `description` | string | nil   | Secondary text shown below the label |
| `icon`     | string   | nil     | FontAwesome icon name (e.g. `"gear"`) or image URL |
| `id`       | string   | auto    | Custom unique identifier |
| `disabled` | boolean  | false   | Prevents interaction when true |
| `category` | string   | nil     | Category id: item is only visible when this category is expanded |
| `metadata` | table    | nil     | Arbitrary data passed to the `onSelect` callback |
| `onSelect` | function | nil     | Callback fired when the button is selected |

---

#### Adding a Checkbox

```lua
zed.AddCheckbox("main", {
    label = "God Mode",
    icon = "shield",
    checked = false,
    onChange = function(checked)
        print("God Mode:", checked)
        SetEntityInvincible(PlayerPedId(), checked)
    end
})
```

| Option     | Type     | Default | Description |
|------------|----------|---------|-------------|
| `label`    | string   | —       | Display text |
| `icon`     | string   | nil     | FontAwesome icon name or image URL |
| `id`       | string   | auto    | Custom unique identifier |
| `disabled` | boolean  | false   | Prevents interaction when true |
| `category` | string   | nil     | Category id: item only visible when this category is expanded |
| `checked`  | boolean  | false   | Initial checked state |
| `onChange`  | function | nil     | Callback receiving the new `checked` boolean |

---

#### Adding a List Selector

Use left/right arrow keys to cycle through options.

```lua
zed.AddList("main", {
    label = "Weather",
    icon = "cloud-sun",
    items = {
        { label = "Clear",    value = "CLEAR" },
        { label = "Rain",     value = "RAIN" },
        { label = "Thunder",  value = "THUNDER" },
        { label = "Snow",     value = "SNOW" },
    },
    currentIndex = 1,
    onChange = function(index, item)
        print("Selected:", item.label, "Value:", item.value, "Index:", index)
        SetWeatherTypeNow(item.value)
    end
})
```

You can also pass plain strings — they are auto-converted to `{ label = str, value = str }`:

```lua
zed.AddList("main", {
    label = "Color",
    items = { "Red", "Green", "Blue" },
    onChange = function(index, item)
        print(item.value) -- "Red", "Green", or "Blue"
    end
})
```

| Option        | Type     | Default | Description |
|---------------|----------|---------|-------------|
| `label`       | string   | —       | Display text |
| `icon`        | string   | nil     | FontAwesome icon name or image URL |
| `id`          | string   | auto    | Custom unique identifier |
| `disabled`    | boolean  | false   | Prevents interaction when true |
| `category`    | string   | nil     | Category id: item only visible when this category is expanded |
| `items`       | table    | —       | Array of `{ label, value }` tables or plain strings |
| `currentIndex`| number   | 1       | Initial selected index (1-based) |
| `onChange`     | function | nil     | Callback receiving `(index, item)` — index is 1-based |

---

#### Adding a Slider

Use left/right arrow keys to adjust the value.

```lua
zed.AddSlider("main", {
    label = "Vehicle Speed",
    icon = "gauge-high",
    min = 0,
    max = 200,
    step = 10,
    value = 80,
    onChange = function(value)
        print("Speed set to:", value)
        SetVehicleMaxSpeed(GetVehiclePedIsIn(PlayerPedId(), false), value + 0.0)
    end
})
```

| Option    | Type     | Default | Description |
|-----------|----------|---------|-------------|
| `label`   | string   | —       | Display text |
| `icon`    | string   | nil     | FontAwesome icon name or image URL |
| `id`      | string   | auto    | Custom unique identifier |
| `disabled`| boolean  | false   | Prevents interaction when true |
| `category`| string   | nil     | Category id: item only visible when this category is expanded |
| `min`     | number   | 0       | Minimum value |
| `max`     | number   | 100     | Maximum value |
| `step`    | number   | 1       | Step increment |
| `value`   | number   | 0       | Initial value |
| `onChange` | function | nil    | Callback receiving the new `value` |

---

#### Adding a Separator

Inserts a visual divider line between menu items. Optional second argument for category.

```lua
zed.AddSeparator("main")

-- Separator only visible when category "actions" is expanded
zed.AddSeparator("main", { category = "actions" })
```

| Option     | Type   | Default | Description |
|------------|--------|---------|-------------|
| `category` | string | nil     | Category id: separator only visible when this category is expanded |

---

#### Adding a Category

Categories let you group items that appear only when the category is expanded (e.g. "Actions on player" → Freeze, Kick, Ban). **Different from submenus**: the category expands in-place; no new menu screen.

```lua
-- Add the category header (id is used when assigning items to this category)
zed.AddCategory("main", {
    label = "Actions on player",
    id = "actions_player",
    icon = "bolt",
})

-- Add items that belong to this category (they are hidden until the category is opened)
zed.AddButton("main", {
    label = "Freeze",
    icon = "snowflake",
    category = "actions_player",
    onSelect = function() -- ... end,
})
zed.AddButton("main", { label = "Kick",  category = "actions_player", onSelect = function() end })
zed.AddButton("main", { label = "Ban",   category = "actions_player", onSelect = function() end })
```

| Option     | Type   | Required | Description |
|------------|--------|----------|-------------|
| `label`    | string | yes      | Display label for the category header |
| `id`       | string | yes      | Category id — use this in `opts.category` when adding items |
| `icon`     | string | no       | FontAwesome icon name or image URL |
| `disabled` | boolean| no       | Whether the category header is disabled (default: false) |

Any menu item (button, checkbox, list, slider, submenu, search, info, separator) can have `category = "id"` so it is only visible when that category is expanded.

---

#### Adding an Info Button

Shows a side panel with label/value pairs when the item is focused or hovered. Does nothing on select (no action). Ideal for player details, entity info, etc.

```lua
zed.AddInfoButton("main", {
    label = "Player info",
    icon = "id-card",
    data = {
        { label = "Name",   value = "John Doe" },
        { label = "Group",  value = "Admin" },
        { label = "Job",    value = "Police" },
        { label = "Money",  value = "$12,500" },
    }
})
```

| Option     | Type   | Default | Description |
|------------|--------|---------|-------------|
| `label`    | string | —       | Display label for the info button |
| `icon`     | string | nil     | FontAwesome icon name or image URL |
| `id`       | string | auto    | Custom unique identifier |
| `disabled` | boolean| false   | Whether the info button is disabled |
| `category` | string | nil     | Category id: item only visible when this category is expanded |
| `data`     | table  | —       | Array of `{ label, value }` pairs shown in the side panel |

---

#### Adding a Search Button

Adds a search/filter input that filters menu items in real-time by label.

```lua
zed.AddSearchButton("main", {
    label = "Search",
    icon = "magnifying-glass",
    placeholder = "Type to filter..."
})
```

| Option       | Type   | Default                | Description |
|--------------|--------|------------------------|-------------|
| `label`      | string | `"Rechercher"`         | Display text |
| `icon`       | string | `"magnifying-glass"`   | FontAwesome icon name |
| `placeholder`| string | `"Tapez pour rechercher..."` | Placeholder text when active |
| `id`         | string | auto                   | Custom unique identifier |
| `category`   | string | nil                    | Category id: item only visible when this category is expanded |

---

#### Creating Submenus

Submenus are created by registering a child menu and linking it to a parent.

```lua
-- Create the parent menu
zed.CreateMenu("main", "Main Menu")

-- Add a submenu link (this also registers the submenu automatically)
zed.AddSubMenu("main", "settings", "Settings", {
    icon = "gear",
    subtitle = "Configure your preferences",
    color = "#e74c3c",
})

-- Now add items to the submenu using its ID
zed.AddCheckbox("settings", {
    label = "Enable Sounds",
    checked = true,
    onChange = function(checked)
        zed.SetConfig({ sounds = checked })
    end
})

zed.AddButton("settings", {
    label = "Reset Defaults",
    icon = "rotate",
    onSelect = function()
        zed.NotifyInfo("Reset", "Settings restored to defaults")
    end
})

-- Open the parent menu
zed.OpenMenu("main")
```

`AddSubMenu` options:

| Option     | Type   | Default | Description |
|------------|--------|---------|-------------|
| `icon`     | string | nil     | FontAwesome icon name or image URL |
| `id`       | string | auto    | Custom identifier for the submenu link item |
| `disabled` | boolean| false   | Prevents interaction when true |
| `category` | string | nil     | Category id: item only visible when this category is expanded |
| `subtitle` | string | label   | Title override for the submenu header |
| `color`    | string | nil     | Accent color override (hex) |
| `banner`   | string | nil     | Banner image URL override |

---

#### Opening, Closing, and Removing Menus

```lua
-- Open a menu by its ID
zed.OpenMenu("main")

-- Close the currently open menu
zed.CloseMenu()

-- Check if any menu is currently open
if zed.IsMenuOpen() then
    print("A menu is open")
end

-- Remove a menu and free its resources
zed.RemoveMenu("main")
```

---

### Notifications

#### Generic Notification

```lua
zed.Notify("success", "Purchase Complete", "You bought a Zentorno for $725,000", 5000)

-- With custom accent color (hex)
zed.Notify("info", "Custom", "Message here", 5000, "#3498db")
```

| Parameter  | Type   | Required | Default | Description |
|------------|--------|----------|---------|-------------|
| `type`     | string | yes      | —       | One of `"success"`, `"error"`, `"warning"`, `"info"` |
| `title`    | string | yes      | —       | Notification title |
| `message`  | string | no       | nil     | Body text |
| `duration` | number | no       | 5000    | Display time in milliseconds |
| `color`    | string | no       | type default | Accent color (hex, e.g. `"#e74c3c"`) |

#### Shortcut Functions

```lua
zed.NotifySuccess("Saved", "Your progress has been saved")
zed.NotifyError("Failed", "Could not connect to the database")
zed.NotifyWarning("Low Health", "Your health is below 25%")
zed.NotifyInfo("Tip", "Press E to interact with nearby objects")

-- With custom color (optional 4th parameter)
zed.NotifySuccess("Done", "Saved", 5000, "#22c55e")
```

Each shortcut accepts `(title, message?, duration?, color?)`.

#### Clear All Notifications

```lua
zed.ClearNotifications()
```

---

### Dialogs

#### Input Dialog

Create a dialog with input fields and action buttons. The dialog captures NUI focus automatically.

```lua
zed.Dialog({
    title = "Spawn Vehicle",
    message = "Enter the vehicle details below",
    type = "input",
    closable = true,
    inputs = {
        {
            id = "model",
            type = "text",
            label = "Model Name",
            placeholder = "adder",
            required = true,
            maxLength = 32
        },
        {
            id = "color",
            type = "text",
            label = "Color (hex)",
            placeholder = "#FF0000",
        },
        {
            id = "amount",
            type = "number",
            label = "Quantity",
            default = 1,
            min = 1,
            max = 10
        },
    },
    buttons = {
        {
            label = "Cancel",
            variant = "secondary",
            action = "cancel",
        },
        {
            label = "Spawn",
            variant = "primary",
            action = "spawn",
            onPress = function(values)
                print("Model:", values.model)
                print("Color:", values.color)
                print("Amount:", values.amount)
            end
        },
    },
})
```

**Dialog options:**

| Option    | Type    | Default   | Description |
|-----------|---------|-----------|-------------|
| `id`      | string  | auto      | Custom dialog identifier |
| `type`    | string  | `"input"` | `"input"` or `"confirm"` |
| `title`   | string  | —         | Dialog title |
| `message` | string  | nil       | Description text |
| `inputs`  | table   | nil       | Array of input field definitions |
| `buttons` | table   | nil       | Array of button definitions |
| `closable`| boolean | true      | Whether the dialog can be dismissed with Escape |
| `color`   | string  | `"#e74c3c"` | Accent color (hex) for header bar and primary button |
| `icon`    | string  | nil       | FontAwesome icon name in dialog header (e.g. `"circle-question"`) |
| `onResult`| function| nil       | Global callback receiving `(action, values)` for any button press |

**Input field options:**

| Option       | Type    | Default     | Description |
|--------------|---------|-------------|-------------|
| `id`         | string  | `"input_N"` | Field identifier (key in `values` table) |
| `type`       | string  | `"text"`    | `"text"`, `"number"`, `"password"`, or `"textarea"` |
| `label`      | string  | —           | Field label |
| `placeholder`| string  | nil         | Placeholder text |
| `default`    | any     | nil         | Default value |
| `required`   | boolean | false       | Whether the field must be filled |
| `maxLength`  | number  | nil         | Maximum character length |
| `min`        | number  | nil         | Minimum value (number fields only) |
| `max`        | number  | nil         | Maximum value (number fields only) |

**Button options:**

| Option    | Type     | Default       | Description |
|-----------|----------|---------------|-------------|
| `label`   | string   | —             | Button text |
| `variant` | string   | `"secondary"` | `"primary"`, `"secondary"`, or `"danger"` |
| `action`  | string   | auto          | Action identifier sent to callbacks |
| `icon`    | string   | nil           | FontAwesome icon name before the label (e.g. `"trash"`) |
| `onPress` | function | nil           | Callback receiving the `values` table |

#### Using `onResult` Instead of Per-Button Callbacks

You can handle all button actions in a single callback:

```lua
zed.Dialog({
    title = "Delete Character",
    message = "This action is irreversible. Are you sure?",
    type = "confirm",
    buttons = {
        { label = "Keep",   variant = "secondary", action = "cancel" },
        { label = "Delete", variant = "danger",    action = "delete" },
    },
    onResult = function(action, values)
        if action == "delete" then
            print("Character deleted")
        else
            print("Cancelled")
        end
    end
})
```

#### Quick Confirm Dialog

A one-liner shortcut for simple yes/no confirmations:

```lua
zed.Confirm("Delete Vehicle?", "This will permanently remove your vehicle.",
    function()
        print("User confirmed")
        DeleteVehicle(GetVehiclePedIsIn(PlayerPedId(), true))
    end,
    function()
        print("User cancelled")
    end
)
```

| Parameter   | Type     | Required | Description |
|-------------|----------|----------|-------------|
| `title`     | string   | yes      | Dialog title |
| `message`   | string   | yes      | Dialog message |
| `onConfirm` | function | no       | Callback fired when the user confirms |
| `onCancel`  | function | no       | Callback fired when the user cancels |
| `color`     | string   | no       | Accent color (hex) for the dialog |

#### Close Dialog

```lua
zed.CloseDialog()
```

---

### Configuration

Toggle global settings at runtime.

```lua
zed.SetConfig({
    sounds = false -- disable all UI sounds
})
```

| Option   | Type    | Default | Description |
|----------|---------|---------|-------------|
| `sounds` | boolean | true    | Enable or disable UI sound effects (hover, select, toggle) |

---

## Keyboard Navigation

When a menu is open, the following controls are active. Weapon and attack controls are automatically disabled.

| Key          | Action                            |
|--------------|-----------------------------------|
| `Arrow Up`   | Move selection up                 |
| `Arrow Down` | Move selection down               |
| `Enter`      | Select / Toggle current item      |
| `Arrow Left` | Previous option (list) / Decrease (slider) |
| `Arrow Right`| Next option (list) / Increase (slider) |
| `Backspace`  | Go back to parent menu            |
| `Escape`     | Close the menu entirely           |

Hold arrow keys for auto-repeat (300ms initial delay, 80ms repeat interval).

---

## Full API Reference

### Menu Functions

| Function | Parameters | Returns | Description |
|----------|-------------|---------|-------------|
| `CreateMenu` | `id, title, subtitle?, opts?` | — | Register a new menu |
| `AddButton` | `menuId, opts` | `itemId` | Add a button item |
| `AddCheckbox` | `menuId, opts` | `itemId` | Add a checkbox item |
| `AddList` | `menuId, opts` | `itemId` | Add a list selector |
| `AddSlider` | `menuId, opts` | `itemId` | Add a slider |
| `AddSeparator` | `menuId, opts?` | `itemId` | Add a visual separator (opts: category) |
| `AddCategory` | `menuId, opts` | `categoryId` | Add a category header (expand/collapse items) |
| `AddSearchButton` | `menuId, opts?` | `itemId` | Add a search/filter input |
| `AddInfoButton` | `menuId, opts` | `itemId` | Add an info button (hover panel with label/value) |
| `AddSubMenu` | `menuId, subMenuId, label, opts?` | `subMenuId` | Link and register a submenu |
| `OpenMenu` | `id` | — | Open a menu |
| `CloseMenu` | — | — | Close the current menu |
| `IsMenuOpen` | — | `boolean` | Check if a menu is open |
| `RemoveMenu` | `id` | — | Remove a menu and free resources |

### Notification Functions

| Function | Parameters | Returns | Description |
|----------|-------------|---------|-------------|
| `Notify` | `type, title, message?, duration?, color?` | — | Show a notification |
| `NotifySuccess` | `title, message?, duration?, color?` | — | Show a success notification |
| `NotifyError` | `title, message?, duration?, color?` | — | Show an error notification |
| `NotifyWarning` | `title, message?, duration?, color?` | — | Show a warning notification |
| `NotifyInfo` | `title, message?, duration?, color?` | — | Show an info notification |
| `ClearNotifications` | — | — | Dismiss all notifications |

### Dialog Functions

| Function | Parameters | Returns | Description |
|----------|-------------|---------|-------------|
| `Dialog` | `opts` | `dialogId` | Open an input/custom dialog (opts: color, icon, inputs type textarea, button icon) |
| `Confirm` | `title, message, onConfirm?, onCancel?, color?` | — | Open a quick confirm dialog |
| `CloseDialog` | — | — | Close the active dialog |

### Configuration Functions

| Function | Parameters | Returns | Description |
|----------|-----------|---------|-------------|
| `SetConfig` | `opts` | — | Update runtime configuration |

---

## Complete Example

A full working example combining menus, submenus, notifications, and dialogs:

```lua
-- In your resource's client.lua (with @zedlib/import.lua loaded)

RegisterCommand("mymenu", function()
    -- Create menus
    zed.CreateMenu("main", "Admin Panel", "Server Administration", {
        banner = "https://forum-cfx-re.akamaized.net/original/4X/d/1/2/d12e827f6eba4f2b64c78dc10895aefe4eaffd4e.jpeg",
        color = "#e74c3c"
    })

    -- Player actions
    zed.AddButton("main", {
        label = "Heal Player",
        icon = "heart",
        description = "Restore full health",
        onSelect = function()
            SetEntityHealth(PlayerPedId(), 200)
            zed.NotifySuccess("Healed", "Health restored to full")
        end
    })

    zed.AddCheckbox("main", {
        label = "Invisible",
        icon = "eye-slash",
        checked = false,
        onChange = function(checked)
            SetEntityVisible(PlayerPedId(), not checked, false)
            zed.NotifyInfo("Visibility", checked and "You are now invisible" or "You are now visible")
        end
    })

    zed.AddSeparator("main")

    -- Vehicle submenu
    zed.AddSubMenu("main", "vehicles", "Vehicles", {
        icon = "car",
        subtitle = "Vehicle Management"
    })

    zed.AddButton("vehicles", {
        label = "Spawn Vehicle",
        icon = "plus",
        onSelect = function()
            zed.CloseMenu()
            zed.Dialog({
                title = "Spawn Vehicle",
                message = "Enter a vehicle model name",
                inputs = {
                    { id = "model", type = "text", label = "Model", placeholder = "adder", required = true }
                },
                buttons = {
                    { label = "Cancel", variant = "secondary", action = "cancel" },
                    {
                        label = "Spawn",
                        variant = "primary",
                        action = "spawn",
                        onPress = function(values)
                            print("Spawning:", values.model)
                        end
                    }
                }
            })
        end
    })

    zed.AddList("vehicles", {
        label = "Vehicle Color",
        icon = "palette",
        items = {
            { label = "Red",    value = 27 },
            { label = "Blue",   value = 64 },
            { label = "Green",  value = 55 },
            { label = "Black",  value = 0 },
            { label = "White",  value = 134 },
        },
        currentIndex = 1,
        onChange = function(index, item)
            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
            if veh ~= 0 then
                SetVehicleColours(veh, item.value, item.value)
            end
        end
    })

    zed.AddSlider("vehicles", {
        label = "Max Speed",
        icon = "gauge-high",
        min = 50,
        max = 300,
        step = 25,
        value = 150,
        onChange = function(value)
            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
            if veh ~= 0 then
                SetVehicleMaxSpeed(veh, value + 0.0)
            end
        end
    })

    -- Danger zone submenu
    zed.AddSubMenu("main", "danger", "Danger Zone", {
        icon = "triangle-exclamation",
        color = "#c0392b"
    })

    zed.AddButton("danger", {
        label = "Delete Nearby Vehicles",
        icon = "trash",
        onSelect = function()
            zed.CloseMenu()
            zed.Confirm("Delete Vehicles?", "This will remove all vehicles in a 50m radius.",
                function()
                    zed.NotifySuccess("Deleted", "Nearby vehicles have been removed")
                end,
                function()
                    zed.NotifyInfo("Cancelled", "No vehicles were deleted")
                end
            )
        end
    })

    -- Search (useful for long menus)
    zed.AddSearchButton("main", {
        label = "Search",
        placeholder = "Filter options..."
    })

    zed.OpenMenu("main")
end)
```

---

## Development

Start the Vite dev server for local UI development without FiveM:

```bash
cd zedlib/web
npm install
npm run dev
```

This opens a dev server with a **Playground** panel for testing all components interactively.

### Production Build

```bash
cd zedlib/web
npm run build
```

Output goes to `web/dist/`, referenced by `fxmanifest.lua`.

---

## Project Structure

```
zedlib/
├── fxmanifest.lua            # FiveM resource manifest
├── import.lua                # zed.* API wrapper with cross-resource callback support
├── lua/
│   ├── client.lua            # NUI bridge, keyboard controls, callback routing
│   └── api/                  # Lua API split by component
│       ├── _init.lua         # UI table, ZedInternal (generateId, fireCallback)
│       ├── menu.lua          # CreateMenu, AddButton, AddCheckbox, AddCategory, AddInfoButton, etc.
│       ├── notification.lua # Notify, NotifySuccess/Error/Warning/Info, ClearNotifications
│       ├── dialog.lua        # Dialog, Confirm, CloseDialog
│       ├── config.lua        # SetConfig
│       └── exports.lua       # FiveM exports for all functions
└── web/
    ├── package.json
    ├── src/
    │   ├── main.tsx           # React entry point
    │   ├── App.tsx            # Root component
    │   ├── core/              # EventBus, PluginSystem, Registry, Sounds
    │   ├── components/        # Menu, Dialog, Notification (menu: category, info panel)
    │   ├── stores/            # Zustand state stores
    │   ├── hooks/             # useNui, useKeyboard, useMenu
    │   ├── nui/               # NUI bridge and message handlers
    │   ├── types/             # TypeScript type definitions
    │   └── devtools/          # Dev playground
    └── dist/                  # Production build output
```

---

## License

MIT
