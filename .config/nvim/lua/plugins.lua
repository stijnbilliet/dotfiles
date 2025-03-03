-- Install lazy.nvim as our pluginmanager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Include plugins directory and set up plugins within
require('lazy').setup({
    spec = {
        { 'echasnovski/mini.base16' },
        { import = 'plugin' },
    },
    performance = {
        rtp = {
            -- disable some rtp plugins
            disabled_plugins = {
              "gzip",
              "matchit",
              "netrwPlugin",
              "tarPlugin",
              "tohtml",
              "tutor",
              "zipPlugin",
            },
        },
    },
}, {})
