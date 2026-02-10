vim.api.nvim_create_autocmd("FileType", {
    pattern = { "typescript", "javascript" },
    callback = function()
        vim.keymap.set('i', 'cl<CR>', 'console.log()<Esc>i')
        vim.keymap.set('i', 'cw<CR>', 'console.warn()<Esc>i')
        vim.keymap.set('i', 'ce<CR>', 'console.error()<Esc>i')
        vim.keymap.set('i', 'ci<CR>', 'console.info()<Esc>i')
    end,
})


