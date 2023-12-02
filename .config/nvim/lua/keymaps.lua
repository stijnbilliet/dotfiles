local cmp = require 'cmp'
local luasnip = require 'luasnip'
local telescope_ns = require 'telescope.builtin'

local function cmp_luasnip_select_next_item()
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
    { key ='<leader>?',     mode='n',       func=telescope_ns.oldfiles,             opts={ desc = '[?] Find recently opened files' } },
    { key ='<leader>?',     mode='n',       func=telescope_ns.buffers,              opts={ desc = '[ ] Find existing buffers' } },
    { key ='<leader>?',     mode='n',       func=telescope_ns.find_files,           opts={ desc = '[S]earch [F]iles' } },
    { key ='<leader>?',     mode='n',       func=telescope_ns.help_tags,            opts={ desc = '[S]earch [H]elp' } },
    { key ='<leader>?',     mode='n',       func=telescope_ns.grep_string,          opts={ desc = '[S]earch current [W]ord' } },
    { key ='<leader>?',     mode='n',       func=telescope_ns.live_grep,            opts={ desc = '[S]earch by [G]rep' } },
}

local cmpkeys = {
    { key = '<C-n>',        mode='n',       func=cmp.mapping.select_next_item,      opts={} },
    { key = '<C-p>',        mode='n',       func=cmp.mapping.select_prev_item,      opts={} },
    { key = '<C-d>',        mode='n',       func=cmp.mapping.scroll_docs,           opts=-4 },
    { key = '<C-f>',        mode='n',       func=cmp.mapping.scroll_docs,           opts= 4 },
    { key = '<C-Space>',    mode='n',       func=cmp.mapping.complete,              opts={} },
    { key = '<CR>',         mode='n',       func=cmp.mapping.confirm,               opts={ behavior = cmp.ConfirmBehavior.Replace, select = true } },
    { key = '<Tab>',        mode='n',       func=cmp_luasnip_select_next_item,      opts={} },
    { key = '<S-Tab>',      mode='n',       func=cmp_luasnip_select_prev_item,      opts={} }
}

local function cmp_generate_mapping()
    local luacmpkeys = {}
    for _, v in ipairs(cmpkeys) do
        if type(v.opts) ~= "table" or next(v.opts) ~= nil then
            luacmpkeys[v.key] = v.func(v.opts);
        else
            luacmpkeys[v.key] = v.func();
        end
    end
    return luacmpkeys;
end

-- Set telescope keys
for _, v in ipairs(telescopekeys) do
    vim.keymap.set(v.mode, v.key, v.func, v.opts)
end

-- Set Lua Cmp keys
cmp.setup({
    mapping = cmp.mapping.preset.insert(cmp_generate_mapping())
})
