-- Set lualine as statusline
return {
    'nvim-lualine/lualine.nvim',
    event = "VeryLazy",
    config = function()
        require('lualine').setup {
            options = {
                section_separators = '', --override default of chevrons
            },
            sections = {
                lualine_a = {'mode'},
                lualine_b = {'filename'},
                lualine_c = {'nvim_treesitter#statusline'},
                lualine_x = {'diagnostics'},
                lualine_y = {'branch', 'diff'},
                lualine_z = {'progress', 'location'}
            }
        }
    end
}
