-- Quit
vim.keymap.set('n', '<leader>q', '<cmd>:quitall<CR>', { desc = "Quit" })
-- vim.keymap.set('n', '<leader>c', '<cmd>:quitall<CR>', { desc = "Quit" })

-- Copy all text
-- vim.keymap.set('n', '<C-a>', '<cmd>%y+<CR>')

-- Saving a file via Ctrl+S
-- vim.keymap.set('i', '<C-s>', '<cmd>:w<CR>')
-- vim.keymap.set('n', '<C-s>', '<cmd>:w<CR>')

-- Snacks Explorer (replaces NvimTree)
vim.keymap.set('n', '<C-e>', function() Snacks.explorer.reveal() end, { desc = 'Reveal in Explorer' })
vim.keymap.set('n', '<C-S-E>', function() Snacks.explorer() end, { desc = 'Toggle Explorer' })

-- BufferLine
vim.keymap.set('n','<M-l>', ':BufferLineCycleNext<CR>')
vim.keymap.set('n','<M-h>', ':BufferLineCyclePrev<CR>')
vim.keymap.set('n', '<C-q>', ':bp|bd #<CR>', { silent = true })
vim.keymap.set('n', '<C-S-Q>', ':BufferLineCloseOthers<CR>')

-- LazyGIT (via snacks)
vim.keymap.set("n", "<leader>g", function() Snacks.lazygit() end, { desc = "Toggle LazyGit", noremap = true, silent = true })

-- LazySQL
vim.keymap.set("n", "<leader>s", "<cmd>LazySql<CR>", { desc = "Database LazySQL", noremap = true, silent = true })

-- LazyDocker
vim.keymap.set("n", "<leader>d", "<cmd>lua LazyDocker.toggle()<CR>", { desc = "Toggle LazyDocker", noremap = true, silent = true })

-- TodoList
vim.keymap.set('n', '<leader>nl', ':TodoTelescope<CR>')

-- Show references
vim.keymap.set('n', '<leader>fr', vim.lsp.buf.references, {desc = 'Go to references'}) -- Map to find references

-- LSP rename
vim.keymap.set('n', 'cd', vim.lsp.buf.rename, { desc = 'LSP rename' })

-- Вставить без перезаписи буфера
vim.keymap.set("x", "p", "P", { desc = "Вставить без перезаписи буфера" })
