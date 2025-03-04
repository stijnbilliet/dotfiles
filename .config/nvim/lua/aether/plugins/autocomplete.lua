-- Autocompletion
return {
    {
        'hrsh7th/nvim-cmp',
        event = "InsertEnter",
        lazy = true,
        dependencies = {
            -- Snippet Engine & its associated nvim-cmp source
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',

            -- Adds LSP/buffer/path completion capabilities
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-nvim-lsp-signature-help',
            'hrsh7th/cmp-cmdline',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path'
        },
        config = function()
            local cmp = require 'cmp'
            local luasnip = require 'luasnip'
            luasnip.config.setup {}

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'nvim_lsp_signature_help' },
                    { name = 'luasnip' },
                    { name = 'path' },
                }),
            });

            -- Add autocompletion in command mode, for both paths and cmds
            cmp.setup.cmdline(':', {
                completion = { autocomplete = false },
                sources = cmp.config.sources({
                    { name = 'path' },
                    {
                        name = 'cmdline',
                        option = {
                            ignore_cmds = { 'Man', '!' },
                        },
                    },
                }),
            })

            -- Use buffer source for `/` and `?`
            cmp.setup.cmdline({ '/', '?' }, {
                completion = { autocomplete = false },
                sources = {
                    { name = 'buffer' }
                }
            })
        end
    },
}
