-- Quit
vim.keymap.set('n', '<leader>q', '<cmd>:quitall<CR>', { desc = "Quit" })
-- vim.keymap.set('n', '<leader>c', '<cmd>:quitall<CR>', { desc = "Quit" })

-- Copy all text
-- vim.keymap.set('n', '<C-a>', '<cmd>%y+<CR>')

-- Saving a file via Ctrl+S
-- vim.keymap.set('i', '<C-s>', '<cmd>:w<CR>')
-- vim.keymap.set('n', '<C-s>', '<cmd>:w<CR>')

-- NvimTree
vim.keymap.set('n', '<C-e>', ':NvimTreeFindFile<CR>')
vim.keymap.set('n', '<C-S-E>', ':NvimTreeToggle<CR>')
-- vim.keymap.set('n', '<leader>t', '<C-w> p', { desc = 'Go to previous window' })  
-- Snacks Explorer (replaces NvimTree)
-- vim.keymap.set('n', '<C-e>', function() Snacks.explorer.reveal() end, { desc = 'Reveal in Explorer' })
-- vim.keymap.set('n', '<C-S-E>', function() Snacks.explorer() end, { desc = 'Toggle Explorer' })

vim.keymap.set('n', '<leader>p', Snacks.picker.cliphist, { desc = "История буфера обмена", noremap = true, silent = true })
vim.keymap.set({'n', 'v'}, '<leader>ic', Snacks.picker.icons, { desc = "Выбор иконки", noremap = true, silent = true } )

-- LazyDocker: см. custom/docker.lua (<leader>d)

-- TodoList
vim.keymap.set('n', '<leader>nl', ':TodoTelescope<CR>')

-- Show references
vim.keymap.set('n', '<leader>fr', vim.lsp.buf.references, {desc = 'Go to references'}) -- Map to find references

-- LSP rename
vim.keymap.set('n', 'cd', vim.lsp.buf.rename, { desc = 'LSP rename' })

-- Вставить без перезаписи буфера
vim.keymap.set("x", "p", "P", { desc = "Вставить без перезаписи буфера" })

-- Checkbox
vim.keymap.set('n', '<leader>x', function()
  local line = vim.api.nvim_get_current_line()
  if string.find(line, "%[% %]") then
    vim.cmd([[s/\[ \]/\[x\]/]])
  elseif string.find(line, "%[x%]") then
    vim.cmd([[s/\[x\]/\[ \]/]])
  end
end, { desc = "Toggle checkbox" })

-- Генерирует случайный 16-значный HEX-строку
local function gen_enfusion_id()
  local id = ""
  for i = 1, 16 do
    id = id .. string.format("%X", math.random(0, 15))
  end
  return id
end

-- Маппинг: при нажатии <leader>id вставит ID прямо в текущую позицию курсора
vim.keymap.set('n', '<leader>id', function()
  local id = gen_enfusion_id()
  vim.api.nvim_put({ id }, 'c', true, true)
end, { desc = "Вставить случайный Enfusion Component ID" })


local function gen_standard_uuid()
  local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
  local uuid = string.gsub(template, '[xy]', function(c)
    local v = (c == 'x') and math.random(0, 15) or math.random(8, 11)
    return string.format('%X', v) -- Генерирует в верхнем регистре
  end)
  return uuid
end

-- Маппинг: по нажатию <leader>uu вставит стандартный UUID
vim.keymap.set('n', '<leader>uu', function()
  vim.api.nvim_put({ gen_standard_uuid() }, 'c', true, true)
end, { desc = "Вставить стандартный UUID" })

local function gen_uuidv7()
  -- Получаем текущее время в миллисекундах (Unix Epoch)
  -- loop.now() дает миллисекунды, гарантируя монотонность и точность
  local ms = vim.loop.now()
  
  -- Переводим миллисекунды в 12-значный HEX (48 бит)
  local time_hex = string.format("%012X", ms)
  
  -- Генерируем случайные HEX-символы для оставшихся частей
  local function rand_hex(len)
    local s = ""
    for i = 1, len do
      s = s .. string.format("%X", math.random(0, 15))
    end
    return s
  end

  -- Вариант для UUIDv7 должен начинаться с битов 10xx (8, 9, A или B)
  local variant_chars = {"8", "9", "A", "B"}
  local variant = variant_chars[math.random(1, 4)] .. rand_hex(3)

  -- Собираем структуру: time_high (8) - time_low (4) - 7 + rand (4) - variant + rand (4) - rand (12)
  local p1 = string.sub(time_hex, 1, 8)
  local p2 = string.sub(time_hex, 9, 12)
  local p3 = "7" .. rand_hex(3)
  local p4 = variant
  local p5 = rand_hex(12)

  return string.lower(string.format("%s-%s-%s-%s-%s", p1, p2, p3, p4, p5))
end

-- Маппинг: по нажатию <leader>u7 вставит UUIDv7 в позицию курсора
vim.keymap.set('n', '<leader>u7', function()
  vim.api.nvim_put({ gen_uuidv7() }, 'c', true, true)
end, { desc = "Вставить UUIDv7" })

