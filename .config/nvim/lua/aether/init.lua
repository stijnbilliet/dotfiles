-- Set <space> as the leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Vim sets
require('aether.sets')

-- Install plugins
require('aether.lazy_plugins')

-- Set up our colorscheme
vim.cmd.colorscheme("cfx16")

-- Custom (Auto)commands
require('aether.commands')

-- Set up key binds
require('aether.remaps')
