local floating_terminal = require("custom.floating_terminal")
local unitcode_project = require("custom.unitcode_project")

local function open_k9s(cmd)
    floating_terminal.toggle("k9s", cmd, {
        title = "k9s",
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

    local proj = unitcode_project.resolve()

    -- Не git-репозиторий unitcode -> открываем список контекстов
    if not proj then
        open_k9s("k9s --command ctx")
        return
    end

    local context = "unitcode-dev"

    local k9s_cmd = string.format(
        "k9s --context %s -n %s -c deploy",
        context, proj.namespace
    )

    -- Если ветка существует, передаем фильтр через слэш без пробелов
    if proj.branch then
        k9s_cmd = string.format(
            "k9s --context %s -n %s --command 'deployments /%s'",
            context, proj.namespace, proj.branch
        )
    end

    -- Отладочное сообщение в Neovim (показывает, что именно мы запускаем)
    vim.notify("Запуск K9s: " .. k9s_cmd, vim.log.levels.INFO)

    open_k9s(k9s_cmd)
end

-- Маппинг клавиши
vim.keymap.set("n", "<leader>k", open_k9s_smart, { desc = "Smart K9s Floating Window" })
