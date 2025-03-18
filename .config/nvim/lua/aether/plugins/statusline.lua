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
                    lualine_b = {'branch', 'diff'},
                    lualine_c = {'filename'},
                    lualine_x = {'nvim_treesitter#statusline'},
                    lualine_y = {'filetype'},
                    lualine_z = {'progress', 'location'}
                }
            }
        end
    },
}
