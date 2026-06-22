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
                lualine_c = {
                    function()
                        local clients = vim.lsp.get_clients({ bufnr = 0 })
                        return #clients > 0 and clients[1].name or ''
                    end,
                },
                lualine_x = {'diagnostics'},
                lualine_y = {'branch', 'diff'},
                lualine_z = {'progress', 'location'}
            }
        }
    end
}
