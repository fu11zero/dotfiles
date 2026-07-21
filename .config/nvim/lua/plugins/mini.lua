
require('mini.move').setup({
  mappings = {
     -- Move visual selection in Visual mode.
    left = '<C-h>',
    right = '<C-l>',
    down = '<C-j>',
    up = '<C-k>',

    -- Move current line in Normal mode
    line_left = '<C-h>',
    line_right = '<C-l>',
    line_down = '<C-j>',
    line_up = '<C-k>',
  },

  -- Options which control moving behavior
  options = {
    -- Automatically reindent selection during linewise vertical move
    reindent_linewise = true,
  },
})
require('mini.pairs').setup({
  mappings = {
    ['\''] = { action = 'open', pair = '\'\'', neigh_pattern = '[^\\\']' },
    ['"'] = { action = 'open', pair = '""', neigh_pattern = '[^\\"]' },
    ['`'] = { action = 'open', pair = '`', neigh_pattern = '[^\\`]' },
    ['('] = { action = 'open', pair = '()', neigh_pattern = '[^\\)]' },
    ['['] = { action = 'open', pair = '[]', neigh_pattern = '[^\\]]' },
    ['{'] = { action = 'open', pair = '{}', neigh_pattern = '[^\\}]' },
  },
})
require("mini.icons").mock_nvim_web_devicons()
