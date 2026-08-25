-- Общая логика сопоставления git-репозитория (gitlab.unitcode.ru) с
-- namespace кластера unitcode-dev. Используется k9s.lua и database.lua,
-- чтобы обе "умные" команды резолвили один и тот же проект одинаково.

local M = {}

local function handle_cmd(cmd)
    local f = io.popen(cmd .. " 2>/dev/null")
    if not f then return "" end
    local result = f:read("*a")
    f:close()
    return result:gsub("%s+$", "")
end

--- Пытается определить unitcode-dev namespace и текущую ветку для git-репозитория
--- в текущей директории.
---@return table|nil { group, project, namespace, branch } или nil, если это не
---        git-репозиторий с origin на gitlab.unitcode.ru
function M.resolve()
    local is_git = os.execute("git rev-parse --is-inside-work-tree >/dev/null 2>&1")
    if is_git ~= 0 then
        return nil
    end

    local origin_url = handle_cmd("git config --get remote.origin.url")
    if not origin_url:find("gitlab%.unitcode%.ru") then
        return nil
    end

    local group, project = origin_url:match("unitcode%.ru[/:]([^/]+)/([^/]+)")
    if not (group and project) then
        return nil
    end
    project = project:gsub("%.git$", "")

    local branch = handle_cmd("git branch --show-current")

    -- "unitcode" — основная группа/домен, для её проектов неймспейс равен
    -- просто имени проекта (без префикса группы), например stride -> stride,
    -- а не unitcode-stride. Для остальных групп префикс сохраняется, как apc-monitoring.
    local namespace = project
    if group ~= "unitcode" then
        namespace = string.format("%s-%s", group, project)
    end

    return {
        group = group,
        project = project,
        namespace = namespace,
        branch = branch ~= "" and branch or nil,
        origin_url = origin_url,
    }
end

return M
