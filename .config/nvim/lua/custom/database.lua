-- Плавающее окно LazySQL.
--
-- <leader>s открывает LazySQL "умно" по аналогии с <leader>k (k9s.lua):
-- если мы внутри git-проекта unitcode (см. custom.unitcode_project), при
-- первом открытии обходим неймспейс проекта в кластере unitcode-dev и
-- собираем ВСЕ postgres-базы ТЕКУЩЕЙ ветки (backend/parser/another-service —
-- в неймспейсе может быть несколько бэкендов, у каждого своя БД). Для
-- каждой берём пользователя/базу из configmap "<app>-configuration" и
-- пароль из Secret "<app>-credentials", и складываем всё во временный
-- lazysql-конфиг с пробросом порта через ssh-туннель на дев-сервер — так
-- же, как уже вручную прописано в основном config.toml.
--
-- Вне такого проекта либо если в неймспейсе БД не нашлись — открываем
-- LazySQL с пустым конфигом.
--
-- Сейчас поддержан только postgres (суффикс сервисов "-postgres-service")
-- и только контекст unitcode-dev; mysql и другие контексты (prod/local) —
-- дело будущего расширения CONTEXT_LABELS / ENGINE_SUFFIXES.

local floating_terminal = require("custom.floating_terminal")
local unitcode_project = require("custom.unitcode_project")

local K8S_CONTEXT = "unitcode-dev"
local SSH_JUMP_HOST = "root@k8s.unitcode.dev"
local SSH_JUMP_PORT = "30022"

-- Короткая метка контекста для имени соединения в списке (dev.backend.dev.postgres).
-- Позже сюда добавятся unitcode-prod/local и т.п.
local CONTEXT_LABELS = {
    ["unitcode-dev"] = "dev",
}

local function context_label()
    return CONTEXT_LABELS[K8S_CONTEXT] or K8S_CONTEXT
end

local function handle_cmd(cmd)
    local f = io.popen(cmd .. " 2>/dev/null")
    if not f then return "" end
    local result = f:read("*a")
    f:close()
    return result:gsub("%s+$", "")
end

local function urlencode(str)
    return (str:gsub("[^%w%-%._~]", function(c)
        return string.format("%%%02X", string.byte(c))
    end))
end

