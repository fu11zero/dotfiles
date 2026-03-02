local function set_layout(id)
  -- Используем vim.fn.system вместо os.execute, чтобы не было "ok"
  vim.fn.system(string.format("hyprctl switchxkblayout all %d", id))
end

local function is_russian(char)
  return char and char:match("[а-яА-ЯёЁ]") ~= nil
end

-- Функция определения символа под курсором
local function get_char_under_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  return line:sub(col + 1):match("^[%z\1-\127\194-\244][\128-\191]*")
end

-- Переменная для хранения языка перед входом в Insert
local last_detected_lang = 0

vim.api.nvim_create_augroup("AutoLayout", { clear = true })

-- Всегда сбрасываем на EN при выходе
vim.api.nvim_create_autocmd("InsertLeave", {
  group = "AutoLayout",
  callback = function() set_layout(0) end,
})

-- Обработка входа в Insert (a, i, o)
vim.api.nvim_create_autocmd("InsertEnter", {
  group = "AutoLayout",
  callback = function()
    if is_russian(get_char_under_cursor()) then
      set_layout(1)
    end
  end,
})

-- Магия для ciw, c, d и т.д.
-- Срабатывает ДО того, как текст будет удален
vim.api.nvim_create_autocmd("ModeChanged", {
  group = "AutoLayout",
  pattern = "n:no", -- При переходе из Normal в Operator-pending (когда нажали 'c')
  callback = function()
    if is_russian(get_char_under_cursor()) then
      last_detected_lang = 1
    else
      last_detected_lang = 0
    end
  end,
})

-- Когда оператор (например, 'c') завершает переход в Insert
vim.api.nvim_create_autocmd("ModeChanged", {
  group = "AutoLayout",
  pattern = "no:i", 
  callback = function()
    set_layout(last_detected_lang)
  end,
})
