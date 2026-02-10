-- Настраиваем комбинации под разные функции
local ufo = require('ufo')

-- vim.opt.foldmethod = "expr"
-- vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- Clear the current fold query
-- vim.treesitter.query.set("lua", "folds", "")

-- Set ONLY the function folds
-- vim.treesitter.query.set("lua", "folds", [[
--   (function_definition) @fold
-- ]])
  -- (function_declaration) @fold
  -- (local_function_definition) @fold

-- vim.opt.foldlevel = 99      -- Start with all folds open
-- vim.opt.foldlevelstart = 99 -- Close folds at level 1 (nested blocks) when opening a file
-- vim.opt.foldenable = true
-- vim.opt.fillchars = 'eob: ,fold: ,foldopen:,foldsep: ,foldinner: ,foldclose:'
vim.o.foldcolumn = '1'
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.fillchars = 'eob: ,fold: ,foldopen:,foldsep: ,foldinner: ,foldclose:'

vim.api.nvim_set_hl(0, "UfoFoldedBg", { bg = "NONE" })
local hl_groups = { "Folded", "UfoFoldedBg", "UfoCursorFoldedLine" }
for _, group in ipairs(hl_groups) do
    vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
end

-- -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
vim.keymap.set('n', 'zR', ufo.openAllFolds)
vim.keymap.set('n', 'zM', ufo.closeAllFolds)
-- treesitter as a main provider instead
ufo.setup({
    provider_selector = function(bufnr, filetype, buftype)
        return {'treesitter', 'indent'}
    end
})
