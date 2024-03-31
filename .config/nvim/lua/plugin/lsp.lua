  -- LSP Configuration & Plugins
  return {
      {
        'neovim/nvim-lspconfig',
        dependencies = {
          -- Use mason to automically install LSPs
          'williamboman/mason.nvim',
          'williamboman/mason-lspconfig.nvim',

          -- Useful status updates for LSP
          { 'j-hui/fidget.nvim', opts = {} },

          -- Additional lua configuration, makes nvim stuff amazing!
          'folke/neodev.nvim',
        },
        config = function ()
            -- mason-lspconfig requires that these setup functions are called in this order
            -- before setting up the servers.
            require('mason').setup()
            require('mason-lspconfig').setup()

            -- Setup neovim lua configuration
            require('neodev').setup()

            -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

            -- Enable the following language servers
            local servers = {
              clangd = {},
              rust_analyzer = {},
              -- gopls = {},
              -- tsserver = {},
              -- html = { filetypes = { 'html', 'twig', 'hbs'} },

              lua_ls = {
                Lua = {
                  workspace = { checkThirdParty = false },
                  telemetry = { enable = false },
                },
              },
            }

            -- Ensure the servers above are installed
            local mason_lspconfig = require 'mason-lspconfig'

            mason_lspconfig.setup {
              ensure_installed = vim.tbl_keys(servers),
            }

            mason_lspconfig.setup_handlers {
              function(server_name)
                require('lspconfig')[server_name].setup {
                  capabilities = capabilities,
                  settings = servers[server_name],
                  filetypes = (servers[server_name] or {}).filetypes,
                }
              end,
            }
        end
      }
  }
