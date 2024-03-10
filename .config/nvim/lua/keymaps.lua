local cmp = require 'cmp'
local telescope_ns = require 'telescope.builtin'
local dap = require 'dap'
local dap_ui_widgets = require 'dap.ui.widgets'

local function cmp_luasnip_select_next_item()
    local luasnip = require 'luasnip'
    return function(fallback)
        if cmp.visible() then
           cmp.select_next_item()
        elseif luasnip.expand_or_locally_jumpable() then
           luasnip.expand_or_jump()
        else
           fallback()
        end
    end
end

local function cmp_luasnip_select_prev_item()
    local luasnip = require 'luasnip'
    return function(fallback)
        if cmp.visible() then
            cmp.select_prev_item()
        elseif luasnip.locally_jumpable(-1) then
            luasnip.jump(-1)
        else
            fallback()
        end
    end
end

local telescopekeys = {
    { key='<leader>?',         mode='n',            func=telescope_ns.oldfiles,                                                        opts={ desc='[?] Find recently opened files' } },
    { key='<leader><space>',   mode='n',            func=telescope_ns.buffers,                                                         opts={ desc='[ ] Find existing buffers' } },
    { key='<leader>sf',        mode='n',            func=telescope_ns.find_files,                                                      opts={ desc='[S]earch [F]iles' } },
    { key='<leader>sh',        mode='n',            func=telescope_ns.help_tags,                                                       opts={ desc='[S]earch [H]elp' } },
    { key='<leader>sw',        mode='n',            func=telescope_ns.grep_string,                                                     opts={ desc='[S]earch current [W]ord' } },
    { key='<leader>sg',        mode='n',            func=telescope_ns.live_grep,                                                       opts={ desc='[S]earch by [G]rep' } },
}

local cmpkeys = {
    { key='<C-n>',             mode='n',            func=cmp.mapping.select_next_item,                                                 opts={} },
    { key='<C-p>',             mode='n',            func=cmp.mapping.select_prev_item,                                                 opts={} },
    { key='<C-d>',             mode='n',            func=cmp.mapping.scroll_docs,                                                      opts=-4 },
    { key='<C-f>',             mode='n',            func=cmp.mapping.scroll_docs,                                                      opts= 4 },
    { key='<C-Space>',         mode='n',            func=cmp.mapping.complete,                                                         opts={} },
    { key='<CR>',              mode='n',            func=cmp.mapping.confirm,                                                          opts={ behavior = cmp.ConfirmBehavior.Replace, select = true } },
    { key='<Tab>',             mode='n',            func=cmp_luasnip_select_next_item,                                                 opts={} },
    { key='<S-Tab>',           mode='n',            func=cmp_luasnip_select_prev_item,                                                 opts={} }
}

local lspkeys = {
    { key='<leader>rn',        mode='n',            func=vim.lsp.buf.rename,                                                           opts={ desc='[R]e[n]ame'} },
    { key='gd',                mode='n',            func=telescope_ns.lsp_definitions,                                                 opts={ desc='[G]oto [D]efinition'} },
    { key='gD',                mode='n',            func=vim.lsp.buf.declaration,                                                      opts={ desc='[G]oto [D]eclaration'} },
    { key='gr',                mode='n',            func=telescope_ns.lsp_references,                                                  opts={ desc='[G]oto [R]eferences'} },
    { key='gI',                mode='n',            func=telescope_ns.lsp_implementations,                                             opts={ desc='[G]oto [I]mplementation'} },
}

local dapkeys = {
    { key='<leader>dB',        mode='n',            func=function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end,    opts={ desc = "Breakpoint Condition" } },
    { key='<leader>da',        mode='n',            func=function() dap.continue({ before = get_args }) end,                           opts={ desc = "Run with Args" } },
    { key='<leader>db',        mode='n',            func=dap.toggle_breakpoint,                                                        opts={ desc = "Toggle Breakpoint" } },
    { key='<leader>dc',        mode='n',            func=dap.continue,                                                                 opts={ desc = "Continue" } },
    { key='<leader>dC',        mode='n',            func=dap.run_to_cursor,                                                            opts={ desc = "Run to Cursor" } },
    { key='<leader>dg',        mode='n',            func=dap.goto_,                                                                    opts={ desc = "Go to line (no execute)" } },
    { key='<leader>di',        mode='n',            func=dap.step_into,                                                                opts={ desc = "Step Into" } },
    { key='<leader>dj',        mode='n',            func=dap.down,                                                                     opts={ desc = "Down" } },
    { key='<leader>dk',        mode='n',            func=dap.up,                                                                       opts={ desc = "Up" } },
    { key='<leader>dl',        mode='n',            func=dap.run_last,                                                                 opts={ desc = "Run Last" } },
    { key='<leader>do',        mode='n',            func=dap.step_out,                                                                 opts={ desc = "Step Out" } },
    { key='<leader>dO',        mode='n',            func=dap.step_over,                                                                opts={ desc = "Step Over" } },
    { key='<leader>dp',        mode='n',            func=dap.pause,                                                                    opts={ desc = "Pause" } },
    { key='<leader>dr',        mode='n',            func=dap.repl.toggle,                                                              opts={ desc = "Toggle REPL" } },
    { key='<leader>ds',        mode='n',            func=dap.session,                                                                  opts={ desc = "Session" } },
    { key='<leader>dt',        mode='n',            func=dap.terminate,                                                                opts={ desc = "Terminate" } },
    { key='<leader>dw',        mode='n',            func=dap_ui_widgets.hover,                                                         opts={ desc = "Widgets" } },
}

local dapuikeys = {
    { key='<leader>du',        mode = 'n',          func=require("dapui").toggle,                                                      opts={desc = "Dap UI" }},
    { key='<leader>de',        mode = {'n', 'v'},   func=require("dapui").eval,                                                        opts={desc = "Eval"} },
}

return {
    mapping = {
        telescope   = telescopekeys,
        luacmp      = cmpkeys,
        lsp         = lspkeys,
        dbg         = {dapkeys, dapuikeys},
    }
}

