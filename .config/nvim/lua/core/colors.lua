
function SetColor()
    require("catppuccin").setup({
        transparent_background = true, -- включает прозрачность для всех стандартных групп
    })
    vim.cmd.colorscheme "catppuccin-macchiato"

    local groups = {
        "Normal", "NormalFloat", "NormalNC", "SignColumn",
        "MsgArea", "Pmenu", "PmenuSel", "FloatBorder",
        "TreesitterContext", "TreesitterContextLineNumber",
        "LineNr", "CursorLineNr", "FoldColumn", "StatusLine",
        "NvimTreeNormal", "Terminal"
    }

    for _, group in ipairs(groups) do
        local normal = vim.api.nvim_get_hl(0, { name = group })
        vim.api.nvim_set_hl(0, group, { fg = normal.fg, bg = "none" })
    end
end

SetColor()
