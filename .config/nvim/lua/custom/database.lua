-- Плавающее окно

-- Хранилище для экземпляра тогла
local lazysql_toggle = nil

-- Глобальный хоткей для управления окном (работает в Normal и Terminal режимах)
vim.keymap.set({ "n", "t" }, "<leader>s", function()
    -- Если тогл еще ни разу не вызывался — создаем его
    if not lazysql_toggle then
        lazysql_toggle = Snacks.terminal.toggle("lazysql", {
            win = {
                wo = { winfixbuf = true },
                position = "float",
                width = math.floor(vim.o.columns * 0.8),
                height = math.floor(vim.o.lines * 0.8),
                border = "rounded",
                title = "LazySQL",
                title_pos = "center",
            },
        })

        -- Берем ID созданного буфера
        local buf = lazysql_toggle.buf

        -- 1. Маппинг внутри этого конкретного терминала для скрытия по <leader>s
        vim.keymap.set("t", "<leader>s", function()
            lazysql_toggle:hide()
        end, { buffer = buf, nowait = true, desc = "Hide LazySQL" })

        -- 3. Принудительное удержание режима Insert при фокусе буфера
        vim.api.nvim_create_autocmd({ "BufEnter", "CursorMoved" }, {
            buffer = buf,
            callback = function()
                if vim.api.nvim_get_current_buf() == buf then
                    vim.cmd("startinsert")
                end
            end,
        })
    else
        -- Если тогл уже существует, просто переключаем его видимость
        lazysql_toggle:toggle()
    end
end, { desc = "Toggle LazySQL Terminal" })


-- Отдельная команда для открытия LazySQL в собственной вкладке
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

