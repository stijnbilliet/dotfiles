local cmp = require 'cmp'
local tscope = require 'telescope.builtin'
local dap = require 'dap'
local dap_ui = require 'dapui'
local dap_ui_widgets = require 'dap.ui.widgets'

-- Vars
local cmp_confirm = function() cmp_try_confirm('<Tab>') end
local cmp_select_next = function() cmp_luasnip_select_next_item('<Down>') end
local cmp_select_prev = function() cmp_luasnip_select_prev_item('<Up>') end

-- Lists of keys for all plugins that we're using
local telescopekeys = {
    {
        key='<CS-F>',
        mode='n',
        func=find_in_files,
        opts={
            desc='Search Files'
        }
    },
    {
        key='<C-;>',
        mode='n',
        func=quick_open,
        opts={
            desc='Quick Open'
        }
    },
    {
        key='<S-Tab>',
        mode='n',
        func=tscope.oldfiles,
        opts={
            desc='Recently opened Files'
        }
    },
    {
        key='<C-Tab>',
        mode='n',
        func=tscope.buffers,
        opts={
            desc='Existing buffers'
        }
    },
    {
        key='<F1>',
        mode='n',
        func=tscope.help_tags,
        opts={
            desc='Search Help'
        }
    },
}

local cmpkeys = {
    {
        key='<C-d>',
        mode={'i', 'c'},
        func=cmp.mapping.scroll_docs(-4),
        opts={
        }
    },
    {
        key='<C-f>',
        mode={'i', 'c'},
        func=cmp.mapping.scroll_docs(4),
        opts={
        }
    },
    {
        key='<C-Space>',
        mode={'i', 'c'},
        func=cmp.mapping.complete,
        opts={
            desc='Trigger completion'
        }
    },
    {
        key='<Tab>',
        mode={'i', 'c'},
        func=cmp_confirm,
        opts={
        }
    },
    {
        key='<Down>',
        mode='i',
        func=cmp_select_next,
        opts={
        }
    },
    {
        key='<Up>',
        mode='i',
        func=cmp_select_prev,
        opts={
        }
    },
}

local lspkeys = {
    {
        key='<F2>',
        mode='n',
        func=vim.lsp.buf.rename,
        opts={
            desc='Rename'
        }
    },
    {
        key='<C-F12>',
        mode='n',
        func=vim.lsp.buf.declaration,
        opts={
            desc='Goto declaration'
        }
    },
    {
        key='<C-h>',
        mode='n',
        func=vim.lsp.buf.hover,
        opts={
            desc='Hover'
        }
    },
    {
        key='<F12>',
        mode='n',
        func=tscope.lsp_definitions,
        opts={
            desc='Goto definition'
        }
    },
    {
        key='<S-F12>',
        mode='n',
        func=tscope.lsp_references,
        opts={
            desc='Goto references'
        }
    },
    {
        key='<C-F12>',
        mode='n',
        func=tscope.lsp_implementations,
        opts={
            desc='Goto implementations'
        }
    },
    {
        key='<C-,>',
        mode='n',
        func=tscope.lsp_dynamic_workspace_symbols,
        opts={
            desc='Search Symbols'
        }
    },
    {
        key='<F8>',
        mode='n',
        func=vim.diagnostic.goto_next,
        opts={
            desc='Goto next error'
        }
    },
    {
        key='<S-F8>',
        mode='n',
        func=vim.diagnostic.goto_prev,
        opts={
            desc='Goto prev error'
        }
    },
    {
        key='<C-k><C-o>',
        mode='n',
        func=switch_source_header,
        opts={
            desc='Toggle source/header'
        }
    },
}

local dapkeys = {
    {
        key='<F5>',
        mode='n',
        func=dap_launch,
        opts={
            desc="Continue"
        }
    },
    {
        key='<F10>',
        mode='n',
        func=dap.step_over,
        opts={
            desc="Step Over"
        }
    },
    {
        key='<F11>',
        mode='n',
        func=dap.step_into,
        opts={
            desc="Step Into"
        }
    },
    {
        key='<F9>',
        mode='n',
        func=dap.toggle_breakpoint,
        opts={
            desc="Toggle Breakpoint"
        }
    },
    {
        key='<C-F10>',
        mode='n',
        func=dap.run_to_cursor,
        opts={
            desc="Run to Cursor"
        }
    },
    {
        key='<S-F11>',
        mode='n',
        func=dap.step_out,
        opts={
            desc="Step Out"
        }
    },
    {
        key='<S-F5>',
        mode='n',
        func=dap.terminate,
        opts={
            desc="Terminate"
        }
    },
    {
        key='<leader>dl',
        mode='n',
        func=dap.run_last,
        opts={
            desc="Run Last"
        }
    },
    {
        key='<leader>dp',
        mode='n',
        func=dap.pause,
        opts={
            desc="Pause"
        }
    },
    {
        key='<leader>dw',
        mode='n',
        func=dap_ui_widgets.hover,
        opts={
            desc="Widgets"
        }
    },
}

local dapuikeys = {
    {
        key='<leader>du',
        mode='n',
        func=dap_ui.toggle,
        opts={
            desc="Dap UI"
        }
    },
    {
        key='<leader>de',
        mode={'n','v'},
        func=dap_ui.eval,
        opts={
            desc="Eval"
        }
    },
}

local nvimkeys = {
    {
        key='<C-`>',
        mode={'n','t'},
        func=toggle_terminal,
        opts={
            desc="Toggle terminal"
        }
    },
    {
        key='n',
        mode='n',
        func="nzz",
        opts={
            desc="Goto next occurence"
        }
    },
    {
        key='N',
        mode='n',
        func="Nzz",
        opts={
            desc="Goto prev occurence"
        }
    },
    {
        key='J',
        mode='n',
        func="mzJ`z",
        opts={
            desc="Join with line below"
        }
    },
}

local nvidekeys = {
    {
        key='<C-=>',
        mode='n',
        func=scale_text_up,
        opts={
            desc="Scale text up"
        }
    },
    {
        key='<C-->',
        mode='n',
        func=scale_text_down,
        opts={
            desc="Scale text down"
        }
    },
}

-- Auto bind lspkeys on lspattach
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        bind_keyset_buffer(lspkeys, ev.buf);
    end,
})

-- Bind those keysets to vim.keymap
bind_keyset(telescopekeys);
bind_keyset(cmpkeys);
bind_keyset(dapkeys);
bind_keyset(dapuikeys);
bind_keyset(nvimkeys);
if vim.g.neovide then
    bind_keyset(nvidekeys);
end
