-- Fuzzy Finder (files, lsp, etc)
return {
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
        require("telescope").setup({})
        -- Enable telescope fzf native, if installed
        pcall(require('telescope').load_extension, 'fzf')
    end
  },
}
