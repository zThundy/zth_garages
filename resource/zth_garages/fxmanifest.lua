fx_version "cerulean"
game "gta5"
lua54 "yes"

author "zThundy__"
description "Resource to manage all kinds of garages"
version "1.0.0"

ui_page "html/index.html"
files {
    "html/*.*",
    "html/**/*.*",
    
    "lib/Luaoop.lua",
    "lib/TunnelV2.lua",
    "lib/IDManager.lua",
    "lib/Tools.lua",
}

client_scripts {
    "client/main.lua",
    "client/utils.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/main.lua",
}

shared_scripts {
	"config.main.lua",
    "config.garages.lua",

	"lib/utils.lua",
}

dependencies {
    "gridsystem",
    "oxmysql"
}