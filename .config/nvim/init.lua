-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Vim sets
require('sets')

-- Install plugins
require('plugins')

-- Set up key binds
require('keymaps')

-- Misc post setup
require('after')
