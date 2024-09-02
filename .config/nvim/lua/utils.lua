-- Toggle between terminal and currently opened buffer
-- resumes terminal if already created one earlier
-- and creates a new terminal if there wasn't one
vim.g.terminal_window = nil
function _G.toggle_terminal()
    if vim.g.terminal_window and vim.api.nvim_win_is_valid(vim.g.terminal_window) then
        vim.api.nvim_win_close(vim.g.terminal_window, true)
        vim.g.terminal_window = nil
    else
        vim.api.nvim_command('bel 10sp')
        local term_bufs = vim.api.nvim_list_bufs()
        for _, buf in ipairs(term_bufs) do
            if vim.bo[buf].buftype == 'terminal' then
                vim.api.nvim_win_set_buf(0, buf)
                vim.g.terminal_window = vim.api.nvim_get_current_win()
                return
            end
        end
        vim.api.nvim_command('terminal')
        vim.g.terminal_window = vim.api.nvim_get_current_win()
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

vim.cmd([[
  command! Todo lua create_todo_file()
]])

function prep_todo_path()
    -- Get home dir to get to todo path
    local homedir = os.getenv('HOME')
    local todopath = homedir .. "/.todo/"

    -- Create it if it doesn't exist already
    if vim.fn.isdirectory(todopath) == false then
        vim.fn.mkdir(todopath, "p")
    end

    vim.api.nvim_set_current_dir(todopath)

    return todopath
end

function _G.create_todo_file()
    local todopath = prep_todo_path()
    local date = os.date("%Y-%m-%d")
    local time = os.date("%H:%M:%S")
    local newentry = "- [ ]  "

    -- Edit todo if already exists, otherwise creates new buffer
    local todofn = date..'.md'
    local todoexists = vim.fn.filereadable(todofn) 
    vim.api.nvim_command('edit '..todofn)

    if todoexists == 0 then
        -- Insert the date and time at the first two lines
        vim.api.nvim_buf_set_lines(0, 0, -1, false, {date, time, "***", newentry})
        vim.api.nvim_command('normal! GA')
    else
        vim.api.nvim_command('normal! Go'..newentry)
    end

    vim.api.nvim_command('startinsert')
end

vim.api.nvim_create_user_command(
    'Lstodo',
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
    local todopath = prep_todo_path()
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
