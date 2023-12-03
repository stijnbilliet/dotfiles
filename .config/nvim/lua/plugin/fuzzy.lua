-- Fuzzy Finder (files, lsp, etc)
return {
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
        local telescope = require("telescope");
        telescope.setup({})
        -- Enable telescope fzf native, if installed
        pcall(telescope.load_extension, 'fzf')

    end
  },
}

