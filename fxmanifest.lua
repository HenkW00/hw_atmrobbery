fx_version 'cerulean'
games {'gta5'}

lua54 'yes'

name         'hw_atmrobbery'
version      '1.6.1'
description  'ATM Robbery system'
author       'HenkW'


dependency 'ox_lib'

shared_scripts {
	'@es_extended/imports.lua',
	'@ox_lib/init.lua',
    'shared/*.lua',
}

server_scripts {
	'server/version.lua',
	'server/server.lua'
}

client_scripts {
	'client/*.lua'
}

files{
    'locales/*.json'
}

escrow_ignore {
	'shared/config_functions.lua',
	'fxmanifest.lua'
}
