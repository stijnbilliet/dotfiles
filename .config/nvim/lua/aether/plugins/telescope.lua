-- Fuzzy Finder (files, lsp, etc)
return {
    'nvim-telescope/telescope.nvim',
    tag = 'v0.1.9',
    event='VeryLazy',
    dependencies = {
        'nvim-lua/plenary.nvim',
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "cmake -S . -B build -D CMAKE_BUILD_TYPE=Release && cmake --build build --config Release --target install",
        }
    },
    config = function()
        local telescope = require("telescope");

        telescope.setup({})

        -- Enable telescope fzf native, if installed
        telescope.load_extension('fzf')
    end
}
