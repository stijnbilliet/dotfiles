local atu = require 'aether.utils'

--- AutoCmds
-- Highlight when yanking (copying) text
-- Try it with `yap` in normal mode
-- See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd(
    'TextYankPost',
    {
        desc = 'Highlight when yanking (copying) text',
        callback = function()
            vim.hl.on_yank()
        end,
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

-- Change current working directory to match the logical root directory (root of project)
-- Makes telescope, terminal and other operations more natural
vim.api.nvim_create_autocmd(
    'BufEnter',
    {
        callback = function()
            local root = atu.find_root_dir(vim.api.nvim_get_current_buf())
            if root == nil then return end
            vim.fn.chdir(root)
        end
    }
)

--- User commands
-- Remove trailing whitespaces from buffer
vim.api.nvim_create_user_command(
    'Rt',
    atu.remove_trailing_whitespace,
    {}
)
