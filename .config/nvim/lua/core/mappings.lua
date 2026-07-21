-- Quit
vim.keymap.set('n', '<leader>q', '<cmd>:quitall<CR>', { desc = "Quit" })
-- vim.keymap.set('n', '<leader>c', '<cmd>:quitall<CR>', { desc = "Quit" })

-- Copy all text
-- vim.keymap.set('n', '<C-a>', '<cmd>%y+<CR>')

-- Saving a file via Ctrl+S
-- vim.keymap.set('i', '<C-s>', '<cmd>:w<CR>')
-- vim.keymap.set('n', '<C-s>', '<cmd>:w<CR>')

-- NvimTree
vim.keymap.set('n', '<C-e>', ':NvimTreeFindFile<CR>')
vim.keymap.set('n', '<C-S-E>', ':NvimTreeToggle<CR>')
-- vim.keymap.set('n', '<leader>t', '<C-w> p', { desc = 'Go to previous window' })  
-- Snacks Explorer (replaces NvimTree)
-- vim.keymap.set('n', '<C-e>', function() Snacks.explorer.reveal() end, { desc = 'Reveal in Explorer' })
-- vim.keymap.set('n', '<C-S-E>', function() Snacks.explorer() end, { desc = 'Toggle Explorer' })

-- BufferLine
vim.keymap.set('n','<M-l>', ':BufferLineCycleNext<CR>')
vim.keymap.set('n','<M-h>', ':BufferLineCyclePrev<CR>')
vim.keymap.set('n', '<C-q>', ':bp|bd #<CR>', { silent = true })
vim.keymap.set('n', '<C-S-Q>', ':BufferLineCloseOthers<CR>')

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

-- Checkbox
vim.keymap.set('n', '<leader>x', function()
  local line = vim.api.nvim_get_current_line()
  if string.find(line, "%[% %]") then
    vim.cmd([[s/\[ \]/\[x\]/]])
  elseif string.find(line, "%[x%]") then
    vim.cmd([[s/\[x\]/\[ \]/]])
  end
end, { desc = "Toggle checkbox" })
