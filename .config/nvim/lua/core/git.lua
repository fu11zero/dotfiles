-- Gitsings
local gitsigns = require('gitsigns')

-- LazyGIT (via snacks)
vim.keymap.set("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "Toggle LazyGit", noremap = true, silent = true })

-- Navigation
vim.keymap.set('n', ']c', function()
    if vim.wo.diff then
        vim.cmd.normal({']c', bang = true})
    else
        gitsigns.nav_hunk('next')
    end
end)

vim.keymap.set('n', '[c', function()
    if vim.wo.diff then
        vim.cmd.normal({'[c', bang = true})
    else
        gitsigns.nav_hunk('prev')
    end
end)

-- actions
-- vim.keymap.set('n', '<leader>gs', gitsigns.stage_hunk)
vim.keymap.set('n', '<leader>gr', gitsigns.reset_hunk)

vim.keymap.set('v', '<leader>gs', function()
    gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
end)

vim.keymap.set('v', '<leader>gr', function()
    gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
end)

vim.keymap.set('n', '<leader>gS', gitsigns.stage_buffer)
vim.keymap.set('n', '<leader>gR', gitsigns.reset_buffer)
vim.keymap.set('n', '<leader>gp', gitsigns.preview_hunk)
vim.keymap.set('n', '<leader>gi', gitsigns.preview_hunk_inline)

vim.keymap.set('n', '<leader>gb', function()
    gitsigns.blame_line({ full = true })
end)

vim.keymap.set('n', '<leader>gd', Snacks.picker.git_diff, { desc = "Open Diff" })
vim.keymap.set("n", "<leader>gL", Snacks.picker.git_log, { desc = "Open project", noremap = true, silent = true })
vim.keymap.set("n", "<leader>glf", Snacks.picker.git_log_file, { desc = "Open file history", noremap = true, silent = true })
vim.keymap.set("n", "<leader>gll", Snacks.picker.git_log_file, { desc = "Open line history", noremap = true, silent = true })
vim.keymap.set("n", "<leader>gH", Snacks.picker.git_log, { desc = "Open project", noremap = true, silent = true })
vim.keymap.set("n", "<leader>ghf", Snacks.picker.git_log_file, { desc = "Open file history", noremap = true, silent = true })
vim.keymap.set("n", "<leader>ghl", Snacks.picker.git_log_file, { desc = "Open line history", noremap = true, silent = true })


-- vim.keymap.set('n', '<leader>gD', gitsigns.diffthis)
vim.keymap.set('n', '<leader>gD', function()
    gitsigns.diffthis('~')
end)

vim.keymap.set('n', '<leader>gQ', function() gitsigns.setqflist('all') end)
vim.keymap.set('n', '<leader>gq', gitsigns.setqflist)

-- Toggles
vim.keymap.set('n', '<leader>gtb', gitsigns.toggle_current_line_blame)
vim.keymap.set('n', '<leader>gtw', gitsigns.toggle_word_diff)

-- Text object
vim.keymap.set({'o', 'x'}, 'ic', gitsigns.select_hunk)
vim.keymap.set({'o', 'x'}, 'ac', gitsigns.select_hunk)

