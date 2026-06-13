
-- [[ DISABLED - requires toggleterm which is replaced by snacks.terminal ]]
-- To re-enable, uncomment 'require("plugins.glim")' in init.lua
-- and add toggleterm back to plugins.lua

-- local Terminal = require('toggleterm.terminal').Terminal

-- local function open_glim_for_current_project()
--   local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
--   local glim_term = Terminal:new({
--     cmd = "glim",
--     dir = vim.fn.getcwd(),
--     direction = "float",
--     close_on_exit = true,
--     float_opts = { border = "none" },
--   })
--   glim_term:toggle()
-- end

-- vim.keymap.set('n', '<leader>Gl', open_glim_for_current_project, { desc = "Open Glim for current project" })

