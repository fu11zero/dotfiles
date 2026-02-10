
require("toggleterm").setup({})

function _G.new_term()
    local terminal = require("toggleterm.terminal").Terminal
    local new_term = terminal:new({ count = #require("toggleterm.terminal").get_all() + 1 })
    new_term:toggle()
end

vim.api.nvim_create_user_command("TermNew", _G.new_term, {})

function _G.set_terminal_keymaps()
    local opts = {buffer = 0}
    -- vim.keymap.set('t', '<C-Esc>', [[<C-\><C-n>]], opts)
    -- vim.keymap.set({'t', 'n'}, '<C-esc>', [[<Cmd>ToggleTermToggleAll<CR>]], opts)
    vim.keymap.set({'t', 'n'}, '<C-Esc>', [[<Cmd>ToggleTerm<CR>]])
    vim.keymap.set({'t', 'n'}, '<M-h>', [[<Cmd>wincmd h<CR>]], opts)
    vim.keymap.set({'t', 'n'}, '<M-j>', [[<Cmd>wincmd j<CR>]], opts)
    vim.keymap.set({'t', 'n'}, '<M-k>', [[<Cmd>wincmd k<CR>]], opts)
    vim.keymap.set({'t', 'n'}, '<M-l>', [[<Cmd>wincmd l<CR>]], opts)
    vim.keymap.set({'t', 'n'}, '<C-w>', [[<C-\><C-n><C-w>]], opts)

    -- New tab
    vim.keymap.set('t', '<C-t>', _G.new_term, { desc = 'Terminal in new tab' })
    -- Close tab
    -- vim.keymap.set('t', '<C-q>', [[]], opts)
end

vim.cmd('autocmd! TermOpen term://*toggleterm#* lua set_terminal_keymaps()')

vim.keymap.set('n', '<C-Esc>', ':ToggleTerm<CR>')
