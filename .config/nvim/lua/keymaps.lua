local cmp = require 'cmp'
local telescope_ns = require 'telescope.builtin'
local dap = require 'dap'
local dap_ui = require 'dapui'
local dap_ui_widgets = require 'dap.ui.widgets'

-- Helper functions for key binding
-- TODO(stijn): some of these would be candidates to move to a util.lua
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

local function feedkeys(keys, mode)
	vim.api.nvim_feedkeys(
		vim.api.nvim_replace_termcodes(keys, true, true, true),
		mode,
		false
	);
end

local function dap_launch()
    if vim.fn.filereadable('.vscode/launch.json') then
        require('dap.ext.vscode').load_launchjs(nil, {});
    end
    dap.continue();
end

local function cmp_luasnip_select_next_item()
    local luasnip = require 'luasnip'
    if cmp.visible() then
       cmp.select_next_item({ behavior = cmp.SelectBehavior.Select });
    elseif luasnip.expand_or_locally_jumpable() then
       luasnip.expand_or_jump();
    else
       feedkeys('<Tab>', 'ni');
    end
end

local function cmp_luasnip_select_prev_item()
    local luasnip = require 'luasnip'
    if cmp.visible() then
        cmp.select_prev_item()
    elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
    else
       feedkeys('<S-Tab>', 'ni');
    end
end

local function cmp_try_confirm()
    if not cmp.confirm({ select = false }) then
        feedkeys('<CR>', 'ni'); -- fallback
    end
end

-- Lists of keys for all plugins that we're using
--
local telescopekeys = {
    { key='<leader>?',          mode='n',           func=telescope_ns.oldfiles,             opts={ desc='[?] Find recently opened files' } },
    { key='<leader><space>',    mode='n',           func=telescope_ns.buffers,              opts={ desc='[ ] Find existing buffers' } },
    { key='<leader>sf',         mode='n',           func=telescope_ns.find_files,           opts={ desc='[S]earch [F]iles' } },
    { key='<leader>sh',         mode='n',           func=telescope_ns.help_tags,            opts={ desc='[S]earch [H]elp' } },
    { key='<leader>sw',         mode='n',           func=telescope_ns.grep_string,          opts={ desc='[S]earch current [W]ord' } },
    { key='<leader>sg',         mode='n',           func=telescope_ns.live_grep,            opts={ desc='[S]earch by [G]rep' } },
}

local cmpkeys = {
    { key='<C-d>',              mode='i',           func=cmp.mapping.scroll_docs(-4),       opts={} },
    { key='<C-f>',              mode='i',           func=cmp.mapping.scroll_docs(4),        opts={} },
    { key='<C-Space>',          mode={'i', 'v'},    func=cmp.mapping.complete,              opts={} },
    { key='<CR>',               mode={'i', 'v'},    func=cmp_try_confirm,                   opts={} },
    { key='<Tab>',              mode={'i', 'v'},    func=cmp_luasnip_select_next_item,      opts={} },
    { key='<Down>',             mode={'i', 'v'},    func=cmp_luasnip_select_next_item,      opts={} },
    { key='<S-Tab>',            mode={'i', 'v'},    func=cmp_luasnip_select_prev_item,      opts={} },
    { key='<Up>',               mode={'i', 'v'},    func=cmp_luasnip_select_prev_item,      opts={} },
}

local lspkeys = {
    { key='<F2>',               mode='n',           func=vim.lsp.buf.rename,                opts={ desc='Rename'} },
    { key='<C-F12>',            mode='n',           func=vim.lsp.buf.declaration,           opts={ desc='Goto declaration'} },
    { key='<F12>',              mode='n',           func=telescope_ns.lsp_definitions,      opts={ desc='Goto definition'} },
    { key='<S-F12>',            mode='n',           func=telescope_ns.lsp_references,       opts={ desc='Goto references'} },
    { key='<C-F12>',            mode='n',           func=telescope_ns.lsp_implementations,  opts={ desc='Goto implementations'} },
}

local dapkeys = {
    { key='<F5>',               mode='n',           func=dap_launch,                        opts={ desc = "Continue" } },
    { key='<F10>',              mode='n',           func=dap.step_over,                     opts={ desc = "Step Over" } },
    { key='<F11>',              mode='n',           func=dap.step_into,                     opts={ desc = "Step Into" } },
    { key='<F9>',               mode='n',           func=dap.toggle_breakpoint,             opts={ desc = "Toggle Breakpoint" } },
    { key='<C-F10>',            mode='n',           func=dap.run_to_cursor,                 opts={ desc = "Run to Cursor" } },
    { key='<S-F11>',            mode='n',           func=dap.step_out,                      opts={ desc = "Step Out" } },
    { key='<S-F5>',             mode='n',           func=dap.terminate,                     opts={ desc = "Terminate" } },
    { key='<leader>dl',         mode='n',           func=dap.run_last,                      opts={ desc = "Run Last" } },
    { key='<leader>dp',         mode='n',           func=dap.pause,                         opts={ desc = "Pause" } },
    { key='<leader>dw',         mode='n',           func=dap_ui_widgets.hover,              opts={ desc = "Widgets" } },
}

local dapuikeys = {
    { key='<leader>du',         mode = 'n',             func=dap_ui.toggle,                    pts={desc = "Dap UI" }},
    { key='<leader>de',         mode = {'n', 'v'},      func=dap_ui.eval,                      pts={desc = "Eval"} },
}

-- Auto bind lspkeys on lspattach
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        bind_keyset_buffer(lspkeys, ev.buf);
    end,
})

-- Bind those keysets to vim.keymap
--
bind_keyset(telescopekeys);
bind_keyset(cmpkeys);
bind_keyset(dapkeys);
bind_keyset(dapuikeys);
