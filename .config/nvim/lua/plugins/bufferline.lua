
vim.opt.termguicolors = true
require("bufferline").setup{
    options={
        offsets = {
            {
                filetype = "NvimTree",
                text = "File Explorer", -- Optional: Add custom text to the offset area
                highlight = "NvimTreeNormal", -- Important: Use the same highlight group as NvimTree
                separator = true, -- Optional: Add a separator
            },
        },
    }
}
