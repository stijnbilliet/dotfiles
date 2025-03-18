-- Fuzzy Finder (files, lsp, etc)
return {
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        event='VeryLazy',
        dependencies = {
            { 'nvim-lua/plenary.nvim' },
            {
                "nvim-telescope/telescope-fzf-native.nvim",
                build = 'cmake',
                cond = function()
                    return vim.fn.executable("cmake") == 1
                end,
            }
        },
        config = function()
            local telescope = require("telescope");
            telescope.setup({})
            -- Enable telescope fzf native, if installed
            pcall(telescope.load_extension, 'fzf');
        end
    },
}
