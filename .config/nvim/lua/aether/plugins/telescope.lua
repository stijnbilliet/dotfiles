-- Fuzzy Finder (files, lsp, etc)
return {
    'nvim-telescope/telescope.nvim',
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

        telescope.setup({
            defaults = {
                mappings = {
                    i = {
                        ['<C-j>'] = false,
                    },
                },
            }
        })

        -- Enable telescope fzf native, if installed
        telescope.load_extension('fzf')
    end
}
