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
                clangd = {
                    cmd = { "clangd", "--background-index", "--suggest-missing-includes", "--clang-tidy", "--header-insertion=iwyu", "--ferror-limit=0" },
                },
                rust_analyzer = {},
                pyright = {
                    python = {
                        analysis = {
                            autoSearchPaths = true,
                            diagnosticMode = "openFilesOnly",
                            useLibraryCodeForTypes = true
                        }
                    }
                },
                lua_ls = {
                  Lua = {
                    workspace = { checkThirdParty = false },
                    telemetry = { enable = false },
                  },
                },
                openscad_lsp = {
                    cmd = { "openscad-lsp", "--stdio" },
                    filetypes = { "openscad" }
                },
                gdscript = {

                }
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