--- Сервисы в неймспейсе, похожие на postgres ("*-postgres-service") и
--- относящиеся к текущей ветке, т.е. "<service>-<branch>-postgres-service".
--- Возвращает уже разобранные на "сервис" пары (backend, parser, ...).
---@return table[] { service_name = "backend-dev-postgres-service", service = "backend" }
local function list_postgres_services_for_branch(namespace, branch)
    local raw = handle_cmd(string.format(
        "kubectl --context %s -n %s get svc -o name",
        K8S_CONTEXT, namespace
    ))
    if raw == "" then return {} end

    local suffix = "-" .. branch .. "-postgres-service"
    local services = {}
    for line in raw:gmatch("[^\r\n]+") do
        local name = line:match("^service/(.+)$")
        if name and name:sub(-#suffix) == suffix then
            table.insert(services, {
                service_name = name,
                service = name:sub(1, #name - #suffix),
            })
        end
    end
    return services
end

--- Забирает POSTGRES_PASSWORD из секрета "<app>-credentials".
local function fetch_postgres_password(namespace, app_prefix)
    local password = handle_cmd(string.format(
        "kubectl --context %s -n %s get secret %s-credentials -o jsonpath='{.data.POSTGRES_PASSWORD}' | base64 -d",
        K8S_CONTEXT, namespace, app_prefix
    ))
    if password == "" or password == "no-password" then
        return nil
    end
    return password
end

--- Забирает POSTGRES_USER и POSTGRES_DB из конфигмапы "<app>-configuration"
--- (пользователь и база различаются между проектами, app-user — лишь дефолт).
---@return string user, string db
local function fetch_postgres_user_db(namespace, app_prefix)
    local raw = handle_cmd(string.format(
        [[kubectl --context %s -n %s get configmap %s-configuration -o jsonpath='{.data.POSTGRES_USER}{"\n"}{.data.POSTGRES_DB}']],
        K8S_CONTEXT, namespace, app_prefix
    ))
    local user, db = raw:match("^(.-)\n(.*)$")
    user = (user and user ~= "") and user or "app-user"
    db = (db and db ~= "") and db or "postgres"
    return user, db
end

local function build_db_entry(name, namespace, service_name, user, password, db)
    local host_fqdn = string.format("%s.%s.svc.cluster.local", service_name, namespace)

    return string.format([==[
[[database]]
Name = '%s'
URL = 'pgsql://%s:%s@127.0.0.1:${port}/%s?sslmode=disable'
Provider = 'postgres'
DBName = '%s'
Schemas = []

[[database.Commands]]
Command = 'ssh -tt -L ${port}:%s:5432 -p %s %s'
WaitForPort = '${port}'
SaveOutputTo = ''
Timeout = 0
]==], name, urlencode(user), urlencode(password), db, db, host_fqdn, SSH_JUMP_PORT, SSH_JUMP_HOST)
end

--- Пишет временный lazysql-конфиг из уже собранных TOML-кусков.
---@return string|nil путь к временному конфигу
local function write_temp_config(entries_toml)
    local path = vim.fn.tempname() .. "-lazysql.toml"
    local f = io.open(path, "w")
    if not f then return nil end
    f:write(entries_toml)
    f:close()
    return path
end

--- Собирает postgres-базы всех сервисов текущей ветки проекта в один
--- временный конфиг. Без ветки (detached HEAD и т.п.) сопоставить нечего —
--- возвращает пустой конфиг.
---@return string|nil путь к конфигу
---@return integer количество найденных баз
local function build_project_config(proj)
    if not proj.branch then
        return write_temp_config(""), 0
    end

    local services = list_postgres_services_for_branch(proj.namespace, proj.branch)

    local entries = {}
    for _, svc in ipairs(services) do
        local app_prefix = svc.service .. "-" .. proj.branch
        local password = fetch_postgres_password(proj.namespace, app_prefix)
        if password then
            local user, db = fetch_postgres_user_db(proj.namespace, app_prefix)
            local name = string.format("%s.%s.%s.postgres", context_label(), svc.service, proj.branch)

            table.insert(entries, {
                name = name,
                toml = build_db_entry(name, proj.namespace, svc.service_name, user, password, db),
            })
        else
            vim.notify(
                "LazySQL: не удалось получить пароль для " .. app_prefix .. ", пропускаю",
                vim.log.levels.WARN
            )
        end
    end

    table.sort(entries, function(a, b) return a.name < b.name end)

    local chunks = {}
    for _, entry in ipairs(entries) do
        table.insert(chunks, entry.toml)
    end

    return write_temp_config(table.concat(chunks, "\n")), #entries
end

local function open_lazysql(cmd)
    floating_terminal.toggle("lazysql", cmd, {
        title = "LazySQL",
    })
end

-- Основная логика переключения
local function open_lazysql_smart()
    -- Если инстанс уже открыт (пусть даже скрыт) — просто переключаем его,
    -- не пересчитывая проект/БД заново
    if floating_terminal.has("lazysql") then
        open_lazysql(nil)
        return
    end

    local proj = unitcode_project.resolve()

    -- Не git-проект unitcode -> пустой конфиг
    if not proj then
        open_lazysql("lazysql -config " .. write_temp_config(""))
        return
    end

    local config_path, count = build_project_config(proj)

    if count == 0 then
        vim.notify(
            "LazySQL: БД проекта " .. proj.namespace .. " не найдены в " .. K8S_CONTEXT .. ", открываю пустой конфиг",
            vim.log.levels.WARN
        )
    else
        vim.notify("LazySQL: " .. proj.namespace .. " — найдено БД: " .. count, vim.log.levels.INFO)
    end

    open_lazysql("lazysql -config " .. config_path)
end

vim.keymap.set("n", "<leader>s", open_lazysql_smart, { desc = "Smart LazySQL Floating Window" })


-- Отдельная команда для открытия LazySQL (с общим конфигом) в собственной вкладке
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
