
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
        vim.api.nvim_set_hl(0, group, { bg = "none" })
    end
end

SetColor()
