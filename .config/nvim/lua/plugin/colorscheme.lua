return {
    {
        'echasnovski/mini.base16',
        version = '*',
        config = function()
            local cfx = require('colors');
            require('mini.base16').setup({
                palette = cfx,
            })
        end
    },
}

