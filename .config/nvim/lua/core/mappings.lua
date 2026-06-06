vim.g.mapleader = " "

-- Quit
vim.keymap.set('n', '<leader>cc', '<cmd>:quitall<CR>', { desc = "Quit" })

-- Copy all text
-- vim.keymap.set('n', '<C-a>', '<cmd>%y+<CR>')

-- Saving a file via Ctrl+S
-- vim.keymap.set('i', '<C-s>', '<cmd>:w<CR>')
-- vim.keymap.set('n', '<C-s>', '<cmd>:w<CR>')

-- NvimTree
vim.keymap.set('n', '<C-e>', ':NvimTreeFindFile<CR>')
vim.keymap.set('n', '<C-E>', ':NvimTreeToggle<CR>')
-- vim.keymap.set('n', '<leader>t', '<C-w> p', { desc = 'Go to previous window' })  

-- BufferLine
vim.keymap.set('n','<M-l>', ':BufferLineCycleNext<CR>')
vim.keymap.set('n','<M-h>', ':BufferLineCyclePrev<CR>')
vim.keymap.set('n', '<C-q>', ':bp|bd #<CR>', { silent = true })
vim.keymap.set('n', '<C-S-Q>', ':BufferLineCloseOthers<CR>')

-- LazyGIT
vim.keymap.set("n", "<leader>lg", "<cmd>LazyGit<CR>", { desc = "Toggle LazyGit", noremap = true, silent = true })

-- LazySQL
vim.keymap.set("n", "<leader>ls", "<cmd>LazySql<CR>", { desc = "Database LazySQL", noremap = true, silent = true })

-- LazyDocker
vim.keymap.set("n", "<leader>ld", "<cmd>lua LazyDocker.toggle()<CR>", { desc = "Toggle LazyDocker", noremap = true, silent = true })

-- TodoList
vim.keymap.set('n', '<leader>nl', ':TodoTelescope<CR>')

-- Show references
vim.keymap.set('n', '<leader>fr', vim.lsp.buf.references, {desc = 'Go to references'}) -- Map to find references

-- Edit 
-- vim.keymap.set('n', 'cd', vim.lsp.buf.rename, { desc = 'LSP rename' })
vim.keymap.set("n", "cd", function()
  return ":IncRename " .. vim.fn.expand("<cword>")
end, { expr = true, desc = "LSP rename" })

-- Вставить без перезаписи буфера
vim.keymap.set("x", "p", "P", { desc = "Вставить без перезаписи буфера" })
