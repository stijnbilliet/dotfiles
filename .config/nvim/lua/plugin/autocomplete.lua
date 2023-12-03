-- Autocompletion
local function cmp_generate_mapping()
    local keymap = require 'keymaps'
    local luacmpmapping = {}
    for _, v in ipairs(keymap.mapping.luacmp) do
        if type(v.opts) ~= "table" or next(v.opts) ~= nil then
            luacmpmapping[v.key] = v.func(v.opts);
        else
            luacmpmapping[v.key] = v.func();
        end
    end
    return luacmpmapping;
end

return {
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',
    },
    config = function()
        local cmp = require 'cmp'
        local luasnip = require 'luasnip'
        require('luasnip.loaders.from_vscode').lazy_load()
        luasnip.config.setup {}

        cmp.setup {
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end,
          },
          completion = {
            completeopt = 'menu,menuone,noinsert',
          },
          sources = {
            { name = 'nvim_lsp' },
            { name = 'luasnip' },
          },
          mapping = cmp.mapping.preset.insert(cmp_generate_mapping()),
        }
    end
  },
}
