-- LazySQL floating window
vim.keymap.set("n", "<leader>s", function()
  Snacks.terminal.toggle("lazysql", {
    win = {
      position = "float",
      width = math.floor(vim.o.columns * 0.8),
      height = math.floor(vim.o.lines * 0.8),
      border = "rounded",
      title = "LazySQL",
      title_pos = "center",
    },
  })
end, { desc = "Toggle LazySQL", noremap = true, silent = true })

vim.api.nvim_create_user_command("LazySQL", function()
  local buf = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_win_set_buf(0, buf)

  vim.fn.termopen("lazysql", {
    on_exit = function()
      if vim.api.nvim_buf_is_valid(buf) then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end
  })

  vim.api.nvim_buf_set_name(buf, "lazysql")

  vim.cmd("startinsert")
end, {})

vim.keymap.set("n", "<leader>S", "<cmd>:LazySQL<CR>");
