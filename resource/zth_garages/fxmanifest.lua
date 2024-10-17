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
    '@qb-core/shared/jobs.lua',

	"lib/utils.lua",
}

client_scripts {
    "client/functions.lua",

    "client/main.lua",
    "client/utils.lua",
    "client/nui.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    
    "server/functions.lua",
    "server/interface.lua",
    "server/main.lua",
}

dependencies {
    "gridsystem",
    "oxmysql",
}