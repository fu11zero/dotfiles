local M = {}

local function get_explorer_target()
  local explorers = Snacks.picker.get({ source = "explorer" })
  if #explorers == 0 then
    local buf_dir = vim.fn.expand("%:p:h")
    if buf_dir and buf_dir ~= "" then
      return buf_dir, vim.fn.getcwd()
    end
    Snacks.notify.warn("Open explorer or a file first")
    return nil, nil
  end
  local picker = explorers[1]
  return Snacks.picker.util.dir(picker:current() or {}), picker:cwd()
end

local function run_in_terminal(cmd, title)
  Snacks.terminal.open(cmd, {
    win = {
      position = "float",
      width = math.floor(vim.o.columns * 0.8),
      height = math.floor(vim.o.lines * 0.4),
      border = "rounded",
      title = title,
      title_pos = "center",
    },
  })
end

local function refresh_explorer()
  vim.defer_fn(function()
    local explorers = Snacks.picker.get({ source = "explorer" })
    if #explorers > 0 then
      explorers[1]:find()
    end
  end, 500)
end

local function get_schematics_data(path_to_json)
  local file = io.open(vim.fn.expand(path_to_json), "r")
  if not file then
    Snacks.notify.error("Schematics collection not found: " .. path_to_json)
    return {}
  end
  local content = file:read("*all")
  file:close()
  local ok, data = pcall(vim.fn.json_decode, content)
  if not ok or not data.schematics then return {} end
  local results = {}
  for name, config in pairs(data.schematics) do
    table.insert(results, {
      name = name,
      description = config.description or "No description",
    })
  end
  return results
end

function M.ng_generate()
  local target_path = get_explorer_target()
  if not target_path then return end

  local schematics = {
    { name = "component",  description = "Component" },
    { name = "service",    description = "Service" },
    { name = "module",     description = "Module" },
    { name = "directive",  description = "Directive" },
    { name = "pipe",       description = "Pipe" },
    { name = "class",      description = "Class" },
    { name = "interface",  description = "Interface" },
    { name = "enum",       description = "Enum" },
  }

  vim.ui.select(schematics, {
    prompt = "ng generate",
    format_item = function(item)
      return string.format("%-15s %s", item.name, item.description)
    end,
  }, function(choice)
    if not choice then return end
    local cmd = string.format("cd %s && ng generate %s", target_path, choice.name)
    run_in_terminal(cmd, "ng generate " .. choice.name)
    refresh_explorer()
  end)
end

function M.run_schematic()
  local target_path = get_explorer_target()
  if not target_path then return end

  local schematics = get_schematics_data("~/Projects/demo/schematics/src/collection.json")
  if vim.tbl_isempty(schematics) then return end

  vim.ui.select(schematics, {
    prompt = "Run custom schematic",
    format_item = function(item)
      return string.format("%-30s %s", item.name, item.description)
    end,
  }, function(choice)
    if not choice then return end
    local cmd = string.format("cd %s && schematics ~/Projects/demo/schematics:%s --no-dry-run", target_path, choice.name)
    run_in_terminal(cmd, "schematics " .. choice.name)
    refresh_explorer()
  end)
end

vim.keymap.set("n", "<leader>ngg", M.ng_generate, { desc = "ng generate" })
vim.keymap.set("n", "<leader>ngs", M.run_schematic, { desc = "ng schematic" })

return M
