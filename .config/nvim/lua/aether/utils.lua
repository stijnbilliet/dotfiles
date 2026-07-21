local M = {}

function M.find_root_dir(buf_id)
    local root_names = { '.git', 'Makefile' }
    buf_id = buf_id or 0

    if not vim.api.nvim_buf_is_valid(buf_id) then
        vim.notify("buf_id "..buf_id.." is invalid.", vim.log.levels.ERROR)
        return
    end

    local path = vim.api.nvim_buf_get_name(buf_id)
    if path == '' then return end

    local dir_path = vim.fs.dirname(path)
    local root_file = vim.fs.find(root_names, { path = dir_path, upward = true })[1]
    if root_file == nil then return end

    local result = vim.fs.dirname(root_file)
    result = vim.fs.normalize(vim.fn.fnamemodify(result, ':p')) --convert to full absolute "print path" and clean up

    return result
end

-- Toggle between terminal and currently opened buffer
-- resumes terminal if already created one earlier
-- and creates a new terminal if there wasn't one
vim.g.terminal_window = nil
function M.toggle_terminal()
    attach_terminal = function()
        vim.g.terminal_window = vim.api.nvim_get_current_win()
    end

    if vim.g.terminal_window and vim.api.nvim_win_is_valid(vim.g.terminal_window) then
        vim.api.nvim_win_close(vim.g.terminal_window, true)
        vim.g.terminal_window = nil
    else
        vim.api.nvim_command('bel 10sp')
        local term_bufs = vim.api.nvim_list_bufs()
        for _, buf in ipairs(term_bufs) do
            if vim.bo[buf].buftype == 'terminal' then
                vim.api.nvim_win_set_buf(0, buf)
                attach_terminal()
                return
            end
        end
        vim.api.nvim_command('terminal')
        attach_terminal()
    end
end

-- VS(code) like functionality to quickly open a file from either
-- the git directory or the current working directory
function M.quick_open()
    local builtin = require('telescope.builtin')
    local utils = require('telescope.utils')

    local _, ret, _ = utils.get_os_command_output({ 'git', 'rev-parse', '--is-inside-work-tree' })
    if ret == 0 then
        builtin.git_files()
    else
        builtin.find_files()
    end
end

-- VS(code) like grep through all the files in a solution, from either
-- the git directory or the current working directory
function M.find_in_files()
    local builtin = require('telescope.builtin')
    local utils = require('telescope.utils')

    local stdout, ret, _ = utils.get_os_command_output({ 'git', 'rev-parse', '--show-toplevel' })
    local opts = {}
    if ret == 0 then
        local git_dir = stdout[1]
        opts.cwd = git_dir
    end
    builtin.live_grep(opts)
end

-- Remove trailing whitespace from buffer
function M.remove_trailing_whitespace()
    local current_view = vim.fn.winsaveview()
    vim.cmd([[
        %s/\s\+$//e
    ]])
    vim.fn.winrestview(current_view)
end

-- Open the debug adapter (and by extention the UI - see config)
-- Checks and consults a launch.json if it is present
-- launch.json will specify the path of the executeable to attach to
-- if missing will fall back and spawn a user prompt requesting the path
function M.dap_launch()
    local dap = require('dap')
    if vim.fn.filereadable('.vscode/launch.json') then
        require('dap.ext.vscode').load_launchjs();
    end
    dap.continue();
end

function M.blink_select_next()
    if vim.bo.filetype == 'TelescopePrompt' then
        require('telescope.actions').move_selection_next(vim.api.nvim_get_current_buf())
        return
    end
    local blink = require('blink.cmp')
    if blink.is_visible() then
        blink.select_next()
    end
end

function M.blink_select_prev()
    if vim.bo.filetype == 'TelescopePrompt' then
        require('telescope.actions').move_selection_previous(vim.api.nvim_get_current_buf())
        return
    end
    local blink = require('blink.cmp')
    if blink.is_visible() then
        blink.select_prev()
    end
end

function M.blink_try_hide()
    local blink = require('blink.cmp')
    if blink.is_visible() then
        blink.hide()
    end
end

-- Super-tab: priority chain for <Tab> in insert/cmdline mode.
-- Selects+accepts the first completion item if the menu is visible.
-- Add further plugin checks here (e.g. snippet jumping) before the fallback.
-- Must return a string: '' if a plugin handled the key, '\t' to insert a literal tab.
function M.super_tab()
    local blink = require('blink.cmp')
    if blink.is_visible() then
        blink.select_and_accept()
        return ''
    end

    -- Hook: add other plugin checks here, e.g.:
    -- local ls = require('luasnip')
    -- if ls.locally_jumpable(1) then ls.jump(1); return '' end

    return '\t'
