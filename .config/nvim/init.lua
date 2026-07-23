vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic
require('core.autosave')
require('core.plugins')
require('core.mappings')
require('core.colors')
require('core.configs')
require('core.emmets')
require('core.filetypes')
require('core.git')
require('core.generators')
require('core.clipboard')
-- disabled require('core.autocorrection')

-- Custom
require('custom.angular')

-- Plugins
require('plugins.autolayout')
require('plugins.mini')
require('plugins.nvim-tree')
require('plugins.treesitter')
require('plugins.lsp')
require('plugins.cmp')
-- require('plugins.glim')      -- requires toggleterm
require('plugins.mason')
-- require('plugins.mermaid')
-- require('plugins.telescope') -- replaced by snacks.picker
-- require('plugins.dashboard') -- replaced by snacks.dashboard
require('plugins.flatten')
require('plugins.k9s')
-- require('plugins.colorizer')
require('plugins.lualine')
require('plugins.comment')
require('plugins.opencode')
require('plugins.otter')
require('plugins.bufferline')
require('plugins.todo')
require('plugins.trouble')
-- require('plugins.toggleterm') -- replaced by snacks.terminal
require('plugins.ufo')
require('plugins.whichkey')
