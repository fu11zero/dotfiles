
-- Настраиваем комбинации под разные функции
local builtin = require('telescope.builtin')

require('telescope').setup{
    defaults = {
        sorting_strategy = "ascending", -- Results appear top-down
        layout_config = {
            prompt_position = "top",     -- Search bar at the top
        },
    },
    extensions = {
        ["ui-select"] = {
            require("telescope.themes").get_dropdown({
            })
        }
    }
}

require("telescope").load_extension("ui-select")

-- Работа с файлами и буфферами
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>ft', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>fs', builtin.lsp_workspace_symbols, {})
vim.keymap.set('n', 'gs', function()
  builtin.lsp_document_symbols({ 
      symbols = {
          'class',
          'interface',
          'struct',
          'enum',
          'field',
          -- 'property',
          'method',
          'function' 
          -- 'variable',
      }
  })
end, { desc = "LSP Document Symbols (Properties only)" })

-- Работа с Git
vim.keymap.set('n', '<leader>Gb', builtin.git_branches, {desc="Git Branches"})
vim.keymap.set('n', '<leader>Gc', builtin.git_commits, {desc="Git Commits"})
vim.keymap.set('n', '<leader>Gs', builtin.git_status, {desc="Git Status"})
-- vim.keymap.set('n', '<leader>Gp', builtin.git_pull, {})
-- vim.keymap.set('n', '<leader>GP', builtin.git_push, {})

-- Выбор цветовой схемы
vim.keymap.set('n', '<leader>cs', builtin.colorscheme, {})

