
vim.opt.termguicolors = true
require("bufferline").setup{
    options={
        offsets = {},
    }
}

vim.keymap.set('n','<M-l>', ':BufferLineCycleNext<CR>')
vim.keymap.set('n','<M-h>', ':BufferLineCyclePrev<CR>')
vim.keymap.set('n','<M-S-l>', ':BufferLineMoveNext<CR>')
vim.keymap.set('n','<M-S-h>', ':BufferLineMovePrev<CR>')
vim.keymap.set('n', '<C-q>', ':bp|bd #<CR>', { silent = true })
vim.keymap.set('n', '<C-S-Q>', ':BufferLineCloseOthers<CR>')

