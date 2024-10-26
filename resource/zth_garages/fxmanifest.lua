fx_version "cerulean"
games { "gta5", "rdr3" }
lua54 "yes"

author "zThundy__"
description "Resource to manage all kinds of garages"
version "1.0.0"

files {
    "html/*",
    "html/config/*.json",
    "html/static/js/*",
    "html/static/css/*",
    "html/svg/*",

    "html/index.html",
    
    "lib/Luaoop.lua",
    "lib/TunnelV2.lua",
    "lib/IDManager.lua",
    "lib/Tools.lua",
}

ui_page "html/index.html"

shared_scripts {
	"config.main.lua",
    "config.garages.lua",
    "config.impounds.lua",
    "config.language.lua",
    "config.houses.lua",
    
	"lib/utils.lua",
    "lib/timeouts.lua",
    "lib/exports.lua",
}

client_scripts {
    "client/functions.lua",
    "client/impounds.lua",
    "client/house.lua",
    
    "client/main.lua",
    "client/utils.lua",
    "client/camera.lua",
    "client/nui.lua",
    "client/commands.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    
    "server/functions.lua",
    "server/interface.lua",
    "server/interface.impound.lua",
    "server/interface.house.lua",
    "server/commands.lua",
    "server/main.lua",
}

dependencies {
    "gridsystem",
    "oxmysql",
}