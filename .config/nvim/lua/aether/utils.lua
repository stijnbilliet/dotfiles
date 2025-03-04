local M = {}

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

-- Wrapper around nvim feedkeys but ensure termcodes aren't escaped
function M.pass_keys_repl(keys)
	vim.api.nvim_feedkeys(
		vim.api.nvim_replace_termcodes(keys, true, false, true),
		"n",
		false
	);
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
        require('dap.ext.vscode').load_launchjs(nil, {});
    end
    dap.continue();
end

--TODO(stijn): Again for all the cases with fallback keys, look into nvim-mapper

-- completion engine interaction defintions
-- cmp if visible with luasnip fallbacks otherwise
function M.cmp_luasnip_select_next_item(args)
    local luasnip = require 'luasnip'
    local cmp = require 'cmp'
    if cmp.visible() then
       cmp.select_next_item({behavior = cmp.SelectBehavior.Select });
    elseif luasnip.expand_or_locally_jumpable() then
       luasnip.expand_or_jump();
    else
       M.pass_keys_repl(args.fbkey);
    end
end

function M.cmp_luasnip_select_prev_item(args)
    local luasnip = require 'luasnip'
    local cmp = require 'cmp'
    if cmp.visible() then
        cmp.select_prev_item({behavior = cmp.SelectBehavior.Select })
    elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
    else
       M.pass_keys_repl(args.fbkey);
    end
end

function M.cmp_try_abort(args)
    local cmp = require 'cmp'
    if cmp.visible() then
        cmp.abort()
    else
        M.pass_keys_repl(args.fbkey);
    end
end

function M.cmp_confirm_selected(args)
    local cmp = require 'cmp'
    local select = args.cmpargs.select or false
    if cmp.visible() and (not select and cmp.get_selected_entry()) then
        cmp.confirm(args.cmpargs)
    else
        M.pass_keys_repl(args.fbkey); -- fallback
    end
end

-- LSP
-- Helper function to request the LSP for a matching file. (i.e. source/header)
function M.switch_source_header()
    local params = { uri = vim.uri_from_bufnr(0) }
    vim.lsp.buf_request(0, 'textDocument/switchSourceHeader', params, function(err, result)
        if err then
            print('Error: ' .. err.message)
            return
        end
        if not result then
            print('No corresponding file found.')
            return
        end
        vim.api.nvim_command('edit ' .. vim.uri_to_fname(result))
    end)
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
function M.bind_keyset(keyset)
    for _, entry in ipairs(keyset) do
        bind_key_or_multi(entry)
    end
end

function M.bind_keyset_buffer(keyset, buffnr)
    for _, entry in ipairs(keyset) do
        local opts = entry.opts;
        opts.buffer = buffnr;
        bind_key_or_multi(entry)
    end
end

-- Helper function to ensure given user path is present/created
local function prep_user_path(foldername)
    -- Get home dir to get to todo path
    local homedir = os.getenv('HOME')
    local userpath = homedir.."/"..foldername.."/"

    -- Create it if it doesn't exist already
    if vim.fn.isdirectory(userpath) == 0 then
        vim.fn.mkdir(userpath, "p")
    end

    vim.api.nvim_set_current_dir(userpath)

    return userpath
end

-- Handle creation of TODO file, used with :Todo user command
function M.create_todo_file(name)
    local todopath = prep_user_path(".todo")

    local dateformat = "%Y-%m-%d"
    local date = os.date(dateformat)
    local time = os.date("%H:%M:%S")

    local newentry = "- [ ]  "

    -- Use provided name otherwise resort to todays date
    local fname = date
    if name ~= nil and name:len() > 0 then fname=name end
    local todofn = fname..'.md'

    -- Edit todo if already exists, otherwise create new buffer
    local todoexists = vim.fn.filereadable(todofn)
    vim.api.nvim_command('edit '..todofn)

    local moddate = vim.fn.strftime(dateformat, vim.fn.getftime(todofn))
    local isnewday = moddate ~= date
    if todoexists == 0 or isnewday then
        -- Insert the date and time at the first two lines
        local content = {date, time, "***", newentry}
        local numlines = 0
        if isnewday then
            numlines = vim.api.nvim_buf_line_count(0)
            table.insert(content, 1, "")
        end

        vim.api.nvim_buf_set_lines(0, numlines, -1, false, content)
        vim.api.nvim_command('normal! GA')
    else
        vim.api.nvim_command('normal! Go'..newentry)
    end

    vim.api.nvim_command('startinsert')
end

-- Helper, check if file is already loaded as an open buffer
function M.is_file_loaded(filename)
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) == filename then
            return true
        end
    end
    return false
end

-- Glob through todo directory and open buffer for each todo file
function M.list_todos(maxdays)
    local todopath = prep_user_path(".todo")
    local files = vim.fn.globpath(todopath, '*.md', false, true)

    if maxdays then
        files = vim.list_slice(files, 1, tonumber(maxdays))
    end

    for _, file in ipairs(files) do
        if not is_file_loaded(file) then
            -- Check if any open todos in file
            local file_contents = vim.fn.readfile(file)
            local match_results = vim.fn.match(table.concat(file_contents, "\n"), "\\[ \\]")
            local anyopens = tonumber(match_results) ~= -1
            if anyopens then
                vim.cmd('split ' .. file)
            end
        end
    end
end

-- Create a new note on the given 'name' as topic
function M.create_new_zettle(name)
    local zettlepath = prep_user_path(".zettlekasten")
    local date = os.date("%Y-%m-%d")

    -- Edit zettle if already exists, otherwise creates new buffer
    if name==nil or name=="" then name=date end
    local zettlefn = name..'.md'
    local zettleexists = vim.fn.filereadable(zettlefn)
    vim.api.nvim_command('edit '..zettlefn)

    if zettleexists == 0 then
        -- Insert the date and time at the first two lines
        vim.api.nvim_buf_set_lines(0, 0, -1, false, {"#"..name, "***"})
    end

    vim.api.nvim_command('normal! Go')
    vim.api.nvim_command('startinsert')
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
