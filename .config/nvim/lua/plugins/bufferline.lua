vim.opt.termguicolors = true

vim.api.nvim_set_hl(0, "GitIconOrange", { fg = "#F1502F" })
vim.api.nvim_set_hl(0, "GitlabIconOrange", { fg = "#FF8800" })
vim.api.nvim_set_hl(0, "GithubIconOrange", { fg = "#24292e" })

local function get_project_status()
    local git_icon = "%#GitlabIconOrange# %*"
    local gitlab_icon = "%#GitlabIconOrange# %*"
    local github = "%#GithubIconOrange# %*"
    local folder_icon = " "

    -- Выполняем команду git для получения URL upstream (или origin, если upstream нет)
    local git_remote = vim.fn.systemlist("git config --get remote.upstream.url")
    if vim.v.shell_error ~= 0 or #git_remote == 0 then
        git_remote = vim.fn.systemlist("git config --get remote.origin.url")
    end

    -- Если это не git-репозиторий или у него нет удаленного адреса
    if vim.v.shell_error ~= 0 or #git_remote == 0 then
        local current_dir = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
        -- local parent_dir = vim.fn.fnamemodify(vim.fn.getcwd(), ":h:t")
        return folder_icon .. current_dir
    end

    local path = git_remote[1] or ""

    -- Обрезаем хост
    -- Если формат SSH (git@gitlab.unitcode.ru:apc/...) — удаляем всё до двоеточия включительно
    if path:match("^[^:]+:") and not path:match("^https?://") then
        path = path:gsub("^[^:]+:", "")
        -- Если формат HTTPS (https://unitcode.ru...) — удаляем протокол и домен до слэша
    elseif path:match("^https?://") then
        path = path:gsub("^https?://[^/]+/", "")
    end

    local icon = git_icon
    local host = git_remote[1]
    if host:match("gitlab") then
        icon = gitlab_icon
    elseif host:match("github") then
        icon = github_icon
    end

    -- Удаляем расширение .git в конце
    path = path:gsub("%.git$", "")

    -- Обрезаем слова backend, frontend, back, front на конце пути
    -- path = path:gsub("[/%%-](backend)$", "")
    --            :gsub("[/%%-](frontend)$", "")
    --            :gsub("[/%%-](back)$", "")
    --            :gsub("[/%%-](front)$", "")

    return icon .. path
end

require("bufferline").setup{
    options={
        separator_style = 'thin',
        indicator = {
            style = 'underline',
        },
        diagnostics = 'nvim_lsp',
        diagnostics_indicator = function(count, level)
            local icon = level:match("error") and " " or " "
            return " " .. icon .. count
        end,
        offsets = {
            {
                filetype = "NvimTree",
                text = get_project_status,
                text_align = 'left',
                highlight = "Directory",
                separator = true
            }
        },
    },
    highlights = {
    },
}

-- ПАТЧ bufferline: исправляет расчёт ширины offset (см. ниже)
local offset_mod = require("bufferline.offset")
local utils = require("bufferline.utils")

-- bufferline меряет текст offset через nvim_strwidth(), который не понимает
-- statusline-эскейпы %#...# и %* и считает их как обычные символы. Из-за этого
-- видимый offset уже окна nvim-tree. Здесь измеряем только видимую ширину.
local function visible_width(s)
    if not s then return 0 end
    s = s:gsub("%%#.-#", "")
    s = s:gsub("%%%*", "")
    return vim.api.nvim_strwidth(s)
end

-- Копия внутренней get_section_text из bufferline/offset.lua с заменой
-- api.nvim_strwidth(text) на visible_width(text).
local function fixed_get_section_text(size, highlight, offset, is_left)
    local text = offset.text
    if type(text) == "function" then text = text() end
    text = text or string.rep(" ", size - 2)

    local text_size, left, right = visible_width(text), 0, 0
    local alignment = offset.text_align or "center"

    if text_size + 2 >= size then
        text, left, right = utils.truncate_name(text, size - 2), 1, 1
    else
        local remainder = size - text_size
        local is_even, side = remainder % 2 == 0, remainder / 2
        if alignment == "center" then
            if not is_even then
                left, right = math.ceil(side), math.floor(side)
            else
                left, right = side, side
            end
        elseif alignment == "left" then
            left, right = 1, remainder - 1
        else
            left, right = remainder - 1, 1
        end
    end
    local str = highlight.text .. string.rep(" ", left) .. text .. string.rep(" ", right)
    if not offset.separator then return str end

    local sep_icon = type(offset.separator) == "string" and offset.separator or "│"
    local sep = highlight.sep .. sep_icon
    return (not is_left and sep or "") .. str .. (is_left and sep or "")
end

-- Подменяем локальную функцию get_section_text в загруженном модуле
-- bufferline.offset через upvalue (наружу она не экспортируется).
for i = 1, 41 do
    local name = debug.getupvalue(offset_mod.get, i)
    if not name then break end
    if name == "get_section_text" then
        debug.setupvalue(offset_mod.get, i, fixed_get_section_text)
        break
    end
end
-- /ПАТЧ bufferline: исправляет расчёт ширины offset (см. ниже)


vim.keymap.set({'n', 'v', 'i', 't'}, '<M-l>', ':BufferLineCycleNext<CR>')
vim.keymap.set({'n', 'v', 'i', 't'}, '<M-h>', ':BufferLineCyclePrev<CR>')
vim.keymap.set({'n', 'v', 'i', 't'}, '<M-S-l>', ':BufferLineMoveNext<CR>')
vim.keymap.set({'n', 'v', 'i', 't'}, '<M-S-h>', ':BufferLineMovePrev<CR>')
vim.keymap.set({'n', 'v', 'i', 't'}, '<C-q>', ':bp|bd #<CR>', { silent = true })
vim.keymap.set({'n', 'v', 'i', 't'}, '<C-S-Q>', ':BufferLineCloseOthers<CR>')

