# ZedLib - Modern FiveM UI Library

A production-ready, modular UI library for FiveM with a modern React-based NUI frontend and a simple Lua API.

## Stack

- **Frontend**: React 19 + TypeScript (strict) + Vite
- **State**: Zustand
- **Styling**: TailwindCSS
- **Animations**: Framer Motion
- **Backend**: FiveM Lua (client-side)

## Features

- Menu system (RageUI-inspired, modern design)
- Notifications (success, error, warning, info)
- Dialogs with input fields
- Keyboard navigation
- Submenu stack navigation
- List selectors and sliders
- Plugin system
- Dev playground (no Storybook needed)
- Hot reload via Vite dev server
- Optimized production build for FiveM

## Project Structure

```
zedlib/
├── fxmanifest.lua           # FiveM resource manifest
├── lua/
│   ├── client.lua           # NUI bridge & callbacks
│   └── api.lua              # Lua UI API
├── web/
│   ├── package.json
│   ├── vite.config.ts
│   ├── tsconfig.json
│   ├── tailwind.config.ts
│   └── src/
│       ├── main.tsx
│       ├── App.tsx
│       ├── core/            # EventBus, PluginSystem, Registry
│       ├── components/
│       │   ├── menu/        # Menu system components
│       │   ├── notification/
│       │   └── dialog/
│       ├── stores/          # Zustand stores
│       ├── hooks/           # useNui, useKeyboard, useMenu
│       ├── nui/             # NUI bridge & message handlers
│       ├── devtools/        # Dev playground
│       ├── plugins/
│       ├── styles/
│       └── types/
└── example/                 # Example FiveM resource
    ├── fxmanifest.lua
    └── client.lua
```

## Installation

### 1. Build the UI

```bash
cd zedlib/web
npm install
npm run build
```

### 2. Add to FiveM server

Copy the `zedlib` folder to your server's `resources/` directory.

Add to `server.cfg`:
```
ensure zedlib
```

### 3. Use in your resource

Add `zedlib` as a dependency:
```lua
dependencies { 'zedlib' }
```

## Development

```bash
cd zedlib/web
npm install
npm run dev
```

Opens a dev server at `http://localhost:3000` with the **Playground** panel for testing all components without FiveM.

## Lua API

### Menu

```lua
-- Create a menu
UI.CreateMenu("main", "Menu Principal", "Subtitle")

-- Add a button
UI.AddButton("main", {
    label = "Mon Bouton",
    description = "Description optionnelle",
    icon = "🎯",
    onSelect = function(data)
        print("Button pressed!")
    end
})

-- Add a checkbox
UI.AddCheckbox("main", {
    label = "God Mode",
    checked = false,
    onChange = function(state)
        print("Checked:", state)
    end
})

-- Add a list selector
UI.AddList("main", {
    label = "Weather",
    items = {
        { label = "Clear", value = "CLEAR" },
        { label = "Rain", value = "RAIN" },
    },
    currentIndex = 1,
    onChange = function(index, item)
        print(item.label, item.value)
    end
})

-- Add a slider
UI.AddSlider("main", {
    label = "Speed",
    min = 0,
    max = 200,
    step = 10,
    value = 80,
    onChange = function(value)
        print("Value:", value)
    end
})

-- Add a separator
UI.AddSeparator("main")

-- Create and link a submenu
UI.CreateMenu("settings", "Settings")
UI.AddSubMenu("main", "settings", "Settings", {
    icon = "⚙️",
    description = "Open settings"
})

-- Open / Close
UI.OpenMenu("main")
UI.CloseMenu()
UI.RemoveMenu("main")
```

### Notifications

```lua
-- Generic
UI.Notify("success", "Title", "Message", 5000)

-- Shortcuts
UI.NotifySuccess("Title", "Message")
UI.NotifyError("Title", "Message")
UI.NotifyWarning("Title", "Message")
UI.NotifyInfo("Title", "Message")

-- Clear all
UI.ClearNotifications()
```

### Dialogs

```lua
-- Input dialog
UI.Dialog({
    title = "Spawn Vehicle",
    message = "Enter the model name",
    inputs = {
        { id = "model", label = "Model", placeholder = "adder", required = true },
        { id = "color", label = "Color", placeholder = "#FF0000" },
    },
    buttons = {
        { label = "Cancel", variant = "secondary", action = "cancel" },
        {
            label = "Spawn",
            variant = "primary",
            action = "spawn",
            onPress = function(values)
                print(values.model, values.color)
            end
        },
    }
})

-- Quick confirm dialog
UI.Confirm("Delete?", "Are you sure?",
    function() print("Confirmed") end,
    function() print("Cancelled") end
)

-- Close dialog
UI.CloseDialog()
```

### Exports

All API functions are also available as exports:

```lua
exports.zedlib:CreateMenu("id", "Title")
exports.zedlib:AddButton("id", { ... })
exports.zedlib:OpenMenu("id")
exports.zedlib:Notify("info", "Title", "Message")
exports.zedlib:Dialog({ ... })
```

## Keyboard Navigation

| Key | Action |
|-----|--------|
| `↑` `↓` | Navigate items |
| `Enter` | Select / Toggle |
| `←` `→` | List/Slider values |
| `Backspace` | Go back (submenu) |
| `Escape` | Close menu |

## Plugin System

```typescript
import { pluginSystem } from '@/plugins';

pluginSystem.register({
  name: 'my-plugin',
  version: '1.0.0',
  init: () => {
    console.log('Plugin loaded');
  },
  destroy: () => {
    console.log('Plugin unloaded');
  },
});
```

## Build for Production

```bash
cd zedlib/web
npm run build
```

Output goes to `web/dist/` which is referenced by `fxmanifest.lua`.

## License

MIT
