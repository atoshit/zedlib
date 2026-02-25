fx_version 'cerulean'
game 'gta5'

name 'zedlib'
description 'Zed Library - Modern FiveM UI Library'
author 'ZedLib Team'
version '1.0.0'

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/**/*',
    'import.lua',
}

client_scripts {
    'lua/client.lua',
    'lua/api.lua',
}
