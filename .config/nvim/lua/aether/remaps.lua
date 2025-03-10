local cmp = require 'cmp'
local tscope = require 'telescope.builtin'
local dap = require 'dap'
local dap_ui = require 'dapui'
local dap_ui_widgets = require 'dap.ui.widgets'
local gitsigns = require 'gitsigns'
local atu = require 'aether.utils'

-- Lists of keys for all plugins that we're using
local telescopekeys = {
    {
        key='<CS-F>',
        mode='n',
        func=atu.find_in_files,
        opts={
            desc="Search Files",
        }
    },
    {
        key='<C-;>',
        mode='n',
        func=atu.quick_open,
        opts={
            desc="Quick Open",
        }
    },
    {
        key='<S-Tab>',
        mode='n',
        func=tscope.oldfiles,
        opts={
            desc="Recently opened Files",
        }
    },
    {
        key='<C-Tab>',
        mode={'n', 'c'},
        func=tscope.buffers,
        opts={
            desc="Existing buffers",
        }
    },
    {
        key='<F1>',
        mode='n',
        func=tscope.help_tags,
        opts={
            desc="Search Help",
        }
    },
}

local cmpkeys = {
    {
        key='<C-d>',
        mode={'i', 'c'},
        func=function() cmp.scroll_docs(-4) end,
        opts={
            desc="Scroll docs down",
        }
    },
    {
        key='<C-f>',
        mode={'i', 'c'},
        func=function() cmp.scroll_docs(4) end,
        opts={
            desc="Scroll docs up",
        }
    },
    {
        key='<C-Space>',
        mode={'i', 'c'},
        func=cmp.complete,
        opts={
            desc="Trigger completion",
        }
    },
    --TODO(stijn): Take a look at nvim-mapper to better handle forwarding of fallback keys
    {
        key='<C-e>',
        mode={'i', 'c'},
        func=function() atu.cmp_try_abort({fbkey='<C-e>'}) end,
        opts={
            desc="Abort completion",
        }
    },
    {
        key='<Tab>',
        mode={'i', 'c'},
        func=function() atu.cmp_confirm_selected({fbkey='<Tab>', cmpargs={select = true}}) end,
        opts={
            desc="Autocomplete confirm selected",
        }
    },
    {
        key='<Enter>',
        mode={'i', 'c'},
        func=function() atu.cmp_confirm_selected({fbkey='<Enter>', cmpargs={select = false}}) end,
        opts={
            desc="Autocomplete confirm selected",
        }
    },
    {
        key='<Down>',
        mode={'i', 'c'},
        func=function() atu.cmp_select_next_item({fbkey='<Down>'}) end,
        opts={
            desc="Autocompletions select next item",
        }
    },
    {
        key='<Up>',
        mode={'i', 'c'},
        func=function() atu.cmp_select_prev_item({fbkey='<Up>'}) end,
        opts={
            desc="Autocompletions select prev item",
        }
    },
}

local lspkeys = {
    {
        key='<F2>',
        mode='n',
        func=vim.lsp.buf.rename,
        opts={
            desc="LSP: Rename",
        }
    },
    {
        key='<C-F12>',
        mode='n',
        func=vim.lsp.buf.declaration,
        opts={
            desc="LSP: Goto declaration",
        }
    },
    {
        key='<C-h>',
        mode='n',
        func=vim.lsp.buf.hover,
        opts={
            desc="LSP: Hover",
        }
    },
    {
        key='<C-.>',
        mode='n',
        func=vim.lsp.buf.code_action,
        opts={
            desc="LSP: Code action",
        }
    },
    {
        key='<F12>',
        mode='n',
        func=tscope.lsp_definitions,
        opts={
            desc="LSP: Goto definition",
        }
    },
    {
        key='<S-F12>',
        mode='n',
        func=tscope.lsp_references,
        opts={
            desc="LSP: Goto references",
        }
    },
    {
        key='<C-F12>',
        mode='n',
        func=tscope.lsp_implementations,
        opts={
            desc="LSP: Goto implementations",
        }
    },
    {
        key='<C-,>',
        mode='n',
        func=tscope.lsp_dynamic_workspace_symbols,
        opts={
            desc="LSP: Search Symbols",
        }
    },
    {
        key='<F8>',
        mode='n',
        func=vim.diagnostic.goto_next,
        opts={
            desc="LSP: Goto next error",
        }
    },
    {
        key='<S-F8>',
        mode='n',
        func=vim.diagnostic.goto_prev,
        opts={
            desc="LSP: Goto prev error",
        }
    },
    {
        key='<C-k><C-o>',
        mode='n',
        func=atu.switch_source_header,
        opts={
            desc="LSP: Toggle source/header",
        }
    },
}

local dapkeys = {
    {
        key='<F5>',
        mode='n',
        func=atu.dap_launch,
        opts={
            desc="Continue",
        }
    },
    {
        key='<F10>',
        mode='n',
        func=dap.step_over,
        opts={
            desc="Step Over",
        }
    },
    {
        key='<F11>',
        mode='n',
        func=dap.step_into,
        opts={
            desc="Step Into",
        }
    },
    {
        key='<F9>',
        mode='n',
        func=dap.toggle_breakpoint,
        opts={
            desc="Toggle Breakpoint",
        }
    },
    {
        key='<C-F10>',
        mode='n',
        func=dap.run_to_cursor,
        opts={
            desc="Run to Cursor",
        }
    },
    {
        key='<S-F11>',
        mode='n',
        func=dap.step_out,
        opts={
            desc="Step Out",
        }
    },
    {
        key='<S-F5>',
        mode='n',
        func=dap.terminate,
        opts={
            desc="Terminate",
        }
    },
    {
        key='<leader>dl',
        mode='n',
        func=dap.run_last,
        opts={
            desc="Run Last",
        }
    },
    {
        key='<leader>dp',
        mode='n',
        func=dap.pause,
        opts={
            desc="Pause",
        }
    },
    {
        key='<leader>dw',
        mode='n',
        func=dap_ui_widgets.hover,
        opts={
            desc="Widgets",
        }
    },
}

