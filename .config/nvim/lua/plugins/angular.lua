local M = {}

-- Вспомогательная функция для создания плавающего терминала
local function open_floating_term(cmd, title, on_exit_callback)
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
    title = title or "",
    title_pos = "center",
  })

  vim.fn.termopen(cmd, {
    on_exit = function()
      if on_exit_callback then on_exit_callback() end
    end
  })
  vim.cmd("startinsert")
end

local function get_schematics_data(path_to_json)
    local file = io.open(vim.fn.expand(path_to_json), "r")
    if not file then return {} end

    local content = file.read(file, "*all")
    file:close()

    local ok, data = pcall(vim.fn.json_decode, content)
    if not ok or not data.schematics then return {} end

    local results = {}
    for name, config in pairs(data.schematics) do
        table.insert(results, {
            name = name,
            description = config.description or "No description",
            -- Здесь можно добавить любые другие поля из вашего JSON
            factory = config.factory,
            schema = config.schema,
            preview = config.preview
        })
    end
    return results
end

-- local function get_folders(path)
--   -- readdir возвращает только имена файлов/папок в директории
--   return vim.fn.readdir(path, function(name)
--     -- Проверяем, является ли объект директорией
--     return vim.fn.isdirectory(path .. '/' .. name) == 1
--   end)
-- end

local function run(list, command, cd_into_target)
  local api = require("nvim-tree.api")
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local entry_display = require("telescope.pickers.entry_display")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local themes = require("telescope.themes")

  local node = api.tree.get_node_under_cursor()
  if not node then return end

  -- local target_path = node.type == 'directory' and node.absolute_path or vim.fn.fnamemodify(node.absolute_path, ":h")
  local target_path = node.absolute_path
  local root_file = vim.fs.find({'angular.json', 'nx.json'}, { upward = true, stop = vim.loop.os_homedir(), path = target_path })[1]

  local root_dir
  local relative_path

  if root_file and false then
      root_dir = vim.fn.fnamemodify(root_file, ":h")
      relative_path = vim.fs.relpath(root_dir, target_path) or ""
  else
      root_dir = vim.fn.getcwd()
      relative_path = vim.fn.fnamemodify(target_path, ":."):gsub("^%./", "")
  end

  -- Создаем разметку: колонка для имени и колонка для описания
  local displayer = entry_display.create({
      separator = "  ",
      items = {
          { width = 25 }, -- Ширина колонки для имени
          { remaining = true }, -- Описание забирает всё остальное место
      },
  })

  local make_display = function(entry)
      return displayer({
          { entry.name, "Type" }, -- "Type" - это группа подсветки (Highlight group)
          { entry.description, "Comment" },
      })
  end

  local make_preview = function()
    require("telescope.previewers").new_buffer_previewer({
        define_preview = function(self, entry, status)
            vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, {
                "Schematic: " .. entry.name,
                "",
                "Description:",
                entry.description,
                "",
                "Factory path: " .. (entry.value.factory or "N/A"),
                "",
                "Preview:",
                entry.preview,
            })
        end
    })
  end

  -- Используем тему dropdown для маленького окна
  local opts = themes.get_dropdown({
    border = true,
    previewer = true,
    layout_strategy = "horizontal",
    layout_config = {
      width = 0.3,
      height = 0.4,
    },
    prompt_title = "Generate",
  })

  pickers.new(opts, {
    finder = finders.new_table {
        results = list,
        entry_maker = function(entry)
            return {
                value = entry,
                display = make_display,
                ordinal = entry.name .. " " .. entry.description, -- Для поиска
                name = entry.name,
                description = entry.description,
            }
        end,
    },
    sorter = conf.generic_sorter(opts),
    -- Заглушка для превью (пока просто текст)
    previewer = make_preview(),
    attach_mappings = function(prompt_bufnr, _)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()

        local cmd = string.format(command, selection.name)

        -- Открываем терминал вместо невидимого выполнения
        if cd_into_target then
            open_floating_term("cd " .. target_path .. " && " .. cmd, selection.name, function() api.tree.reload() end)
        else
            open_floating_term("cd " .. root_dir .. " && " .. cmd .. " --directory=. --path=" .. relative_path, selection.name, function() api.tree.reload() end)
        end
        vim.schedule(function()
            vim.cmd('startinsert')
        end)
      end)
      return true
    end,
  }):find()
end

M.run_schematic = function()
  -- local schematics = get_folders("/home/fullzero/Projects/demo/schematics/src")
  local schematics = get_schematics_data("/home/fullzero/Projects/demo/schematics/src/collection.json")
  run(schematics, "schematics ~/Projects/demo/schematics:%s --no-dry-run")
  -- run(schematics, "ng generate ~/Projects/demo/schematics:%s --no-dry-run")
end

M.ng_generate = function()
  local schematics = {
    {name = "component", description = "Component" },
    {name = "service", description = "Service" },
    {name = "component", description = "Component" },
    {name = "service", description = "Service" },
    {name = "module", description = "Module" },
    {name = "directive", description = "Directive" },
    {name = "pipe", description = "Pipe" },
    {name = "class", description = "Class" },
    {name = "interface", description = "Interface" },
    {name = "enum", description = "Enum" },
  }
  run(schematics, "ng generate %s", true)
end

return M
