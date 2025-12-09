-- Install treesitter
return {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
        'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
    config = function ()
        require('nvim-treesitter.configs').setup({
            -- Add languages to be installed here that you want installed for treesitter
            ensure_installed = { 'vim', 'vimdoc', 'lua', 'bash', 'c' },

            -- Install parsers synchronously (only applied to `ensure_installed`)
            sync_install = false,

            -- Automatically install missing parsers when entering buffer
            -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
            auto_install = true,

            -- List of parsers to ignore installing (or "all")
            ignore_install = {},

            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },

            fold = {
                enable = true,
            },

            indent = {
                enable = true,
            },

            modules = {},
        })

        -- Set up source of truth for folds and indents with fallback to vim indents
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
    end
}