local dapuikeys = {
    {
        key='<leader>du',
        mode='n',
        func=dap_ui.toggle,
        opts={
            desc="Dap UI",
        }
    },
    {
        key='<leader>de',
        mode={'n','v'},
        func=dap_ui.eval,
        opts={
            desc="Eval",
        }
    },
}

local gitkeys = {
    --Navigation
    {
        key=']c',
        mode='n',
        func=atu.diff_nav_next,
        opts={
            desc="Git: Nav to next diff"
        }
    },
    {
        key='[c',
        mode='n',
        func=atu.diff_nav_prev,
        opts={
            desc="Git: Nav to prev diff"
        }
    },
    --Actions
    {
        key='<leader>hs',
        mode='n',
        func=gitsigns.stage_hunk,
        opts={
            desc="Git: Toggle stage hunk",
        }
    },
    {
        key='<leader>hr',
        mode='n',
        func=gitsigns.reset_hunk,
        opts={
            desc="Git: Reset hunk",
        }
    },
    {
        key='<leader>hs',
        mode='v',
        func=function() gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end,
        opts={
            desc="Git: Toggle stage v-selected hunk",
        }
    },
    {
        key='<leader>hr',
        mode='v',
        func=function() gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end,
        opts={
            desc="Git: Reset v-selected hunk",
        }
    },
    {
        key='<leader>hS',
        mode='n',
        func=gitsigns.stage_buffer,
        opts={
            desc="Git: Toggle stage buffer"
        }
    },
    {
        key='<leader>hR',
        mode='n',
        func=gitsigns.reset_buffer,
        opts={
            desc="Git: Reset hunk"
        }
    },
    {
        key='<leader>hp',
        mode='n',
        func=gitsigns.preview_hunk,
        opts={
            desc="Git: Preview hunk"
        }
    },
    {
        key='<leader>hi',
        mode='n',
        func=gitsigns.preview_hunk_inline,
        opts={
            desc="Git: Preview hunk inline"
        }
    },
    {
        key='<leader>hb',
        mode='n',
        func=function() gitsigns.blame_line({ full = true }) end,
        opts={
            desc="Git: Blame line"
        }
    },
    {
        key='<leader>hD',
        mode='n',
        func=gitsigns.diffthis,
        opts={
            desc="Git: Diff this file"
        }
    },
    {
        key='<leader>hd',
        mode='n',
        func=atu.gitsigns_diff_inline,
        opts={
            desc="Git: Diff this file inline"
        }
    },
    --Text object
    {
        key='ih',
        mode={'o', 'x'},
        func=gitsigns.select_hunk,
        opts={
            desc="Git: Select inner hunk"
        }
    },
}

local nvimkeys = {
    {
        key='<C-`>',
        mode={'n','t'},
        func=atu.toggle_terminal,
        opts={
            desc="Toggle terminal",
        }
    },
    {
        key='n',
        mode='n',
        func="nzz",
        opts={
            desc="Goto next occurence",
        }
    },
    {
        key='N',
        mode='n',
        func="Nzz",
        opts={
            desc="Goto prev occurence",
        }
    },
    {
        key='J',
        mode='n',
        func="mzJ`z",
        opts={
            desc="Join with line below",
        }
    },
    --Navigate around in the quickfix list
    --Try `lua: vim.diagnostic.setqflist()`
    --Or with Telescope pickers <C-q> to add results to qflist
    {
        key='<M-j>',
        mode='n',
        func="<cmd>cnext<CR>",
        opts={
            desc="Goto next in quickfix list",
        }
    },
    {
        key='<M-k>',
        mode='n',
        func="<cmd>cprev<CR>",
        opts={
            desc="Goto prev in quickfix list",
        }
    },
}

local nvidekeys = {
    {
        key={'<C-=>', '<C-kPlus>'},
        mode='n',
        func=function() atu.change_scale_factor(1.25) end,
        opts={
            desc="Scale text up",
        }
    },
    {
        key={'<C-->', '<C-kMinus>'},
        mode='n',
        func=function() atu.change_scale_factor(1/1.25) end,
        opts={
            desc="Scale text down",
        }
    },
}

-- Auto bind lspkeys on lspattach
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(args)
        atu.bind_keyset_buffer(lspkeys, args.buf);
    end,
})

vim.api.nvim_create_autocmd('BufReadPost', {
    group = vim.api.nvim_create_augroup('UserGitSigns', {}),
    callback = function(args)
        atu.bind_keyset_buffer(gitkeys, args.buf);
    end,
})

-- Bind those keysets to vim.keymap
atu.bind_keyset(telescopekeys);
atu.bind_keyset(cmpkeys);
atu.bind_keyset(dapkeys);
atu.bind_keyset(dapuikeys);
atu.bind_keyset(nvimkeys);
if vim.g.neovide then
    atu.bind_keyset(nvidekeys);
end
