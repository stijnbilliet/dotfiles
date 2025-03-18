-- Set lualine as statusline
return {
    {
        'nvim-lualine/lualine.nvim',
        event = "VeryLazy",
        config = function()
            require('lualine').setup {
                options = {
                    icons_enabled = true,
                    theme = 'auto',
                    component_separators = '|',
                    section_separators = '',
                },
                sections = {
                    lualine_a = {'mode'},
                    lualine_b = {'filename'},
                    lualine_c = {'nvim_treesitter#statusline'},
                    lualine_x = {'branch', 'diff'},
                    lualine_y = {'diagnostics'},
                    lualine_z = {'progress', 'location'}
                }
            }
        end
    },
}
