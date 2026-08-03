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

vim.keymap.set('n','<M-l>', ':BufferLineCycleNext<CR>')
vim.keymap.set('n','<M-h>', ':BufferLineCyclePrev<CR>')
vim.keymap.set('n','<M-S-l>', ':BufferLineMoveNext<CR>')
vim.keymap.set('n','<M-S-h>', ':BufferLineMovePrev<CR>')
vim.keymap.set('n', '<C-q>', ':bp|bd #<CR>', { silent = true })
vim.keymap.set('n', '<C-S-Q>', ':BufferLineCloseOthers<CR>')

