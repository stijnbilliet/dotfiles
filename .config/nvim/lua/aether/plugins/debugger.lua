return {
    -- dap and friends
    {
        "mfussenegger/nvim-dap",
        event='VeryLazy',
        dependencies = {
            "rcarriga/nvim-dap-ui", -- debugger ui
            "theHamsta/nvim-dap-virtual-text", -- virtual text for the debugger
            "nvim-neotest/nvim-nio",
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")
            local dapvt = require("nvim-dap-virtual-text")

            dapui.setup()
            dapvt.setup()

            -- Automatically open dapui when debugging is started.
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open({})
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close({})
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close({})
            end
        end,
    },
    -- mason.nvim integration
    {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = "mason.nvim",
        cmd = { "DapInstall", "DapUninstall" },
        opts = {
            -- Makes a best effort to setup the various debuggers with reasonable defaults
            automatic_installation = true,

            -- You can provide additional configuration to the handlers,
            -- see mason-nvim-dap README for more information
            handlers = {},

            -- Note(stijn): You'll also want to ensure you have the
            -- relevant adapters installed on your system.
            ensure_installed = {
                "codelldb",
                "debugpy",
            },
        },
    },
}
