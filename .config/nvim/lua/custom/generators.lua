-- Источник случайности: /dev/urandom, с откатом на math.random
math.randomseed(os.time() + (vim.loop.hrtime() % 1000000))

local function secure_bytes(n)
  local fd = io.open("/dev/urandom", "rb")
  if fd then
    local data = fd:read(n)
    fd:close()
    if data and #data == n then
      local bytes = {}
      for i = 1, n do bytes[i] = data:byte(i) end
      return bytes
    end
  end
  local bytes = {}
  for i = 1, n do bytes[i] = math.random(0, 255) end
  return bytes
end

-- Равномерный выбор из диапазона [0, max) без смещения по модулю
local function rand_below(max)
  local limit = 256 - (256 % max)
  while true do
    local b = secure_bytes(1)[1]
    if b < limit then return b % max end
  end
end

local function rand_hex(len)
  local s = ""
  local bytes = secure_bytes(len)
  for i = 1, len do s = s .. string.format("%X", bytes[i] % 16) end
  return s
end

-- 1. Enfusion ID
local function enf_id() return rand_hex(16) end

-- 2. Enfusion GUID
local function enf_guid() return "{" .. rand_hex(16) .. "}" end

-- 3. UUIDv4 (Стандартный случайный)
local function uuid4()
  local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
  return string.lower(string.gsub(template, '[xy]', function(c)
    return string.format('%X', (c == 'x') and rand_below(16) or (rand_below(4) + 8))
  end))
end

-- 4. UUIDv7 (По времени)
local function uuid7()
  local seconds, microseconds = vim.loop.gettimeofday()
  local ms = (seconds * 1000) + math.floor(microseconds / 1000)
  local th = string.format("%012X", ms)
  local v = ({"8", "9", "A", "B"})[rand_below(4) + 1]
  return string.lower(string.format("%s-%s-7%s-%s%s-%s",
    th:sub(1,8), th:sub(9,12), rand_hex(3), v, rand_hex(3), rand_hex(12)))
end

-- 5. Надёжный пароль
-- Длина по умолчанию 20; гарантированно содержит строчную, заглавную, цифру и символ.
local function password(len)
  len = len or 20
  if len < 4 then len = 4 end

  local sets = {
    "abcdefghijklmnopqrstuvwxyz",
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
    "0123456789",
    "!@#$%^&*()-_=+[]{};:,.<>?",
  }
  local all = table.concat(sets)

  local chars = {}
  -- по одному символу из каждого набора
  for _, set in ipairs(sets) do
    chars[#chars + 1] = set:sub(rand_below(#set) + 1, rand_below(#set) + 1)
  end
  -- добор до нужной длины
  for _ = #chars + 1, len do
    local idx = rand_below(#all) + 1
    chars[#chars + 1] = all:sub(idx, idx)
  end

  -- перемешивание Фишера–Йейтса, чтобы обязательные символы не стояли в начале
  for i = #chars, 2, -1 do
    local j = rand_below(i) + 1
    chars[i], chars[j] = chars[j], chars[i]
  end

  return table.concat(chars)
end

-- Универсальный обработчик (Normal + Visual)
local function insert(gen)
  local mode = vim.api.nvim_get_mode().mode
  local val = gen()
  if mode:sub(1,1) == "v" or mode:sub(1,1) == "V" then
    vim.api.nvim_feedkeys("c" .. val, "nx", false)
  else
    vim.api.nvim_put({ val }, "c", true, true)
  end
end

-- Клавиши
vim.keymap.set({'n', 'v'}, 'genid', function() insert(enf_id) end, { desc = "Generate 16 digits hex ID", noremap = true, silent = true } )
vim.keymap.set({'n', 'v'}, 'gengid', function() insert(enf_guid) end, { desc = "Generate {16 digits hex ID}", noremap = true, silent = true } )
vim.keymap.set({'n', 'v'}, 'genuu', function() insert(uuid4) end, { desc = "Generate uuid4", noremap = true, silent = true } )
vim.keymap.set({'n', 'v'}, 'genu4', function() insert(uuid4) end, { desc = "Generate uuid4", noremap = true, silent = true } )
vim.keymap.set({'n', 'v'}, 'genu7', function() insert(uuid7) end, { desc = "Generate uuid7", noremap = true, silent = true } )
vim.keymap.set({'n', 'v'}, 'genp', function() insert(function() return password(20) end) end, { desc = "Generate strong password (20)", noremap = true, silent = true } )
vim.keymap.set({'n', 'v'}, 'genp32', function() insert(function() return password(32) end) end, { desc = "Generate strong password (32)", noremap = true, silent = true } )

-- Команда с произвольной длиной: :GenPassword 24
vim.api.nvim_create_user_command("GenPassword", function(opts)
  local len = tonumber(opts.args) or 20
  vim.api.nvim_put({ password(len) }, "c", true, true)
end, { nargs = "?", desc = "Insert a strong password of given length (default 20)" })
