local function rand_hex(len)
  local s = ""
  for i = 1, len do s = s .. string.format("%X", math.random(0, 15)) end
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
    return string.format('%X', (c == 'x') and math.random(0, 15) or math.random(8, 11))
  end))
end

-- 4. UUIDv7 (По времени)
local function uuid7()
  local seconds, microseconds = vim.loop.gettimeofday()
  local ms = (seconds * 1000) + math.floor(microseconds / 1000)
  local th = string.format("%012X", ms)
  local v = ({"8", "9", "A", "B"})[math.random(1, 4)]
  return string.lower(string.format("%s-%s-7%s-%s%s-%s", 
    th:sub(1,8), th:sub(9,12), rand_hex(3), v, rand_hex(3), rand_hex(12)))
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
vim.keymap.set({'n', 'v'}, '<leader>id', function() insert(enf_id) end, { desc = "Generate 16 digits hex ID", noremap = true, silent = true } )
vim.keymap.set({'n', 'v'}, '<leader>gid', function() insert(enf_guid) end, { desc = "Generate {16 digits hex ID}", noremap = true, silent = true } )
vim.keymap.set({'n', 'v'}, '<leader>uu', function() insert(uuid4) end, { desc = "Generate uuid4", noremap = true, silent = true } )
vim.keymap.set({'n', 'v'}, '<leader>u4', function() insert(uuid4) end, { desc = "Generate uuid4", noremap = true, silent = true } )
vim.keymap.set({'n', 'v'}, '<leader>u7', function() insert(uuid7) end, { desc = "Generate uuid7", noremap = true, silent = true } )

