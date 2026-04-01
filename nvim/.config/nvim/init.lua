require('options')
require('configs/lspconfig')
require('autoloader')
require('keymaps')

pcall(require, 'configs')
