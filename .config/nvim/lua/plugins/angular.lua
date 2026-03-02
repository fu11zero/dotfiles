local M = {}

-- Вспомогательная функция для создания плавающего терминала
local function open_floating_term(cmd, on_exit_callback)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.4)
  local buf = vim.api.nvim_create_buf(false, true)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
    title = " Angular CLI ",
    title_pos = "center",
  })

  vim.fn.termopen(cmd, {
    on_exit = function()
      print("Done!")
      if on_exit_callback then on_exit_callback() end
    end
  })
  vim.cmd("startinsert")
end

local function get_folders(path)
  -- readdir возвращает только имена файлов/папок в директории
  return vim.fn.readdir(path, function(name)
    -- Проверяем, является ли объект директорией
    return vim.fn.isdirectory(path .. '/' .. name) == 1
  end)
end

local function run(list, command)
  local api = require("nvim-tree.api")
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local themes = require("telescope.themes")

  local node = api.tree.get_node_under_cursor()
  if not node then return end

  local target_path = node.type == 'directory' and node.absolute_path or vim.fn.fnamemodify(node.absolute_path, ":h")
  local relative_path = vim.fn.fnamemodify(target_path, ":."):gsub("^%./", "")

  -- Используем тему dropdown для маленького окна
  local opts = themes.get_dropdown({
    border = true,
    previewer = false,
    layout_config = {
      width = 0.4,
      height = 0.3,
    },
    prompt_title = "NG Generate",
  })

  pickers.new(opts, {
    finder = finders.new_table { results = list },
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()[1]


        local cmd = string.format(command, selection)

        -- Открываем терминал вместо невидимого выполнения
        open_floating_term("cd " .. relative_path .. " && " .. cmd, function()
            api.tree.reload() -- Обновляем дерево после закрытия терминала
        end)
        vim.schedule(function()
            vim.cmd('startinsert')
        end)
      end)
      return true
    end,
  }):find()
end

M.run_schematic = function()
  local schematics = get_folders("/home/fullzero/Projects/demo/schematics/src")
  run(schematics, "schematics ~/Projects/demo/schematics:%s --no-dry-run")
end

M.ng_generate = function()
  local schematics = { "component", "service", "module", "directive", "pipe", "class", "interface", "enum" }
  run(schematics, "ng generate %s")
end

return M
