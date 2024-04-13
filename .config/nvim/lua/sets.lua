-- set up globals to detect operating system
local uname = vim.loop.os_uname()
_G.OS = uname.sysname
_G.IS_MAC = OS == 'Darwin'
_G.IS_LINUX = OS == 'Linux'
_G.IS_WINDOWS = OS:find 'Windows' and true or false
_G.IS_WSL = IS_LINUX and uname.release:find 'Microsoft' and true or false

-- Don't highlight everything on search & visual incremental search
vim.o.hlsearch = false
vim.opt.incsearch = true

-- Linenumbers
vim.opt.nu = true
vim.opt.relativenumber = true

-- Tabs
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

-- Auto indent
vim.opt.smartindent = true

-- Don't wrap text
vim.opt.wrap = false

-- Sync clipboard between OS and Neovim.
vim.o.clipboard = 'unnamedplus'

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Decrease update time
vim.o.updatetime = 50

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- Nice colors
vim.o.termguicolors = true

-- On scroll always keep 'x' lines of text below/above visible on screen
vim.opt.scrolloff = 8

-- Add horizontal line at 'x' characters
vim.opt.colorcolumn = "120"

-- Allow execution of !commands in shell (i.e. :!ls runs ls in shell)
vim.cmd('set shellcmdflag="-c"')

-- Set up WSL as shell for nvim terminal
if IS_WINDOWS then
    vim.opt.shell='wsl.exe'
end
