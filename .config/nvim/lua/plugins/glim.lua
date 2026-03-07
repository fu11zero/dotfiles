
local Terminal = require('toggleterm.terminal').Terminal

local function open_glim_for_current_project()
  -- Get the name of the current working directory
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')

  -- Create the terminal instance
  -- Glim doesn't have a direct 'filter' CLI flag, so we use its interactive
  -- search if available, or just open it in the current dir.
  local glim_term = Terminal:new({
    cmd = "glim",
    dir = vim.fn.getcwd(),
    direction = "float",
    close_on_exit = true,
    float_opts = {
      border = "none",
    },
    -- Optional: If glim supports a search argument in future versions, 
    -- you would append it to 'cmd' here.
  })

  glim_term:toggle()
end

-- Bind to a keystroke (e.g., <leader>g)
vim.keymap.set('n', '<leader>G', open_glim_for_current_project, { desc = "Open Glim for current project" })

