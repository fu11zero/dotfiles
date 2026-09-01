-- Общая логика поиска docker-compose проекта: локально (в текущем
-- git-репозитории) и на проде (по ssh-алиасу хоста, найденному по пути
-- проекта в gitlab). Используется custom.database (для БД) и
-- custom.docker (для lazydocker) — чтобы не дублировать поиск хоста и
-- compose-файла в двух местах.

local M = {}

function M.handle_cmd(cmd)
    local f = io.popen(cmd .. " 2>/dev/null")
    if not f then return "" end
    local result = f:read("*a")
    f:close()
    return result:gsub("%s+$", "")
end

function M.read_file(path)
    local f = io.open(path, "r")
    if not f then return nil end
    local content = f:read("*a")
    f:close()
    return content
end

---@return string|nil путь к записанному временному файлу
function M.write_temp_file(content, suffix)
    local path = vim.fn.tempname() .. (suffix or "")
    local f = io.open(path, "w")
    if not f then return nil end
    f:write(content)
    f:close()
    return path
end

--- Корень текущего git-репозитория (для local-окружения).
---@return string|nil
function M.find_local_project_root()
    local root = M.handle_cmd("git rev-parse --show-toplevel")
    return root ~= "" and root or nil
end

--- Ищет compose.yaml/docker-compose.yml в корне проекта.
---@return string|nil путь к compose-файлу
function M.find_local_compose_path(root)
    for _, name in ipairs({ "compose.yaml", "compose.yml", "docker-compose.yaml", "docker-compose.yml" }) do
        local path = root .. "/" .. name
        if M.read_file(path) then
            return path
        end
    end
    return nil
end

--- Алиасы хостов из ssh-конфига архитектуры (~/.ssh/unitcode/conf/, см.
--- ~/Projects/unitcode/architecture) — unsorted.conf сознательно
--- пропускаем, это временный черновик.
---@return table<string, boolean>
function M.list_ssh_hosts()
    local raw = M.handle_cmd([[for f in ~/.ssh/unitcode/conf/*.conf; do [ "$(basename "$f")" = "unsorted.conf" ] && continue; grep -h "^Host " "$f"; done]])
    local hosts = {}
    for line in raw:gmatch("[^\r\n]+") do
        for alias in line:gmatch("%S+") do
            if alias ~= "Host" then
                hosts[alias] = true
            end
        end
    end
    return hosts
end

--- Ищет ssh-алиас продакшн-хоста проекта по группе/проекту gitlab:
--- "group.project" (unitcode/stride -> unitcode.stride), затем просто
--- "group", затем просто "project" — так покрывается и unitcode.stride,
--- и, например, dubrava/backend -> dubrava.
---@return string|nil
function M.find_prod_host_alias(group, project)
    local hosts = M.list_ssh_hosts()
    for _, candidate in ipairs({ group .. "." .. project, group, project }) do
        if hosts[candidate] then
            return candidate
        end
    end
    return nil
end

--- Выполняет разведывательную команду на хосте. Некоторые хосты в
--- ~/.ssh/unitcode/conf/ объявляют RemoteCommand (авто-cd в директорию
--- проекта), а ssh отказывается сочетать его с командой из командной
--- строки — поэтому явно его отключаем.
function M.ssh_run(host_alias, remote_cmd)
    return M.handle_cmd(string.format(
        "ssh -o RemoteCommand=none %s '%s'",
        host_alias, remote_cmd
    ))
end

--- Ищет docker-compose файл проекта на хосте, сперва по стандартному пути
--- /data/<project>/, затем более широким поиском по /data.
---@return string|nil путь к compose-файлу на удалённом хосте
function M.find_remote_compose_path(host_alias, project)
    local fast = string.format(
        [[for f in /data/%s/compose.yaml /data/%s/compose.yml /data/%s/docker-compose.yaml /data/%s/docker-compose.yml; do [ -f "$f" ] && echo "$f" && break; done]],
        project, project, project, project
    )
    local path = M.ssh_run(host_alias, fast)
    if path ~= "" then return path end

    local wide = string.format(
        [[find /data -maxdepth 2 \( -path '*/%s/compose.y*ml' -o -path '*/%s/docker-compose*.y*ml' \) 2>/dev/null | head -1]],
        project, project
    )
    path = M.ssh_run(host_alias, wide)
    return path ~= "" and path or nil
end

return M
