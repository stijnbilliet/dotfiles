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
              -- clangd = {},
              -- gopls = {},
              -- pyright = {},
              -- rust_analyzer = {},
              -- tsserver = {},
              -- html = { filetypes = { 'html', 'twig', 'hbs'} },

              lua_ls = {
                Lua = {
                  workspace = { checkThirdParty = false },
                  telemetry = { enable = false },
                },
              },
            }

            --  Gets run when an LSP connects to a particular buffer, set the mode, buffer and description
            local on_attach = function(_, bufnr)
              local nmap = function(keys, func, desc)
                if desc then
                  desc = 'LSP: ' .. desc
                end
                vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
              end

              -- TODO(stijn): move these remaps to keymaps.lua
              nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

              nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
              nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
              nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
              nmap('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
            end

            -- Ensure the servers above are installed
            local mason_lspconfig = require 'mason-lspconfig'

            mason_lspconfig.setup {
              ensure_installed = vim.tbl_keys(servers),
            }

            mason_lspconfig.setup_handlers {
              function(server_name)
                require('lspconfig')[server_name].setup {
                  capabilities = capabilities,
                  on_attach = on_attach,
                  settings = servers[server_name],
                  filetypes = (servers[server_name] or {}).filetypes,
                }
              end,
            }
        end
      }
  }
