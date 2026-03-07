-- Configuration for RRethy/vim-illuminate
require('illuminate').configure({
})

-- Keybindings to jump between variable usages
local map = vim.keymap.set

vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    local buffer = vim.api.nvim_get_current_buf()

    -- Next usage
    map({ "n", "x", "o" }, "]]", function()
        require("illuminate").goto_next_reference(false)
    end, { desc = "Next Reference", buffer = buffer })

    -- Previous usage
    map({ "n", "x", "o" }, "[[", function()
        require("illuminate").goto_prev_reference(false)
    end, { desc = "Prev Reference", buffer = buffer })
  end,
})
