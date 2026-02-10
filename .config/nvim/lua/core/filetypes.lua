local tui_group = vim.api.nvim_create_augroup("TUI", { clear = true })

-- Automatically close the terminal window when the process exits
vim.api.nvim_create_autocmd("TermClose", {
    group = tui_group,
    callback = function()
        -- Only close if the exit status is 0 (success)
        if vim.v.event.status == 0 then
            vim.cmd("bdelete!")
        end
    end,
})

-- Open xlsx files in xleak within a Neovim terminal
vim.api.nvim_create_autocmd("BufReadCmd", {
    group = tui_group,
    pattern = "*.xlsx",
    callback = function(ev)
        vim.cmd("terminal xleak -iH " .. vim.fn.shellescape(ev.file))
        vim.cmd("startinsert") -- Ensure you're in insert mode
        vim.bo.bufhidden = "wipe"
    end,
})

vim.api.nvim_create_autocmd("BufReadCmd", {
    group = tui_group,
    pattern = "*.docx",
    callback = function(ev)
        vim.cmd("terminal doxx " .. vim.fn.shellescape(ev.file))
        vim.cmd("startinsert") -- Ensure you're in insert mode
        vim.bo.bufhidden = "wipe"
    end,
})
