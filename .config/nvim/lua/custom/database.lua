-- Плавающее окно LazySQL.
--
-- <leader>s открывает LazySQL "умно" по аналогии с <leader>k (k9s.lua):
-- если мы внутри git-проекта unitcode (см. custom.unitcode_project), при
-- первом открытии собираем во временный lazysql-конфиг все найденные
-- postgres-базы проекта, в порядке local -> dev (unitcode-dev) -> prod:
--   * local — docker-compose(.yml|.yaml)/.env в корне текущего репозитория,
--     подключение напрямую на локальный порт, без туннеля;
--   * dev — все сервисы ТЕКУЩЕЙ ветки в кластере unitcode-dev
--     (backend/parser/another-service — сервисов может быть несколько),
--     пользователь/база из configmap "<app>-configuration", пароль из
--     Secret "<app>-credentials", проброс порта через ssh-туннель на
--     дев-сервер;
--   * prod — ssh-хост стенда (ищем по алиасам из ~/.ssh/unitcode/conf/),
--     на нём docker-compose(.yml|.yaml)/.env проекта, проброс порта прямым
--     ssh-туннелем на хост.
-- Всё это — так же, как уже вручную прописано в основном config.toml.
--
-- lazysql не даёт задавать цвет/группу для соединения (проверено по
-- встроенным toml-тегам в бинарнике: у Database только Name/URL/Provider/
-- DBName/Schemas/Commands) — единственный рычаг визуально отделить
-- окружения это префикс в Name (local./dev./prod.) и порядок в списке.
--
-- Вне git-проекта unitcode либо если ничего не нашлось — открываем
-- LazySQL с пустым конфигом.
--
-- Сейчас поддержан только postgres (по image в compose / суффиксу сервиса
-- "-postgres-service"); mysql и другие движки — дело будущего расширения.

local floating_terminal = require("custom.floating_terminal")
local unitcode_project = require("custom.unitcode_project")
local compose = require("custom.compose_discovery")

local handle_cmd = compose.handle_cmd
local read_file = compose.read_file

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

-- Прод: ssh-хост стенда (custom.compose_discovery) -> compose.yaml -> .env
--
-- На хосте ищем compose.yaml/docker-compose.yml проекта в /data/<project>,
-- в нём — постгрес-сервис и проброшенный на localhost порт
-- ("127.0.0.1:5434:5432"), а пользователя/пароль/базу — в лежащем рядом .env.

--- Группирует строки docker-compose файла по сервисам верхнего уровня
--- (2 пробела отступа — имя сервиса, 4+ — его содержимое).
---@return table<string, string[]>
local function group_compose_services(text)
    local services = {}
    local current = nil
    for line in (text .. "\n"):gmatch("(.-)\n") do
        local svc = line:match("^  (%S+):%s*$")
        if svc then
            current = svc
            services[current] = {}
        elseif current and line:match("^    ") then
            table.insert(services[current], line)
        elseif line:match("^%S") then
            current = nil
        end
    end
    return services
end

--- Находит среди сервисов compose-файла все postgres (по image) и порты,
--- проброшенные с них на localhost хоста ("127.0.0.1:5434:5432" -> 5434).
--- Обычно такой сервис один (db), но теоретически бывает и несколько.
---@return table[] отсортированный по имени сервиса список { service, port, body }
local function find_postgres_services_in_compose(compose_text)
    local found = {}
    for service, lines in pairs(group_compose_services(compose_text)) do
        local body = table.concat(lines, "\n")
        if body:lower():find("image:%s*[^\n]-postgres") then
            local port = body:match('"%d+%.%d+%.%d+%.%d+:(%d+):%d+"') or body:match('"(%d+):%d+"')
            if port then
                table.insert(found, { service = service, port = port, body = body })
            end
        end
    end
    table.sort(found, function(a, b) return a.service < b.service end)
    return found
end

--- Разбирает произвольный текст в стиле .env (KEY=value, по строке) в таблицу.
---@return table<string, string>
local function parse_env_vars(text)
    local vars = {}
    for line in text:gmatch("[^\r\n]+") do
        local k, v = line:match("^([%u_]+)=(.*)$")
        if k then
            vars[k] = v:gsub("^[\"'](.*)[\"']$", "%1")
        end
    end
    return vars
