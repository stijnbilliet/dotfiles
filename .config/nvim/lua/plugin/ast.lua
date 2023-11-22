-- Install treesitter
return {
  {
    -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
    },
    build = ':TSUpdate',
    config = function ()
        require('nvim-treesitter.configs').setup({
            -- Add languages to be installed here that you want installed for treesitter
            ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'vimdoc', 'vim', 'bash' },

            -- Install parsers synchronously (only applied to `ensure_installed`)
            sync_install = false,

            -- Automatically install missing parsers when entering buffer
            -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
            auto_install = false,

            -- List of parsers to ignore installing (or "all")
            ignore_install = {},

            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },

            modules = {},
        })
    end
  },
}
