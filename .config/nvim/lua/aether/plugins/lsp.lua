-- LSP Configuration
return {
    'neovim/nvim-lspconfig',
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "LspInfo", "LspInstall", "LspUninstall" },
    dependencies = {
        -- Use mason to automically install LSPs
        {
            'mason-org/mason-lspconfig.nvim',
            dependencies = {
                "mason-org/mason.nvim"
            }
        },

        -- Useful status updates for LSP
        'j-hui/fidget.nvim',
    },
    config = function ()
        --- Enable the following language servers
        -- Example configuration:
        -- lua_ls = {
        --      cmd = { ... },
        --      filetypes = { ... },
        --      capabilities = {},
        --      settings = {},
        --      etc...
        -- },
        -- Or leave the table blank for defaults
        local servers = {
            clangd = {
                cmd = { "clangd", "-j=12", "--background-index", "--pch-storage=memory", "--header-insertion=never"},
            },
            rust_analyzer = {},
            pyright = {},
            lua_ls = {
                root_markers = { "init.lua", { '.luarc.json', '.luarc.jsonc' }, '.git' },
            },
            openscad_lsp = {},
        }

        -- Ensure the servers above are installed
        require('mason').setup()
        require('mason-lspconfig').setup({
            ensure_installed = vim.tbl_keys(servers or {})
        })

        -- Apply language server configs

        -- nvim-cmp supports additional completion capabilities, so broadcast that to servers
        local lsp_capabilities = vim.lsp.protocol.make_client_capabilities()
        lsp_capabilities = require('cmp_nvim_lsp').default_capabilities(lsp_capabilities)

        -- Set up global opts
        vim.lsp.config('*', {
            capabilities = lsp_capabilities
        })

        -- Apply our overrides
        for k, opts in pairs(servers) do
            vim.lsp.config(k, opts)
        end
    end
}
