-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Vim sets
require('sets')

-- Install plugins
require('plugins')

-- Set up our colorscheme
vim.cmd([[colorscheme cfx16]])

-- Enable utils
require('utils')

-- Set up key binds
require('keymaps')

-- Misc post setup
require('after')
