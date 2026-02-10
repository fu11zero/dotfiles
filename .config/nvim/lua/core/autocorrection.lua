local null_ls = require('null-ls')
local cspell = require('cspell')

null_ls.setup({
    sources = {
        -- This adds spell checking specifically for code
        cspell.diagnostics.with({
            -- Tell it to only look at specific files
            -- filetypes = { "javascript", "typescript", "lua" },
        }),
        -- This enables the "fix" command
        cspell.code_actions,
    },
    -- Optional: Auto-fix keywords on save
    on_attach = function(client, bufnr)
    end,
})

-- Automatically fix keyword typos when leaving Insert Mode
vim.api.nvim_create_autocmd("InsertLeave", {
    -- pattern = { "*.js", "*.ts" },
    callback = function()
        -- Small delay to allow none-ls/cspell to update diagnostics
        vim.defer_fn(function()
            local bufnr = vim.api.nvim_get_current_buf()
            local diagnostics = vim.diagnostic.get(bufnr)

            for _, diagnostic in ipairs(diagnostics) do
                -- Only target cspell errors (your keyword typos)
                if diagnostic.source == "cspell" then
                    vim.lsp.buf.code_action({
                        context = { diagnostics = { diagnostic } },
                        apply = true,
                        -- This filter ensures we only apply 'Preferred' fixes automatically
                        filter = function(action)
                            return action.isPreferred or action.title:match("Fix spelling")
                        end,
                    })
                end
            end
        end, 1000) -- 100ms delay for background processing
    end,
})
