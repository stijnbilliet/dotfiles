local function telescope_setup_keys()
    local keymaps = require('keymaps')
    for _, v in ipairs(keymaps.mapping.telescope) do
        vim.keymap.set(v.mode, v.key, v.func, v.opts)
    end
end

-- Bind keys from keymap to telescope
telescope_setup_keys();
