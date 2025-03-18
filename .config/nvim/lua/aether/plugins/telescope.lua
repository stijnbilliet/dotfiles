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
                build = vim.fn.executable("make") == 1 and "make"
                or "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
                cond = function()
                    return vim.fn.executable("make") == 1 or vim.fn.executable("cmake") == 1
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
