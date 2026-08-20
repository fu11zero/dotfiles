local floating_terminal = require("custom.floating_terminal")

-- Вспомогательная функция для безопасного чтения вывода системных команд
local function handle_cmd(cmd)
    local f = io.popen(cmd)
    if not f then return "" end
    local result = f:read("*a")
    f:close()
    return result:gsub("%s+$", "") -- удаляем лишние переносы строк
end

local function open_k9s(cmd)
    floating_terminal.toggle("k9s", cmd, {
        title = "k9s",
        hide_key = "<C-k>",
    })
end

-- Основная логика переключения
local function open_k9s_smart()
    -- Если инстанс уже открыт (пусть даже скрыт) — просто переключаем его,
    -- не пересчитывая контекст/ветку заново
    if floating_terminal.has("k9s") then
        open_k9s(nil)
        return
    end

    local is_git = os.execute("git rev-parse --is-inside-work-tree >/dev/null 2>&1")

    -- Если не git-репозиторий -> открываем список контекстов
    if is_git ~= 0 then
        open_k9s("k9s --command ctx")
        return
    end

    local origin_url = handle_cmd("git config --get remote.origin.url")
    local branch = handle_cmd("git branch --show-current")

    -- Проверяем хост gitlab.unitcode.ru
    if origin_url:find("gitlab%.unitcode%.ru") then
        local group, project = origin_url:match("unitcode%.ru[/:]([^/]+)/([^/]+)")
        if project then
            project = project:gsub("%.git$", "")
        end

        if group and project then
            local context = "unitcode-dev"
            local namespace = string.format("%s-%s", group, project)

            local k9s_cmd = string.format(
                "k9s --context %s -n %s -c deploy",
                context, namespace
            )

            -- Если ветка существует, передаем фильтр через слэш без пробелов
            if branch ~= "" then
                k9s_cmd = string.format(
                    "k9s --context %s -n %s --command 'deployments /%s'",
                    context, namespace, branch
                )
            end

            -- Отладочное сообщение в Neovim (показывает, что именно мы запускаем)
            vim.notify("Запуск K9s: " .. k9s_cmd, vim.log.levels.INFO)

            open_k9s(k9s_cmd)
            return
        else
            -- Если хост unitcode, но регулярка не смогла вытащить group/project из пути
            vim.notify("Gitlab unitcode найден, но не удалось извлечь group/project из URL: " .. origin_url, vim.log.levels.WARN)
        end
    end

    -- Если gitlab другой или не удалось распарсить пути -> открываем список контекстов
    open_k9s("k9s --command ctx")
end

-- Маппинг клавиши
vim.keymap.set("n", "<C-k>", open_k9s_smart, { desc = "Smart K9s Floating Window" })
