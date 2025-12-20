fx_version 'cerulean'
game 'gta5'

author 'PinguimScripts'
description 'Christmas Script'
version '1.0.0'

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

client_scripts {
    'client.lua'
}


files {
    'locales/pt.json',
    'locales/en.json',
    'peds.meta'
}


dependencies {
    'ox_lib'
}

data_file 'PED_METADATA_FILE' 'peds.meta'