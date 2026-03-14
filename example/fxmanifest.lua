fx_version 'cerulean'
game 'gta5'

name 'zedlib-example'
description 'ZedLib - Example'
author 'Atoshi'

dependencies {
    'zedlib',
}

client_scripts {
    '@zedlib/import.lua',
    'client.lua',
}
