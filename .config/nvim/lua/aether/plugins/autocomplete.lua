-- Autocompletion
return {
    {
        'hrsh7th/nvim-cmp',
        event = "InsertEnter",
        lazy = true,
        dependencies = {
            -- Adds LSP/buffer/path etc. completion capabilities
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-nvim-lsp-signature-help',
            'hrsh7th/cmp-cmdline',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path'
        },
        config = function()
            local cmp = require 'cmp'

            cmp.setup({
                sources = cmp.config.sources({
                    { name = 'nvim_lsp' },
                    { name = 'nvim_lsp_signature_help' },
                    { name = 'buffer' },
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
