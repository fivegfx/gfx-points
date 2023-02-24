fx_version 'cerulean'
game 'gta5'

client_script {
    "config.lua",
	'client.lua',
}

server_script {
	'@oxmysql/lib/MySQL.lua',
	"config.lua",
	"server.lua",
}