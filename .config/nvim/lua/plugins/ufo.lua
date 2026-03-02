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

-- Глобальные опции (чтобы ufo понимал, что нужно работать)
vim.o.foldlevel = 99 -- Открывать все складки по умолчанию (ufo управляет этим)
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.foldcolumn = '1'
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

-- Настройка StatusCol
local builtin = require("statuscol.builtin")
require("statuscol").setup({
    segments = {
        {
            text = { builtin.foldfunc, " " }, 
            click = "v:lua.ScFa" 
        },
        { text = { "%s" }, click = "v:lua.ScSa" },
        { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
    },
})

-- Настройка UFO (важно для авто-свертывания)
require('ufo').setup({
    provider_selector = function(bufnr, filetype, buftype)
        return {'treesitter', 'indent'} -- Используем treesitter для авто-определения складок
    end
})

-- Using ufo provider need remap `zR` and `zM`.
vim.keymap.set('n', 'zR', ufo.openAllFolds)
vim.keymap.set('n', 'zM', ufo.closeAllFolds)

-- Делаем прозрачным бэкграунд свертываний
vim.api.nvim_set_hl(0, "UfoFoldedBg", { bg = "NONE" })
local hl_groups = { "Folded", "UfoFoldedBg", "UfoCursorFoldedLine" }
for _, group in ipairs(hl_groups) do
    vim.api.nvim_set_hl(0, group, { bg = "NONE", ctermbg = "NONE" })
end

