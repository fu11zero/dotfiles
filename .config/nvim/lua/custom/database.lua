-- Плавающее окно

local floating_terminal = require("custom.floating_terminal")

-- Глобальный хоткей для управления окном (работает в Normal и Terminal режимах)
vim.keymap.set("n", "<leader>s", function()
    floating_terminal.toggle("lazysql", "lazysql", {
        title = "LazySQL",
    })
end, { desc = "Toggle LazySQL Terminal" })


-- Отдельная команда для открытия LazySQL в собственной вкладке
vim.api.nvim_create_user_command("LazySQL", function()
  local buf = vim.api.nvim_create_buf(true, true)

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

