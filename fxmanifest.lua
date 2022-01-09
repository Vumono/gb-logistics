fx_version 'cerulean'
game 'gta5'

shared_scripts {
    '@es_extended/imports.lua',
    'shared.lua'
}

server_script 'server.lua'

client_scripts {
    'client.lua',
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/EntityZone.lua'
    
}
