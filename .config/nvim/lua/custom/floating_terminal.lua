-- Единая точка для плавающих терминалов-синглтонов (k9s, lazysql и т.п.):
-- открытие/скрытие по одной и той же клавише и гарантированное закрытие
-- окна+буфера при выходе из программы, чтобы следующий вызов запускал
-- новый процесс, а не показывал пустой мёртвый буфер.

local M = {}

---@type table<string, snacks.win>
local instances = {}

--- Проверяет, есть ли уже открытый (созданный) инстанс с данным id.
---@param id string
function M.has(id)
    return instances[id] ~= nil
end

--- Открыть/переключить плавающий терминал-синглтон.
---@param id string уникальный идентификатор инструмента (например "k9s")
---@param cmd string|string[]|nil команда запуска; игнорируется, если инстанс уже существует
---@param opts table { title?, hide_key?, win? }
function M.toggle(id, cmd, opts)
    opts = opts or {}

    local inst = instances[id]
    if inst then
        -- Инстанс уже существует — просто показываем/скрываем его
        inst:toggle()
        return inst
    end

    local win = vim.tbl_deep_extend("force", {
        wo = { winfixbuf = true },
        position = "float",
        width = math.floor(vim.o.columns * 0.8),
        height = math.floor(vim.o.lines * 0.8),
        border = "rounded",
        title = opts.title or id,
        title_pos = "center",
    }, opts.win or {})

    local term = Snacks.terminal.toggle(cmd, {
        -- Закрытие полностью управляется нами (ниже), независимо от кода выхода
        auto_close = false,
        win = win,
    })

    instances[id] = term
    local buf = term.buf

    if opts.hide_key then
        vim.keymap.set("t", opts.hide_key, function()
            term:hide()
        end, { buffer = buf, nowait = true, desc = "Hide " .. (opts.title or id) })
    end

    -- Принудительное удержание режима Insert при фокусе буфера
    vim.api.nvim_create_autocmd({ "BufEnter", "CursorMoved" }, {
        buffer = buf,
        callback = function()
            if vim.api.nvim_get_current_buf() == buf then
                vim.cmd("startinsert")
            end
        end,
    })

    -- Закрываем окно и буфер при выходе из программы, чтобы следующий
    -- toggle создавал новый процесс, а не показывал мёртвый буфер
    vim.api.nvim_create_autocmd("TermClose", {
        buffer = buf,
        once = true,
        callback = function()
            vim.schedule(function()
                if instances[id] then
                    instances[id]:close()
                    instances[id] = nil
                end
            end)
        end,
    })

    return term
end

return M
