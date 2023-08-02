fx_version 'cerulean'
game 'gta5'

author 'Side Project'

description 'Side Project Garage - Reworked by Sleepy Rae'

lua54 'yes'

ui_page 'ui/index.html'
 

files {
	'ui/script.js',
	'ui/progressbar.js',
	'ui/index.html',
	'ui/style.css',
	'ui/**',
	'locales/*'
}

shared_scripts {
	'@es_extended/imports.lua',
	'@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/server.lua'
}

client_scripts {
	'client/client.lua',
}
