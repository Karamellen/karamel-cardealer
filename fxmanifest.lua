fx_version 'cerulean'
games { 'gta5' }

shared_script 'config.lua'

client_scripts {
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
}