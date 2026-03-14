fx_version 'cerulean'
game 'gta5'

name 'zedlib'
description 'Zed Library - Modern FiveM UI Library'
author 'Atoshi'
version '1.2.0'

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/**/*',
    'import.lua',
}

client_scripts {
    'config.lua',
    'lua/api/_init.lua',
    'lua/client.lua',
    'lua/api/menu.lua',
    'lua/api/notification.lua',
    'lua/api/dialog.lua',
    'lua/api/context.lua',
    'lua/api/progressbar.lua',
    'lua/api/interact.lua',
    'lua/api/watcher.lua',
    'lua/api/config.lua',
    'lua/api/exports.lua',
    'lua/events/notification.lua',
}

server_scripts {
    'lua/events/notification_server.lua',
}