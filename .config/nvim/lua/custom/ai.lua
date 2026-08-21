-- Плавающее окно

local floating_terminal = require("custom.floating_terminal")

-- Глобальный хоткей для управления окном (работает в Normal и Terminal режимах)
vim.keymap.set("n", "<leader>a", function()
    floating_terminal.toggle("ai", "claude", {
        title = "AI",
    })
end, { desc = "Toggle AI Window" })