end

-- Super-enter: priority chain for <Enter> in insert/cmdline mode.
-- Only confirms the completion if an item is already explicitly selected.
-- Add further plugin checks here before the fallback.
-- Must return a string: '' if a plugin handled the key, '\r' to insert a literal newline.
function M.super_enter()
    local blink = require('blink.cmp')
    if blink.is_visible() and blink.get_selected_item() then
        blink.accept()
        return ''
    end

    -- Hook: add other plugin checks here, e.g.:
    -- local ls = require('luasnip')
    -- if ls.locally_jumpable(1) then ls.jump(1); return '' end

    return '\r'
end

-- LSP
-- Helper function to request the LSP for a matching file. (i.e. source/header)
function M.switch_source_header()
    local params = { uri = vim.uri_from_bufnr(0) }
    vim.lsp.buf_request(0, 'textDocument/switchSourceHeader', params, function(err, result)
        if err then
            vim.notify(err.message, vim.log.levels.ERROR)
            return
        end
        if not result then
            vim.notify('No corresponding file found.', vim.log.levels.INFO)
            return
        end
        vim.api.nvim_command('edit ' .. vim.uri_to_fname(result))
    end)
end

-- GITSIGNS
-- Naviate to NEXT difference in file/buffer
function M.diff_nav_next()
    if vim.wo.diff then
        vim.cmd.normal({']c', bang = true})
    else
        local gitsigns = require('gitsigns')
        gitsigns.nav_hunk('next')
    end
end

-- Naviate to PREV difference in file/buffer
function M.diff_nav_prev()
    if vim.wo.diff then
        vim.cmd.normal({'[c', bang = true})
    else
        local gitsigns = require('gitsigns')
        gitsigns.nav_hunk('prev')
    end
end

-- Toggle 'inline' diff on current buffer
function M.gitsigns_diff_inline()
    local gitsigns = require('gitsigns')
    gitsigns.toggle_word_diff()
    gitsigns.toggle_deleted()
    gitsigns.toggle_linehl()
    vim.g.aether_gitsigns_inline = not vim.g.aether_gitsigns_inline
end

-- super_j/super_k: priority chain for navigating "next/prev thing" in normal mode.
-- Both branches require explicitly-active state — nothing fires from ambient conditions.
-- Hook: add further plugin checks here before the no-op fallback.
function M.super_j()
    if vim.bo.filetype == 'TelescopePrompt' then
        require('telescope.actions').move_selection_next(vim.api.nvim_get_current_buf())
        return
    end
    if vim.wo.diff then
        vim.cmd.normal({']c', bang = true})
        return
    end
    if vim.g.aether_gitsigns_inline then
        require('gitsigns').nav_hunk('next')
        return
    end
    if #vim.diagnostic.get(0) > 0 then
        vim.diagnostic.jump({ count = 1 })
        return
    end
end

function M.super_k()
    if vim.bo.filetype == 'TelescopePrompt' then
        require('telescope.actions').move_selection_previous(vim.api.nvim_get_current_buf())
        return
    end
    if vim.wo.diff then
        vim.cmd.normal({'[c', bang = true})
        return
    end
    if vim.g.aether_gitsigns_inline then
        require('gitsigns').nav_hunk('prev')
        return
    end
    if #vim.diagnostic.get(0) > 0 then
        vim.diagnostic.jump({ count = -1 })
        return
    end
end

local function bind_key_or_multi(entry)
    if type(entry.key) == "string" then
        vim.keymap.set(entry.mode, entry.key, entry.func, entry.opts)
    elseif type(entry.key) == "table" then
        for k, v in pairs(entry.key) do
            vim.keymap.set(entry.mode, v, entry.func, entry.opts)
        end
    end
end

-- Helper functions for keyset (table of keys) bulk binding
function M.bind_keyset(keyset, _index)
    local index = _index or "Misc"
    for _, entry in ipairs(keyset) do
        local opts = vim.deepcopy(entry.opts)
        opts.desc = index..": "..opts.desc
        bind_key_or_multi({ key = entry.key, mode = entry.mode, func = entry.func, opts = opts })
    end
end

function M.bind_keyset_buffer(keyset, buffnr, _index)
    local index = _index or "Misc"
    for _, entry in ipairs(keyset) do
        local opts = vim.deepcopy(entry.opts)
        opts.buffer = buffnr
        opts.desc = index..": "..opts.desc
        bind_key_or_multi({ key = entry.key, mode = entry.mode, func = entry.func, opts = opts })
    end
end

-- Change scale factor of editor
-- Only used when running through neovide
vim.g.neovide_scale_factor = 1.0
function M.change_scale_factor(delta)
    if vim.g.neovide then
      vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
    end
end

return M;
