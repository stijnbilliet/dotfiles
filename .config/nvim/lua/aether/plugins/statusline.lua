-- Set lualine as statusline
return {
    {
        'nvim-lualine/lualine.nvim',
        event = "VeryLazy",
        opts = {
            options = {
                icons_enabled = false,
                theme = 'auto',
                component_separators = '|',
                section_separators = '',
            },
        },
    },
}