end

---@return string|nil user
---@return string|nil password
---@return string|nil db
local function pick_postgres_vars(vars)
    return vars.POSTGRES_USER, vars.POSTGRES_PASSWORD, vars.POSTGRES_DB or vars.POSTGRES_NAME
end

--- Забирает POSTGRES_USER/PASSWORD/DB(NAME) из .env рядом с compose-файлом на удалённом хосте.
---@return string|nil user
---@return string|nil password
---@return string|nil db
local function read_remote_env_postgres(host_alias, compose_dir)
    local raw = compose.ssh_run(host_alias, string.format(
        [[grep -iE "^(POSTGRES_USER|POSTGRES_PASSWORD|POSTGRES_DB|POSTGRES_NAME)=" %s/.env 2>/dev/null]],
        compose_dir
    ))
    return pick_postgres_vars(parse_env_vars(raw))
end

--- Разбирает значение переменной окружения из compose: "${VAR:-default}"
--- резолвится через .env (или default, если .env её не переопределяет),
--- "${VAR}" — только через .env, иначе значение берётся как есть.
local function resolve_compose_value(raw, env_vars)
    raw = raw:gsub("^[\"'](.*)[\"']$", "%1")
    local var, default = raw:match("^%${([%w_]+):%-(.*)}$")
    if var then
        return env_vars[var] or default
    end
    local var_only = raw:match("^%${([%w_]+)}$")
    if var_only then
        return env_vars[var_only]
    end
    return raw
end

--- POSTGRES_USER/PASSWORD/DB(NAME) сервиса локального compose: сперва из
--- его собственного inline "environment:" (с резолвом ${VAR:-default} через
--- .env), а если там их нет — напрямую из .env (стиль "env_file:", как на проде).
---@return string|nil user
---@return string|nil password
---@return string|nil db
local function resolve_local_postgres_creds(service_body, env_vars)
    local function value_for(key)
        local raw = (service_body .. "\n"):match(key .. ":%s*(.-)\n")
        if raw then
            return resolve_compose_value(raw, env_vars)
        end
        return env_vars[key]
    end
    return value_for("POSTGRES_USER"), value_for("POSTGRES_PASSWORD"),
        value_for("POSTGRES_DB") or value_for("POSTGRES_NAME")
end

--- Собирает запись прод-БД проекта (ssh-хост -> compose.yaml -> .env).
--- Второе значение — причина неудачи, для диагностики.
---@return table|nil entry
---@return string|nil reason
local function build_prod_entry(proj)
    local host_alias = compose.find_prod_host_alias(proj.group, proj.project)
    if not host_alias then
        return nil, "не нашёл ssh-хост для " .. proj.group .. "/" .. proj.project
    end

    local compose_path = compose.find_remote_compose_path(host_alias, proj.project)
    if not compose_path then
        return nil, "не нашёл compose-файл на " .. host_alias
    end
    local compose_dir = compose_path:match("^(.*)/[^/]+$")

    local compose_text = compose.ssh_run(host_alias, "cat " .. compose_path)
    local pg_services = find_postgres_services_in_compose(compose_text)
    if #pg_services == 0 then
        return nil, "не нашёл проброшенный порт postgres в " .. compose_path
    end
    local remote_port = pg_services[1].port

    local user, password, db = read_remote_env_postgres(host_alias, compose_dir)
    if not (user and password and db) then
        return nil, "не нашёл POSTGRES_* переменные в " .. compose_dir .. "/.env"
    end

    local name = string.format("prod.%s.postgres", proj.project)
    local toml = string.format([==[
[[database]]
Name = '%s'
URL = 'pgsql://%s:%s@127.0.0.1:${port}/%s?sslmode=disable'
Provider = 'postgres'
DBName = '%s'
Schemas = []

[[database.Commands]]
Command = 'ssh -tt -L ${port}:127.0.0.1:%s %s'
WaitForPort = '${port}'
SaveOutputTo = ''
Timeout = 0
]==], name, urlencode(user), urlencode(password), db, db, remote_port, host_alias)

    return { name = name, toml = toml, env = "prod" }, nil
