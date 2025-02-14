-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Vim sets
require('sets')

-- Install plugins
require('plugins')

-- Set up our colorscheme
vim.cmd([[colorscheme cfx16]])

-- Util functions and callbacks
require('utils')

-- Custom (Auto)commands
require('commands')

-- Set up key binds
require('keymaps')

-- Misc post setup
require('after')
