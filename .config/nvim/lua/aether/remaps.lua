local cmp = require 'cmp'
local tscope = require 'telescope.builtin'
local dap = require 'dap'
local dap_ui = require 'dapui'
local dap_ui_widgets = require 'dap.ui.widgets'
local gitsigns = require 'gitsigns'
local atu = require 'aether.utils'

-- Lists of keys for all plugins that we're using
local keymap = {
    ['Nvim'] = {
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
        --Usage: e.g. Telescope pickers <C-q> to add results to qflist
        {
            key='<leader>qd',
            mode='n',
            func=vim.diagnostic.setqflist,
            opts={
                desc="[Q]uickfix list - [D]iagnostics",
            }
        },
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
    },

    ["TScope"] = {
        {
            key={'<CS-F>', '<leader>sif'},
            mode='n',
            func=atu.find_in_files,
            opts={
                desc="[s]earch [i]n [f]iles",
            }
        },
        {
            key={'<C-;>', '<leader>sd'},
            mode='n',
            func=atu.quick_open,
            opts={
                desc="[s]earch [d]ir",
            }
        },
        {
            key={'<S-Tab>', '<leader>so'},
            mode='n',
            func=tscope.oldfiles,
            opts={
                desc="[s]earch [o]ld files",
            }
        },
        {
            key={'<C-Tab>', '<leader>sb'},
            mode='n',
            func=tscope.buffers,
            opts={
                desc="[s]earch [b]uffers",
            }
        },
        {
            key={'<F1>', '<leader>sh'},
            mode='n',
            func=tscope.help_tags,
            opts={
                desc="[s]earch [h]elp",
            }
        },
    },

    ['Cmp'] = {
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
        {
            key='<C-e>',
            mode={'i', 'c'},
            func=function() atu.cmp_try_abort() end,
            opts={
                desc="Abort completion",
            }
        },
        --TODO(stijn): Take a look at nvim-mapper to better handle forwarding of fallback keys
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
            key={'<C-j>'},
            mode={'i', 'c'},
            func=atu.cmp_select_next_item,
            opts={
                desc="Autocompletions select next item",
            }
        },
        {
            key={'<C-k>'},
            mode={'i', 'c'},
            func=atu.cmp_select_prev_item,
            opts={
                desc="Autocompletions select prev item",
            }
        },
    },

    ['Lsp'] = {
        {
            key='<F2>',
            mode='n',
            func=vim.lsp.buf.rename,
            opts={
                desc="Rename",
            }
        },
        {
            key='<F3>',
            mode='n',
            func=vim.lsp.buf.format,
            opts={
                desc="Buffer format",
            }
        },
        {
            key='<C-F12>',
            mode='n',
            func=vim.lsp.buf.declaration,
            opts={
                desc="Goto declaration",
            }
        },
        {
            key='<C-h>',
            mode='n',
            func=vim.lsp.buf.hover,
            opts={
                desc="Hover",
            }
        },
        {
            key='<C-.>',
            mode='n',
            func=vim.lsp.buf.code_action,
            opts={
                desc="Code action",
            }
        },
        {
            key='<F12>',
            mode='n',
            func=tscope.lsp_definitions,
            opts={
                desc="Goto definition",
            }
        },
        {
            key='<S-F12>',
            mode='n',
            func=tscope.lsp_references,
            opts={
                desc="Goto references",
            }
        },
        {
            key='<C-F12>',
            mode='n',
            func=tscope.lsp_implementations,
            opts={
                desc="Goto implementations",
            }
        },
        {
            key='<C-,>',
            mode='n',
            func=tscope.lsp_dynamic_workspace_symbols,
            opts={
                desc="Search Symbols",
            }
        },
        {
            key='<F8>',
            mode='n',
            func=vim.diagnostic.goto_next,
            opts={
                desc="Goto next error",
            }
        },
        {
            key='<S-F8>',
            mode='n',
            func=vim.diagnostic.goto_prev,
            opts={
                desc="Goto prev error",
            }
        },
        {
            key='<C-k><C-o>',
            mode='n',
            func=atu.switch_source_header,
            opts={
                desc="Toggle source/header",
            }
        },
    },

    ['Dap'] = {
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
        {
            key='<leader>du',
            mode='n',
            func=dap_ui.toggle,
            opts={
                desc="Toggle ui",
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
    },

    ['Git'] = {
        --Navigation
        {
            key=']c',
            mode='n',
            func=atu.diff_nav_next,
            opts={
                desc="Nav to next diff"
            }
        },
        {
            key='[c',
            mode='n',
            func=atu.diff_nav_prev,
            opts={
                desc="Nav to prev diff"
            }
        },
        --Actions
        {
            key='<leader>hs',
            mode='n',
            func=gitsigns.stage_hunk,
            opts={
                desc="[h]unk [s]tage",
            }
        },
        {
            key='<leader>hs',
            mode='v',
            func=function() gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end,
            opts={
                desc="[h]unk [s]tage",
            }
        },
        {
            key='<leader>hr',
            mode='n',
            func=gitsigns.reset_hunk,
            opts={
                desc="[h]unk [r]eset",
            }
        },
        {
            key='<leader>hr',
            mode='v',
            func=function() gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end,
            opts={
                desc="[h]unk [r]eset",
            }
        },
        {
            key='<leader>hsb',
            mode='n',
            func=gitsigns.stage_buffer,
            opts={
                desc="[h]unk [s]tage [b]uffer"
            }
        },
        {
            key='<leader>hrb',
            mode='n',
            func=gitsigns.reset_buffer,
            opts={
                desc="[h]unk [r]eset [b]uffer"
            }
        },
        {
            key='<leader>hp',
            mode='n',
            func=gitsigns.preview_hunk,
            opts={
                desc="[h]unk [p]review"
            }
        },
        {
            key='<leader>hpi',
            mode='n',
            func=gitsigns.preview_hunk_inline,
            opts={
                desc="[h]unk [p]review [i]nline"
            }
        },
        {
            key='<leader>hb',
            mode='n',
            func=function() gitsigns.blame_line({ full = true }) end,
            opts={
                desc="[h]unk [b]lame"
            }
        },
        {
            key='<leader>hds',
            mode='n',
            func=gitsigns.diffthis,
            opts={
                desc="[h]unk [d]iff [s]plit"
            }
        },
        {
            key='<leader>hd',
            mode='n',
            func=atu.gitsigns_diff_inline,
            opts={
                desc="[h]unk [d]iff"
            }
        },
        --Text object
        {
            key='ih',
            mode={'o', 'x'},
            func=gitsigns.select_hunk,
            opts={
                desc="select [i]nner [h]unk"
            }
        },
    },

    ['Neovide'] = {
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
}

-- Auto bind lspkeys on lspattach
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(args)
        atu.bind_keyset_buffer(keymap, 'Lsp', args.buf);
    end,
})

-- Auto bind gitsigns keys on buffer read
vim.api.nvim_create_autocmd('BufReadPost', {
    group = vim.api.nvim_create_augroup('UserGitKeys', {}),
    callback = function(args)
        atu.bind_keyset_buffer(keymap, 'Git', args.buf);
    end,
})

-- Bind those keysets to vim.keymap
atu.bind_keyset(keymap, 'Nvim');
atu.bind_keyset(keymap, 'TScope');
atu.bind_keyset(keymap, 'Cmp');
atu.bind_keyset(keymap, 'Dap');
if vim.g.neovide then
    atu.bind_keyset(keymap, 'Neovide');
end
