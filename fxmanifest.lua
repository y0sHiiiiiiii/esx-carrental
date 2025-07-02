fx_version 'cerulean'
game 'gta5'

description 'YS - Car Rental Script'
author 'YS Development'
version '1.0.0'

client_scripts {
    'config.lua',  
    'c.lua'
}

server_scripts {
    'config.lua',
    's.lua'
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/script.js',
    'ui/img/logo.png',
    'ui/img/bg.svg',
    'ui/img/car.png',
    'ui/img/buttonbg.svg'
}


dependency 'es_extended'
