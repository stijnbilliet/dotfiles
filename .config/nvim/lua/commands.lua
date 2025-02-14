-- Set up source of truth for folds
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
                vim.opt.foldmethod = "indent"
            end
        end
    }
)

-- Start terminal in insert mode
vim.api.nvim_create_autocmd(
    'TermOpen',
    {
        pattern  = '*',
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

-- My TODO/Note list
vim.api.nvim_create_user_command(
    "Todo",
    function(opts)
        create_todo_file(opts.args or nil)
    end,
    { nargs='?' }
)

vim.api.nvim_create_user_command(
    "Lstodo",
    function(opts)
        list_todos(opts.args or nil)
    end,
    { nargs='?' }
)

vim.api.nvim_create_user_command(
    "Note",
    function(opts)
        create_new_zettle(opts.args or nil)
    end,
    { nargs='?' }
)

