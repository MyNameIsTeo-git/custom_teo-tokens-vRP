resource_manifest_version "44febabe-d386-4d18-afbe-5e627f4af937"

author "MyNameIsTeo__"
description "Custom Token System [vRP]"
version "1.0.0"
dependency "mysql-async"

client_script {
	"lib/Tunnel.lua",
    "lib/Proxy.lua",
	"config.lua",
	"client/functions.lua",
	"client/main.lua"
}

server_script {
	"@vrp/lib/utils.lua",
	"@mysql-async/lib/MySQL.lua",
	"config.lua",
	"server/functions.lua",
	"server/main.lua"
}