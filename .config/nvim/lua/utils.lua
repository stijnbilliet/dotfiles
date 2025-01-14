-- Toggle between terminal and currently opened buffer
-- resumes terminal if already created one earlier
-- and creates a new terminal if there wasn't one
vim.g.terminal_window = nil
function _G.toggle_terminal()
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
function _G.cmp_luasnip_select_next_item(fallback_key)
    local luasnip = require 'luasnip'
    local cmp = require 'cmp'
    if cmp.visible() then
       cmp.select_next_item();
    elseif luasnip.expand_or_locally_jumpable() then
       luasnip.expand_or_jump();
    else
       feed_keys(fallback_key, 'ni');
    end
end

function _G.cmp_luasnip_select_prev_item(fallback_key)
    local luasnip = require 'luasnip'
    local cmp = require 'cmp'
    if cmp.visible() then
        cmp.select_prev_item()
    elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
    else
       feed_keys(fallback_key, 'ni');
    end
end

function _G.cmp_try_confirm(fallback_key)
    local cmp = require 'cmp'
    if cmp.visible() then
        cmp.confirm({ select = true })
    elseif not cmp.confirm({ select = true }) then
        feed_keys(fallback_key, 'ni'); -- fallback
    end
end

vim.api.nvim_create_user_command(
    "Todo",
    function(opts)
        create_todo_file(opts.args or nil)
    end,
    { nargs='?' }
)

function prep_user_path(foldername)
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

function _G.create_todo_file(name)
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

vim.api.nvim_create_user_command(
    "Lstodo",
    function(opts)
        list_todos(opts.args or nil)
    end,
    { nargs='?' }
)

local function is_file_loaded(filename)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) == filename then
      return true
    end
  end
  return false
end

function _G.list_todos(maxdays)
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

vim.api.nvim_create_user_command(
    "Note",
    function(opts)
        create_new_zettle(opts.args or nil)
    end,
    { nargs='?' }
)

function _G.create_new_zettle(name)
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
local function change_scale_factor(delta)
    if vim.g.neovide then
      vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
    end
end

function _G.scale_text_up()
    change_scale_factor(1.25)
end

function _G.scale_text_down()
    change_scale_factor(1/1.25)
end