end

-- Local: docker-compose(.yml|.yaml)/.env в корне текущего репозитория.
-- Порт уже локальный (проброшен самим docker compose на хост-машину) —
-- ssh-туннель и ${port}-подстановка не нужны, URL сразу рабочий.

--- Собирает записи локальных postgres-баз проекта (может быть несколько
--- сервисов, например основная и тестовая база).
---@return table[]
local function build_local_entries(proj)
    local root = compose.find_local_project_root()
    if not root then return {} end

    local compose_path = compose.find_local_compose_path(root)
    if not compose_path then return {} end

    local compose_text = read_file(compose_path) or ""
    local pg_services = find_postgres_services_in_compose(compose_text)
    if #pg_services == 0 then return {} end

    local env_vars = parse_env_vars(read_file(root .. "/.env") or "")

    local entries = {}
    for _, svc in ipairs(pg_services) do
        local user, password, db = resolve_local_postgres_creds(svc.body, env_vars)
        if not (user and password and db) then
            vim.notify(
                "LazySQL: не нашёл POSTGRES_* переменные для локального сервиса " .. svc.service,
                vim.log.levels.INFO
            )
            goto continue
        end

        local name = #pg_services == 1
            and string.format("local.%s.postgres", proj.project)
            or string.format("local.%s.%s.postgres", proj.project, svc.service)

        local toml = string.format([==[
[[database]]
Name = '%s'
URL = 'pgsql://%s:%s@127.0.0.1:%s/%s?sslmode=disable'
Provider = 'postgres'
DBName = '%s'
Schemas = []
]==], name, urlencode(user), urlencode(password), svc.port, db, db)

        table.insert(entries, { name = name, toml = toml, env = "local" })
        ::continue::
    end
    return entries
end

--- Пишет временный lazysql-конфиг из уже собранных TOML-кусков.
---@return string|nil путь к временному конфигу
local function write_temp_config(entries_toml)
    return compose.write_temp_file(entries_toml, "-lazysql.toml")
end

-- В списке базы всегда идут в этом порядке: local -> dev -> prod.
local ENV_ORDER = { ["local"] = 1, ["dev"] = 2, ["prod"] = 3 }

--- Собирает postgres-базы проекта в один временный конфиг: локальный
--- docker-compose, все сервисы текущей ветки в unitcode-dev (без ветки
--- сопоставить нечего — пропускаем) и прод, если для проекта нашёлся
--- ssh-хост.
---@return string|nil путь к конфигу
---@return integer количество найденных баз
local function build_project_config(proj)
    local entries = {}

    for _, entry in ipairs(build_local_entries(proj)) do
        table.insert(entries, entry)
    end

    if proj.branch then
        local services = list_postgres_services_for_branch(proj.namespace, proj.branch)
        for _, svc in ipairs(services) do
            local app_prefix = svc.service .. "-" .. proj.branch
            local password = fetch_postgres_password(proj.namespace, app_prefix)
            if password then
                local user, db = fetch_postgres_user_db(proj.namespace, app_prefix)
                local name = string.format("%s.%s.%s.postgres", context_label(), svc.service, proj.branch)

                table.insert(entries, {
                    name = name,
                    toml = build_db_entry(name, proj.namespace, svc.service_name, user, password, db),
                    env = "dev",
                })
            else
                vim.notify(
                    "LazySQL: не удалось получить пароль для " .. app_prefix .. ", пропускаю",
                    vim.log.levels.WARN
                )
            end
        end
    end

    local prod_entry, prod_err = build_prod_entry(proj)
    if prod_entry then
        table.insert(entries, prod_entry)
    elseif prod_err then
        vim.notify("LazySQL: прод не найден (" .. prod_err .. ")", vim.log.levels.INFO)
    end

    table.sort(entries, function(a, b)
        if ENV_ORDER[a.env] ~= ENV_ORDER[b.env] then
            return ENV_ORDER[a.env] < ENV_ORDER[b.env]
        end
        return a.name < b.name
    end)

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
            "LazySQL: БД проекта " .. proj.namespace .. " не найдены, открываю пустой конфиг",
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
