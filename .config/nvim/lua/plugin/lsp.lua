  -- LSP Configuration & Plugins
  return {
      {
        'neovim/nvim-lspconfig',
        event = { "BufReadPost", "BufNewFile" },
        cmd = { "LspInfo", "LspInstall", "LspUninstall" },
        dependencies = {
          -- Use mason to automically install LSPs
          'williamboman/mason.nvim',
          'williamboman/mason-lspconfig.nvim',
          'WhoIsSethDaniel/mason-tool-installer.nvim',

          -- Useful status updates for LSP
          { 'j-hui/fidget.nvim', opts = {} },

          -- Additional lua configuration, makes nvim stuff amazing!
          'folke/neodev.nvim',
        },
        config = function ()
            -- mason-lspconfig requires that these setup functions are called in this order
            -- before setting up the servers.
            require('mason-lspconfig').setup()

            -- Setup neovim lua configuration
            require('neodev').setup()

            -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

            -- Enable the following language servers
            -- Example configuration:
            -- lua_ls = {
                -- cmd = { ... },
                -- filetypes = { ... },
                -- capabilities = {},
                -- settings = {},
            -- },
            -- Or leave the table blank for defaults
            local servers = {
                clangd = {
                    cmd = { "clangd", "--background-index", "--suggest-missing-includes", "--clang-tidy", "--header-insertion=iwyu", "--ferror-limit=0" },
                },
                rust_analyzer = {},
                pyright = {},
                lua_ls = {},
                openscad_lsp = {},
                gdtoolkit = {}, --Godot gdscript
            }

            -- Set up mason (to install language servers etc.)
            require('mason').setup()

            -- Ensure the servers above are installed
            local ensure_installed = vim.tbl_keys(servers or {})
            require('mason-tool-installer').setup { ensure_installed = ensure_installed }

            -- Set up language servers installed through mason
            require 'mason-lspconfig'.setup {
              handlers = {
                    function(server_name)
                        local server = servers[server_name] or {}
                        -- This handles overriding only values explicitly passed
                        -- by the server configuration above. Useful when disabling
                        -- certain features of an LSP
                        server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
                        require('lspconfig')[server_name].setup(server)
                    end,
                },
            }
        end
      }
  }
