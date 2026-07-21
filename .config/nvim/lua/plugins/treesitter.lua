
local function set_angular_filetype()
  -- Ищем признаки Angular проекта (angular.json или nx.json)
  local root = vim.fs.find({'angular.json', 'nx.json'}, { upward = true, stop = vim.loop.os_homedir() })[1]
  if root then
    vim.opt_local.filetype = "htmlangular"
  end
end

vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*.html",
  callback = set_angular_filetype,
})

vim.treesitter.language.register('angular', 'htmlangular')
vim.api.nvim_create_autocmd("FileType", {
  pattern = "htmlangular",
  callback = function()
    vim.treesitter.start()
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.treesitter.start()
  end,
})

vim.filetype.add({
  pattern = {
    [".*/[Ss]cripts/.*%.c"] = "enforce",
  },
})

vim.treesitter.language.register('enforce', 'enforce')
vim.api.nvim_create_autocmd("FileType", {
  pattern = "enforce",
  callback = function()
    vim.treesitter.start()
  end,
})

require('nvim-treesitter').setup {

    ensure_installed = {
        "ecma",
        "enforce",
        "jsx",
        "html_tags",
        "bash",
        "dbml",
        "ecma",
        "css",
        "scss",
        "less",
        "dockerfile",
        "html",
        "html_tags",
        "htmlangular",
        "javascript",
        "typescript",
        "angular",
        "json",
        "json5",
        "lua",
        "python",
        "vim",
        "yaml",
        "c",
        "go",
        "rust",
        "markdown",
        "markdown_inline",
        "embedded_template",
    },

    sync_install = false,
    auto_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
        markdown = true,
        markdown_inline = true,
    },
    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                -- Функции
                -- ["af"] = "@function.outer",
                -- ["if"] = "@function.inner",
                -- Классы
                -- ["ac"] = "@class.outer",
                -- ["ic"] = "@class.inner",
                -- Параметры/Аргументы
                -- ["aa"] = "@parameter.outer",
                -- ["ia"] = "@parameter.inner",
                -- Условия (if/else)
                -- ["ai"] = "@conditional.outer",
                -- ["ii"] = "@conditional.inner",
            },
            selection_modes = {
                ['@parameter.outer'] = 'v',
                ['@function.outer'] = 'V',
                ['@class.outer'] = '<c-v>',
            },
        },
    },
}

