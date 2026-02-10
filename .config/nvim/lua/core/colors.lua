
function SetColor()
	-- Option 1
	-- vim.o.background = "dark"
	-- vim.cmd([[colorscheme gruvbox]])	

	-- Option 2
	vim.cmd.colorscheme "catppuccin-macchiato"

    local groups = {
        "Normal", "NormalFloat", "NormalNC", "SignColumn",
        "MsgArea", "Pmenu", "PmenuSel", "FloatBorder",
        "TreesitterContext", "TreesitterContextLineNumber",
        "LineNr", "CursorLineNr", "FoldColumn", "StatusLine",
        "NvimTreeNormal"
    }

    for _, group in ipairs(groups) do
        vim.api.nvim_set_hl(0, group, { bg = "none" })
    end
end

SetColor()
