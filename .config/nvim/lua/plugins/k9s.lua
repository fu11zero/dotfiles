-- Вспомогательная функция для безопасного чтения вывода системных команд
local function handle_cmd(cmd)
    local f = io.popen(cmd)
    if not f then return "" end
    local result = f:read("*a")
    f:close()
    return result:gsub("%s+$", "") -- удаляем лишние переносы строк
end


-- Хранилище для экземпляра тогла
local k9s_toggle = nil

-- Функция для создания красивого плавающего окна по центру экрана
local function open_floating_terminal(cmd)

    -- Если тогл еще ни разу не вызывался — создаем его
    if not k9s_toggle then
        k9s_toggle = Snacks.terminal.toggle(cmd, {
            win = {
                wo = { winfixbuf = true },
                position = "float",
                width = math.floor(vim.o.columns * 0.8),
                height = math.floor(vim.o.lines * 0.8),
                border = "rounded",
                title = "k9s",
                title_pos = "center",
            },
        })

        -- Берем ID созданного буфера
        local buf = k9s_toggle.buf

        -- Маппинг внутри этого конкретного терминала для скрытия по <leader>s
        vim.keymap.set("t", "<leader>k", function()
            k9s_toggle:hide()
        end, { buffer = buf, nowait = true, desc = "Hide k9s" })

        -- Принудительное удержание режима Insert при фокусе буфера
        vim.api.nvim_create_autocmd({ "BufEnter", "CursorMoved" }, {
            buffer = buf,
            callback = function()
                if vim.api.nvim_get_current_buf() == buf then
                    vim.cmd("startinsert")
                end
            end,
        })

        -- Реагируем на закрытие команды
        vim.api.nvim_create_autocmd("TermClose", {
            buffer = buf,
            callback = function()
                vim.schedule(function()
                    -- Проверяем, существует ли еще окно, и закрываем его
                    if vim.api.nvim_win_is_valid(win) then
                        vim.api.nvim_win_close(win, true)
                    end

                    -- Принудительно удаляем буфер терминала, чтобы он не висел в списке (:ls)
                    if vim.api.nvim_buf_is_valid(buf) then
                        vim.api.nvim_buf_delete(buf, { force = true })
                    end

                    k9s_toggle = nil
                end)
            end
        })
    else
        -- Если тогл уже существует, просто переключаем его видимость
        k9s_toggle:toggle()
    end

end

-- Основная логика переключения
local function open_k9s_smart()
    if k9s_toggle then
        open_floating_terminal("")
        return
    end

    local is_git = os.execute("git rev-parse --is-inside-work-tree >/dev/null 2>&1")

    -- Если не git-репозиторий -> открываем список контекстов
    if is_git ~= 0 then
        open_floating_terminal("k9s --command ctx")
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
            local filter = string.format("-%s", branch)


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

            open_floating_terminal(k9s_cmd)
            return
        else
            -- Если хост unitcode, но регулярка не смогла вытащить group/project из пути
            vim.notify("Gitlab unitcode найден, но не удалось извлечь group/project из URL: " .. origin_url, vim.log.levels.WARN)
        end
    end

    -- Если gitlab другой или не удалось распарсить пути -> открываем список контекстов
    open_floating_terminal("k9s --command ctx")
end

-- Маппинг клавиши
vim.keymap.set("n", "<leader>k", open_k9s_smart, { desc = "Smart K9s Floating Window" })
