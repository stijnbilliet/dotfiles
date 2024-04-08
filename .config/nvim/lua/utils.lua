-- Toggle between terminal and currently opened buffer
-- resumes terminal if already created one earlier
-- and creates a new terminal if there wasn't one
vim.g.terminal_window = nil
function _G.toggle_terminal()
    if vim.g.terminal_window and vim.api.nvim_win_is_valid(vim.g.terminal_window) then
        vim.api.nvim_win_close(vim.g.terminal_window, true)
        vim.g.terminal_window = nil
    else
        local term_bufs = vim.api.nvim_list_bufs()
        for _, buf in ipairs(term_bufs) do
            if vim.bo[buf].buftype == 'terminal' then
                vim.api.nvim_command('bel 10sp')
                vim.api.nvim_win_set_buf(0, buf)
                vim.g.terminal_window = vim.api.nvim_get_current_win()
                vim.cmd(":startinsert")
                return
            end
        end
        vim.api.nvim_command('botright split | terminal')
        vim.g.terminal_window = vim.api.nvim_get_current_win()
        vim.cmd(":startinsert")
    end
end

-- VS(code) like functionality to quickly open a file from either
-- the git directory or the current working directory
function _G.quick_open()
    local builtin = require('telescope.builtin')
    local utils = require('telescope.utils')

    local _, ret, _ = utils.get_os_command_output({ 'git', 'rev-parse', '--is-inside-work-tree' })
    if ret == 0 then
        builtin.git_files()
    else
        builtin.find_files()
    end
end

-- Wrapper around nvim feedkeys but ensure termcodes aren't escaped
function _G.feed_keys(keys, mode)
	vim.api.nvim_feedkeys(
		vim.api.nvim_replace_termcodes(keys, true, true, true),
		mode,
		false
	);
end

-- Open the debug adapter (and by extention the UI - see config)
-- Checks and consults a launch.json if it is present
-- launch.json will specify the path of the executeable to attach to
-- if missing will fall back and spawn a user prompt requesting the path
function _G.dap_launch()
    local dap = require('dap')
    if vim.fn.filereadable('.vscode/launch.json') then
        require('dap.ext.vscode').load_launchjs(nil, {});
    end
    dap.continue();
end

-- completion engine interaction defintions
-- cmp if visible with luasnip fallbacks otherwise
function _G.cmp_luasnip_select_next_item()
    local luasnip = require 'luasnip'
    local cmp = require 'cmp'
    if cmp.visible() then
       cmp.select_next_item({ behavior = cmp.SelectBehavior.Select });
    elseif luasnip.expand_or_locally_jumpable() then
       luasnip.expand_or_jump();
    else
       feed_keys('<Tab>', 'ni');
    end
end

function _G.cmp_luasnip_select_prev_item()
    local luasnip = require 'luasnip'
    local cmp = require 'cmp'
    if cmp.visible() then
        cmp.select_prev_item()
    elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
    else
       feed_keys('<S-Tab>', 'ni');
    end
end

function _G.cmp_try_confirm()
    local cmp = require 'cmp'
    if not cmp.confirm({ select = false }) then
        feed_keys('<CR>', 'ni'); -- fallback
    end
end

