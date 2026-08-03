vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local buf_name = vim.api.nvim_buf_get_name(0)

    -- Определяем целевую директорию
    local target_dir = ""
    if buf_name == "" then
      target_dir = vim.fn.getcwd()
    elseif vim.fn.isdirectory(buf_name) == 1 then
      target_dir = buf_name
    else
      target_dir = vim.fn.getcwd()
    end

    -- Если папка определена, ищем и открываем README.md
    if target_dir ~= "" then
      local base_path = target_dir:sub(-1) == "/" and target_dir or target_dir .. "/"
      local readme = base_path .. "README.md"

      if vim.fn.filereadable(readme) == 1 then
        -- Откладываем выполнение на миллисекунду, чтобы Neovim успел настроить окружение
        vim.schedule(function()
          vim.cmd("edit " .. vim.fn.fnameescape(readme))
        end)
      end
    end
  end,
})
