oc = require("opencode")

vim.keymap.set({ "n", "x" }, "<C-return>", function() oc.ask("@this: ") end,              { desc = "Ask opencode…" })
vim.keymap.set({ "n", "x" }, "<S-C-.>", function() oc.select() end,                       { desc = "Execute opencode action…" })
vim.keymap.set({ "n" }, "<leader>a", function() oc.ask() end,                             { desc = "Ask opencode" })

vim.keymap.set("n", "<S-C-u>", function() oc.command("session.half.page.up") end,   { desc = "Scroll opencode up" })
vim.keymap.set("n", "<S-C-d>", function() oc.command("session.half.page.down") end, { desc = "Scroll opencode down" })

vim.keymap.set('t', '<C-w>h', [[<C-\><C-n><C-w>h]], {silent = true})
vim.keymap.set('t', '<C-w>l', [[<C-\><C-n><C-w>l]], {silent = true})
vim.keymap.set('t', '<C-w>j', [[<C-\><C-n><C-w>j]], {silent = true})
vim.keymap.set('t', '<C-w>k', [[<C-\><C-n><C-w>k]], {silent = true})
vim.keymap.set('t', '<C-w>w', [[<C-\><C-n><C-w>w]], {silent = true})
