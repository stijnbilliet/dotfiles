local atu = require 'aether.utils'

--- AutoCmds
-- Highlight when yanking (copying) text
-- Try it with `yap` in normal mode
-- See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd(
    'TextYankPost',
    {
        desc = 'Highlight when yanking (copying) text',
        callback = function()
            vim.highlight.on_yank()
        end,
    }
)

-- Set up source of truth for folds and indents
vim.api.nvim_create_autocmd(
    "FileType",
    {
        callback = function()
            if require("nvim-treesitter.parsers").has_parser() then
                -- Use treesitter for main source of truth on folds
                vim.opt.indentexpr = "nvim_treesitter#indent()"

                vim.opt.foldmethod = "expr"
                vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
            else
                -- Fallback to vim indents
                vim.opt.indentexpr = ""
                vim.opt.foldmethod = "indent"
            end
        end
    }
)

-- Start terminal in insert mode
vim.api.nvim_create_autocmd(
    {'TermOpen', 'BufEnter'},
    {
        pattern  = 'term://*',
        command  = 'startinsert | set winfixheight'
    }
)

-- Show lsp diagnostics on hover
vim.api.nvim_create_autocmd(
    "CursorHold",
    {
        pattern = "*",
        callback = function()
            for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
                if vim.api.nvim_win_get_config(winid).zindex then
                    return
                end
            end
            vim.diagnostic.open_float({
                scope = "cursor",
                focusable = false,
                close_events = {
                    "CursorMoved",
                    "CursorMovedI",
                    "BufHidden",
                    "InsertCharPre",
                    "WinLeave",
                },
            })
        end
    }
)

-- Change diagnostics error highlighting to be an undercurl instead of underline
vim.api.nvim_create_autocmd(
    {"VimEnter", "ColorScheme"},
    {
        pattern = "*",
        callback = function()
            vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { underline=false, undercurl = true })
        end,
    }
)

-- Highlight trailing whitespace
vim.api.nvim_create_autocmd(
    {"VimEnter", "ColorScheme"},
    {
        pattern = "*",
        callback = function()
            --Use the Beacon highlight group to denote extra trailing whitespace
            vim.api.nvim_set_hl(0, "ExtraWhitespace", { link = "Beacon" })
        end,
    }
)

vim.api.nvim_create_autocmd(
    "BufWinEnter",
    {
        --any buffer as long as it isn't a terminal
        pattern = "!~^term:://*",
        callback = function()
            vim.fn.matchadd("ExtraWhitespace", "\\s\\+$")
        end,
    }
)

vim.api.nvim_create_autocmd(
    "InsertEnter",
    {
        pattern = "*",
        callback = function()
            vim.fn.matchadd("ExtraWhitespace", "\\s\\+\\%#\\@<!$")
        end,
    }
)

vim.api.nvim_create_autocmd(
    "InsertLeave",
    {
        pattern = "*",
        callback = function()
            vim.fn.matchadd("ExtraWhitespace", "\\s\\+$")
        end,
    }
)

vim.api.nvim_create_autocmd(
    "BufWinLeave",
    {
        pattern = "*",
        callback = function()
            vim.cmd("call clearmatches()")
        end,
    }
)

--- User commands
-- My TODO/Note list
vim.api.nvim_create_user_command(
    "Todo",
    function(opts)
        atu.create_todo_file(opts.args or nil)
    end,
    { nargs='?' }
)

vim.api.nvim_create_user_command(
    "Lstodo",
    function(opts)
        atu.list_todos(opts.args or nil)
    end,
    { nargs='?' }
)

vim.api.nvim_create_user_command(
    "Note",
    function(opts)
        atu.create_new_zettle(opts.args or nil)
    end,
    { nargs='?' }
)

-- Remove trailing whitespaces from buffer
vim.api.nvim_create_user_command(
    'Rt',
    atu.remove_trailing_whitespace,
    {}
)
