-- Плавающее окно LazyDocker.
--
-- <leader>d открывает LazyDocker "умно": если мы в git-проекте unitcode,
-- собираем найденные docker-compose окружения проекта — local (compose в
-- корне репозитория) и prod (compose на ssh-хосте стенда, ищем так же,
-- как в custom.database) — и даём выбрать через vim.ui.select (по
-- умолчанию это и есть Snacks.picker, см. picker.ui_select в
-- core.plugins). Дальше запускаем lazydocker, нацеленный именно на
-- выбранное окружение, а не на всю кучу контейнеров хоста разом.
--
-- local: `lazydocker -f <compose> -p <project>` — свой докер-сокет.
-- prod: lazydocker тоже запускается ЛОКАЛЬНО (на хосте установлен только
--   docker, самого lazydocker там нет), но подключается к докер-демону
--   хоста через unix-сокет, заранее проброшенный ssh-туннелем —
--   `ssh -N -L $SOCK:/var/run/docker.sock host` в фоне, DOCKER_HOST=unix://$SOCK.
--   Пробовали DOCKER_HOST=ssh://host напрямую (пусть Docker сам поднимает
--   туннель) — Docker закрывает соединение по своему внутреннему таймауту
--   раньше, чем успевает подняться туннель ("ssh tunneled socket never
--   became available: context deadline exceeded"), поэтому поднимаем
--   туннель сами и ждём появления сокета перед запуском. compose-файл
--   для `-f` лежит только на хосте — стягиваем его во временный локальный
--   файл. Туннель убиваем через `trap ... EXIT`, когда лезидокер завершится
--   (или окно будет закрыто).
--
-- Вне unitcode-проекта либо если окружений не нашлось — открываем
-- lazydocker как раньше, без фильтрации.

local floating_terminal = require("custom.floating_terminal")
local unitcode_project = require("custom.unitcode_project")
local compose = require("custom.compose_discovery")

--- Ищет local/prod docker-compose окружения текущего проекта.
---@return table[] { label, project, compose_path, host_alias? }
local function find_environments(proj)
    local envs = {}

    local root = compose.find_local_project_root()
    local local_compose = root and compose.find_local_compose_path(root)
    if local_compose then
        table.insert(envs, {
            label = string.format("local.%s", proj.project),
            project = proj.project,
            compose_path = local_compose,
        })
    end

    local host_alias = compose.find_prod_host_alias(proj.group, proj.project)
    local remote_compose = host_alias and compose.find_remote_compose_path(host_alias, proj.project)
    if remote_compose then
        table.insert(envs, {
            label = string.format("prod.%s", proj.project),
            project = proj.project,
            compose_path = remote_compose,
            host_alias = host_alias,
        })
    end

    return envs
end

--- Строит команду запуска lazydocker для выбранного окружения.
---@return string|nil
local function build_cmd(env)
    if not env.host_alias then
        return string.format("lazydocker -f %s -p %s", env.compose_path, env.project)
    end

    local compose_text = compose.ssh_run(env.host_alias, "cat " .. env.compose_path)
    local local_copy = compose.write_temp_file(compose_text, "-docker-compose.yaml")
    if not local_copy then
        vim.notify("LazyDocker: не смог сохранить compose-файл " .. env.host_alias, vim.log.levels.WARN)
        return nil
    end

    local socket_path = string.format("/tmp/lazydocker-%s.sock", env.project)

    return string.format([==[
SOCK=%s
rm -f "$SOCK"
ssh -o ExitOnForwardFailure=yes -N -L "$SOCK:/var/run/docker.sock" %s &
TUNNEL_PID=$!
trap 'kill $TUNNEL_PID 2>/dev/null; rm -f "$SOCK"' EXIT
for i in $(seq 1 50); do [ -S "$SOCK" ] && break; sleep 0.1; done
DOCKER_HOST=unix://$SOCK lazydocker -f %s -p %s
]==], socket_path, env.host_alias, local_copy, env.project)
end

local function open_docker(cmd)
    if cmd then
        vim.notify("LazyDocker: " .. cmd, vim.log.levels.INFO)
    end
    floating_terminal.toggle("docker", cmd, { title = "LazyDocker" })
end

-- Основная логика переключения
local function open_docker_smart()
    -- Если инстанс уже открыт (пусть даже скрыт) — просто переключаем его,
    -- не пересчитывая проект/окружения заново
    if floating_terminal.has("docker") then
        open_docker(nil)
        return
    end

    local proj = unitcode_project.resolve()
    local envs = proj and find_environments(proj) or {}

    -- Не unitcode-проект либо окружений не нашлось -> открываем как раньше
    if #envs == 0 then
        open_docker("lazydocker")
        return
    end

    vim.ui.select(envs, {
        prompt = "LazyDocker: окружение",
        format_item = function(env) return env.label end,
    }, function(env)
        if not env then return end
        open_docker(build_cmd(env) or "lazydocker")
    end)
end

vim.keymap.set("n", "<leader>d", open_docker_smart, { desc = "Smart LazyDocker Floating Window" })
