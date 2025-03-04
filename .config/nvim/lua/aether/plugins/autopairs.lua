-- Install autopairs
return {
    {
        -- Enables automatic pairing of multiple characters
        -- i.e. "", '', {}, (), etc.
        'windwp/nvim-autopairs',
        event = { "InsertEnter" },
        dependencies = {
            'hrsh7th/nvim-cmp',
        },
        config = function ()
            require('nvim-autopairs').setup{
                enable_ts = true, --enable treesitter support
            }

            local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
            local cmp = require 'cmp'
            cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
        end
    },
}
