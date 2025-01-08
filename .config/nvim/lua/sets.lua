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

-- Folds
vim.opt.foldnestmax = 4 -- Only provide folds 4 levels deep
vim.opt.foldlevelstart = 99 -- Don't collapse folds by default
vim.api.nvim_create_autocmd(
    "FileType",
    {
        callback = function()
            if require("nvim-treesitter.parsers").has_parser() then
                -- Use treesitter for main source of truth on folds
                vim.opt.foldmethod = "expr"
                vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
            else
                -- Fallback to syntax files
                vim.opt.foldmethod = "syntax"
            end
        end
    }
)

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
-- menuone = also show menu even if there's only one option
-- noselect = don't automatically select options, wait for user
vim.o.completeopt = 'menu,menuone,noselect'

-- Nice colors
vim.o.termguicolors = true

-- On scroll always keep 'x' lines of text below/above visible on screen
vim.opt.scrolloff = 8

-- Add horizontal line at 'x' characters
vim.opt.colorcolumn = "120"

-- Automatically change into the directory of the opened buffer
vim.opt.autochdir = true

-- Vim shada file
-- !':      Save and restore global variables that start with an uppercase letter and contain at least one lowercase letter.
-- '{{x}}:  Save the command-line history with a maximum of 100 entries.
-- <{{x}}:  Save the contents of registers if they are less than 50 lines long.
-- s{{x}}:  Save the search history with a maximum of 10 entries.
-- h:       Save and restore the 'hlsearch' setting (highlight search).
vim.opt.shada = "!,'20,<50,s10,h"

-- Start terminal in insert mode
vim.api.nvim_create_autocmd(
    'TermOpen',
    {
        pattern  = '*',
        command  = 'startinsert | set winfixheight'
    }
)

-- Allow execution of !commands in shell (i.e. :!ls runs ls in shell)
vim.cmd('set shellcmdflag="-c"')

-- Set up WSL as shell for nvim terminal
if IS_WINDOWS then
    vim.opt.shell='wsl.exe'
end

-- Change neovide to match system theme
if vim.g.neovide then
    vim.g.neovide_theme = 'auto'
end
