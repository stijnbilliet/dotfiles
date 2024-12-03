local cmp = require 'cmp'
local tscope = require 'telescope.builtin'
local dap = require 'dap'
local dap_ui = require 'dapui'
local dap_ui_widgets = require 'dap.ui.widgets'

-- Lists of keys for all plugins that we're using
--
local telescopekeys = {
    { key='<C-F>',      mode='n',       func=tscope.live_grep,                     opts={desc='Search Files'}},
    { key='<C-;>',      mode='n',       func=quick_open,                           opts={desc='Quick Open'}},
    { key='<C-Tab>',    mode='n',       func=tscope.oldfiles,                      opts={desc='Recently opened Files'}},
    { key='<S-Tab>',    mode='n',       func=tscope.buffers,                       opts={desc='Existing buffers'}},
    { key='<F1>',       mode='n',       func=tscope.help_tags,                     opts={desc='Search Help'}},
}

-- TODO(stijn): might want to swap tab to just do autocomplete as well
local cmpkeys = {
    { key='<C-d>',      mode='i',       func=cmp.mapping.scroll_docs(-4),          opts={} },
    { key='<C-f>',      mode='i',       func=cmp.mapping.scroll_docs(4),           opts={} },
    { key='<C-Space>',  mode={'i'},     func=cmp.mapping.complete,                 opts={} },
    { key='<CR>',       mode={'i','v'}, func=cmp_try_confirm,                      opts={} },
    { key='<Tab>',      mode={'i','v'}, func=cmp_luasnip_select_next_item,         opts={} },
    { key='<Down>',     mode={'i','v'}, func=cmp_luasnip_select_next_item,         opts={} },
    { key='<S-Tab>',    mode={'i','v'}, func=cmp_luasnip_select_prev_item,         opts={} },
    { key='<Up>',       mode={'i','v'}, func=cmp_luasnip_select_prev_item,         opts={} },
}

local lspkeys = {
    { key='<F2>',       mode='n',       func=vim.lsp.buf.rename,                   opts={desc='Rename'}},
    { key='<C-F12>',    mode='n',       func=vim.lsp.buf.declaration,              opts={desc='Goto declaration'}},
    { key='<C-h>',      mode='n',       func=vim.lsp.buf.hover,                    opts={desc='Hover'}},
    { key='<F12>',      mode='n',       func=tscope.lsp_definitions,               opts={desc='Goto definition'}},
    { key='<S-F12>',    mode='n',       func=tscope.lsp_references,                opts={desc='Goto references'}},
    { key='<C-F12>',    mode='n',       func=tscope.lsp_implementations,           opts={desc='Goto implementations'}},
    { key='<C-,>',      mode='n',       func=tscope.lsp_dynamic_workspace_symbols, opts={desc='Search Symbols'}},
    { key='<F8>',       mode='n',       func=vim.diagnostic.goto_next,             opts={desc='Goto next error'}},
    { key='<S-F8>',     mode='n',       func=vim.diagnostic.goto_prev,             opts={desc='Goto prev error'}},
}

local dapkeys = {
    { key='<F5>',       mode='n',       func=dap_launch,                           opts={desc="Continue"}},
    { key='<F10>',      mode='n',       func=dap.step_over,                        opts={desc="Step Over"}},
    { key='<F11>',      mode='n',       func=dap.step_into,                        opts={desc="Step Into"}},
    { key='<F9>',       mode='n',       func=dap.toggle_breakpoint,                opts={desc="Toggle Breakpoint"}},
    { key='<C-F10>',    mode='n',       func=dap.run_to_cursor,                    opts={desc="Run to Cursor"}},
    { key='<S-F11>',    mode='n',       func=dap.step_out,                         opts={desc="Step Out"}},
    { key='<S-F5>',     mode='n',       func=dap.terminate,                        opts={desc="Terminate"}},
    { key='<leader>dl', mode='n',       func=dap.run_last,                         opts={desc="Run Last"}},
    { key='<leader>dp', mode='n',       func=dap.pause,                            opts={desc="Pause"}},
    { key='<leader>dw', mode='n',       func=dap_ui_widgets.hover,                 opts={desc="Widgets"}},
}

local dapuikeys = {
    { key='<leader>du', mode='n',       func=dap_ui.toggle,                        opts={desc="Dap UI"}},
    { key='<leader>de', mode={'n','v'}, func=dap_ui.eval,                          opts={desc="Eval"}},
}

local nvimkeys = {
    { key='<C-`>',      mode={'n','t'}, func=toggle_terminal,                      opts={desc="Toggle terminal"}},
    { key='n',          mode={'n'},     func="nzz",                                opts={desc="Goto next occurence"}},
    { key='N',          mode={'n'},     func="Nzz",                                opts={desc="Goto prev occurence"}},
    { key='J',          mode={'n'},     func="mzJ`z",                              opts={desc="Join with line below"}},
}

local nvidekeys = {
    { key='<C-=>',      mode={'n'},     func=scale_text_up,                       opts={desc="Scale text up"}},
    { key='<C-->',      mode={'n'},     func=scale_text_down,                     opts={desc="Scale text down"}},
}

-- Helper functions for keyset (table of keys) bulk binding
local function bind_keyset(keyset)
    for _, entry in ipairs(keyset) do
        vim.keymap.set(entry.mode, entry.key, entry.func, entry.opts)
    end
end

local function bind_keyset_buffer(keyset, buffnr)
    for _, entry in ipairs(keyset) do
        local opts = entry.opts;
        opts.buffer = buffnr;
        vim.keymap.set(entry.mode, entry.key, entry.func, opts);
    end
end

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
