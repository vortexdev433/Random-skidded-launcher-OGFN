

fx_version 'cerulean'
game 'gta5'

description 'QB-HUD'
version '1.0.0'

shared_scripts { 
	'@es_extended/imports.lua',
	'config.lua'
}

client_script 'client/main.lua'
server_script 'server/main.lua'

ui_page 'html/ui.html'

files {
	'html/ui.html',
	'html/css/*.css',
	'html/css/*.ttf',
	'html/js/*.js',
	'html/css/*.otf',
	'html/*.webp',
	'html/*.png',
}


