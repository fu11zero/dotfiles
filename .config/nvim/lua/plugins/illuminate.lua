-- Configuration for RRethy/vim-illuminate
require('illuminate').configure({
})

-- Keybindings to jump between variable usages
local map = vim.keymap.set

-- Next usage
map({ "n", "x", "o" }, "]]", function()
    require("illuminate").goto_next_reference(false)
end, { desc = "Next Reference" })

-- Previous usage
map({ "n", "x", "o" }, "[[", function()
    require("illuminate").goto_prev_reference(false)
end, { desc = "Prev Reference" })
