fx_version 'cerulean' -- Verze FiveM
game 'gta5' -- Hra, pro kterou je resource určen

author 'Stody'
description 'NPC Mechanik - opravy a mytí vozidel'
version '1.0.0'

lua54 'yes' -- Aktivace Lua 5.4

shared_scripts {
    '@ox_lib/init.lua', -- Inicializace ox_lib
    'locales/*.lua' -- Lokalizační soubory
}

server_scripts {
    'server.lua' -- Server-side skript
}

client_scripts {
    'client.lua' -- Client-side skript
}

dependencies {
    'ox_lib',       -- Závislost na ox_lib
    'ox_inventory'  -- Závislost na ox_inventory
}
