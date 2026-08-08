
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    ui = {
        border = "rounded",
    },

    {
        "willothy/flatten.nvim",
        config = true,
        lazy = false,
        priority = 1001,
    },

    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
        build = ":TSUpdate",
    },

    { 'neovim/nvim-lspconfig' },
    { 'jmbuhr/otter.nvim' },

    -- Autocomplete
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/cmp-buffer' },
    { 'hrsh7th/cmp-path' },
    { 'hrsh7th/cmp-cmdline' },
    { 'hrsh7th/nvim-cmp' },
    { 'williamboman/mason.nvim' },
    { 'kevinhwang91/nvim-ufo', dependencies = { 'kevinhwang91/promise-async', 'luukvbaal/statuscol.nvim' }},

    { "tpope/vim-abolish" },
    { "nvimtools/hydra.nvim" },

    {
        'nat-418/boole.nvim',
        event = "VeryLazy",
        config = function()
            require('boole').setup({
                mappings = {
                    increment = '<C-a>',
                    decrement = '<C-x>'
                },
                additions = {
                    {'+', '-'},
                    {'⬜', '✅'},
                    {'[ ]', '[x]'}
                },
                allow_caps_additions = {
                    {'enable', 'disable'}
                }
            })
        end
    },

    -- { "smjonas/inc-rename.nvim", opts = {} },

    {
        'lewis6991/gitsigns.nvim',
        event = "VeryLazy",
        config = function()
            require('gitsigns').setup {
                current_line_blame = true,
                -- current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
                max_file_length = 40000,
            }
        end
    },

    {
        'rgroli/other.nvim',
        event = "VeryLazy",
        config = function()
            local componentTargets = {
                { target = "/%1/%2/%3.ts", context = "component" },
                { target = "/%1/%2/%3.html", context = "html" },
                { target = "/%1/%2/%3.scss", context = "scss" },
                { target = "/%1/%2/%3.gql", context = "graphql" },
                { target = "/%1/%2/%3.spec.ts", context = "test" },
            }
            require('other-nvim').setup({
                mappings = {
                    {
                        pattern = "/(.*)/(.*)/([^/]+)%.ts$",
                        target = componentTargets,
                    },
                    {
                        pattern = "/(.*)/(.*)/([^/]+)%.html$",
                        target = componentTargets,
                    },
                    {
                        pattern = "/(.*)/(.*)/([^/]+)%.scss$",
                        target = componentTargets,
                    },
                    {
                        pattern = "/(.*)/(.*)/([^/]+)%.gql$",
                        target = componentTargets,
                    },
                    "laravel",
                    "python",
                },
            })

            vim.api.nvim_set_keymap("n", "goh", "<cmd>:Other html<CR>", { noremap = true, silent = true })
            vim.api.nvim_set_keymap("n", "goT", "<cmd>:Other test<CR>", { noremap = true, silent = true })
            vim.api.nvim_set_keymap("n", "gos", "<cmd>:Other scss<CR>", { noremap = true, silent = true })
            vim.api.nvim_set_keymap("n", "got", "<cmd>:Other component<CR>", { noremap = true, silent = true })
            vim.api.nvim_set_keymap("n", "gog", "<cmd>:Other graphql<CR>", { noremap = true, silent = true })
        end
    },

    {
        "kylechui/nvim-surround",
        version = "^3.0.0",
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup({})
        end
    },

    {
        'MeanderingProgrammer/render-markdown.nvim',
        event = "VeryLazy",
        config = function ()
            require('render-markdown').setup({
                heading = { backgrounds = {} },
                code = { style = 'language', highlight = 'Normal' },
                anti_conceal = { enabled = false },
            })
        end
    },

    {
        "wellle/targets.vim",
    },

    {
        "chrisgrieser/nvim-various-textobjs", event = "VeryLazy",
        opts = {
            keymaps = {
                useDefaults = true,
            }
        },
        keys = {
            -- Swap 's' for subword (inner/outer)
            { "is", '<cmd>lua require("various-textobjs").subword("inner")<CR>', mode = { "o", "x" }, desc = "Inner subword" },
            { "as", '<cmd>lua require("various-textobjs").subword("outer")<CR>', mode = { "o", "x" }, desc = "Outer subword" },

            -- Swap 'S' for sentence (inner/outer)
            { "iS", '<cmd>lua require("various-textobjs").sentence("inner")<CR>', mode = { "o", "x" }, desc = "Inner sentence" },
            { "aS", '<cmd>lua require("various-textobjs").sentence("outer")<CR>', mode = { "o", "x" }, desc = "Outer sentence" },
        },
    },

    {
        "crnvl96/lazydocker.nvim",
        event = 'VeryLazy',
        opts = {
            window = {
                settings = {
                    width = 1, -- Percentage of screen width (0 to 1)
                    height = 1, -- Percentage of screen height (0 to 1)
                    -- border = 'rounded', -- See ':h nvim_open_win' border options
                    -- relative = 'editor', -- See ':h nvim_open_win' relative options
                }
            }
        },
        dependencies = { }
    },

    { 'norcalli/nvim-colorizer.lua' },

    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' }
    },

    {
      "folke/todo-comments.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = {}
    },

    { "catppuccin/nvim", name = "catppuccin", priority = 1000 },

    {
        'numToStr/Comment.nvim',
        opts = {},
        lazy = false,
    },

    {'akinsho/bufferline.nvim', version = "*", dependencies = 'nvim-tree/nvim-web-devicons'},

    {
      "nvim-tree/nvim-tree.lua",
      version = "*",
      lazy = false,
      dependencies = { "nvim-tree/nvim-web-devicons" },
    },

    {
        'dense-analysis/ale',
        config = function()
            local g = vim.g
            g.ale_linters = {
                python = {'mypy'},
                lua = {'lua_language_server'},
                php = {},
            }
        end
    },

    {
        "vhyrro/luarocks.nvim",
        priority = 1001,
        opts = {
            rocks = { "magick" },
        },
    },

    {
     "folke/trouble.nvim",
     dependencies = { "nvim-tree/nvim-web-devicons" },
     opts = {},
    },

    -- { 'akinsho/toggleterm.nvim', version = "*", config = true },

    { "folke/which-key.nvim", event = "VeryLazy" },

    { 'echasnovski/mini.nvim', version = false },
    { 'echasnovski/mini.move', version = false },
    { 'echasnovski/mini.pairs', version = false },

    { "nickjvandyke/opencode.nvim", version = "*" },

    {
      "folke/snacks.nvim",
      priority = 1000,
      lazy = false,
      ---@type snacks.Config
      opts = {
        bigfile = { enabled = true },
        dashboard = { enabled = false },
        explorer = { enabled = false },
        indent = { enabled = true },
        input = { enabled = true },
        picker = { enabled = true },
        notifier = { enabled = true },
        quickfile = { enabled = true },
        scope = { enabled = true },
        scroll = { enabled = true },
        statuscolumn = { enabled = true },
        words = { enabled = true },
        lazygit = { enabled = true },
        terminal = { enabled = true },
        image = {
          enabled = true,
          -- processor = "magick_cli",
          -- formats = { "png", "jpg", "jpeg", "gif", "bmp", "webp", "tiff", "heic", "avif", "mp4", "mov", "avi", "mkv", "webm", "pdf", "icns" },
        },
        bufdelete = { enabled = true },
        git = { enabled = true },
        gh = {
            enabled = true,
            highlights = { enabled = false }
        },
        gitbrowse = { enabled = true },
        rename = { enabled = true },
        zen = { enabled = true },
        animate = { enabled = true },
        dim = { enabled = true },
        keymap = { enabled = true },
        toggle = { enabled = true },
        win = { enabled = true },
      },
      keys = {
          { "<leader>o", function() Snacks.picker.projects() end, desc = "Projects" },
          { "<leader><space>", function() Snacks.picker.files() end, desc = "Find Files" },
        -- { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
        { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
        { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
        { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
        { "<leader>;", function() Snacks.picker.resume() end, desc = "Resme previous picker" },
        { "<leader>t", function() Snacks.picker.todo_comments() end, desc = "Open TODO picker" },
        { "<leader>h", function() Snacks.picker.undo() end, desc = "Open history" },
        { "<leader>m", function() Snacks.picker.marks({global = false, ['local'] = true}) end, desc = "Command History" },
        { "<leader>M", function() Snacks.picker.marks({global = true, ['local'] = false}) end, desc = "Command History" },
        -- { "<leader>N", function() Snacks.picker.notifications() end, desc = "Notification History" },
        -- { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },
        -- { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
        { "<leader>r", function() Snacks.picker.recent({ filter = { cwd = true }}) end, desc = "Recent" },
        -- { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
        -- { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
        { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
        { "g*", function() Snacks.picker.grep_word() end, desc = "Git Branches" },
        -- { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Visual selection or word", mode = { "n", "x" } },
        -- { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command History" },
        { "<leader>gd", function() Snacks.picker.diagnostics_bufffer() end, desc = "Diagnostics" },
        -- { "<leader>gh", function() Snacks.picker.help() end, desc = "Help Pages" },
        -- { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
        { "<leader>gm", function() Snacks.picker.marks() end, desc = "Marks" },
        { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
        { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
        { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
        { "gt", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto Type Definition" },
        { "gs", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
        { "gS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Symbols" },
        { "<leader>z",  function() Snacks.zen() end, desc = "Toggle Zen Mode" },
        { "<leader>Z",  function() Snacks.zen.zoom() end, desc = "Toggle Zoom" },
        { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
        { "<leader>N",  function() Snacks.notifier.show_history() end, desc = "Notification History" },
        { "<leader>b", function() Snacks.git.blame_line() end, desc = "Blame line" },
        -- { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File" },
        -- { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" } },
        -- { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
        { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
        { "<c-/>",      function() Snacks.terminal() end, desc = "Toggle Terminal" , mode = { "n", "v", "i", "t" }},
        { "<c-t>",      function() Snacks.terminal.open() end, desc = "Toggle Terminal" , mode = { "t" }},
        { "<c-q>",      function() Snacks.terminal.close() end, desc = "Close Terminal" , mode = { "t" }},
        { "]]",         function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
        { "[[",         function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
      },
      init = function()
        vim.api.nvim_create_autocmd("User", {
          pattern = "VeryLazy",
          callback = function()
            _G.dd = function(...)
              Snacks.debug.inspect(...)
            end
            _G.bt = function()
              Snacks.debug.backtrace()
            end
          end,
        })
      end,
    },

    {
        "joryeugene/dadbod-grip.nvim",
        version = "*",
        opts = {
            limit            = 22,      -- default row limit for SELECT queries
            -- max_col_width    = 40,       -- max display width per column
            -- timeout          = 30000,    -- query timeout in ms (default: 10000; raise for slow tunnels)
            -- completion       = true,     -- set false to use blink.cmp/nvim-cmp instead
            -- connections_path = nil,      -- absolute path to a shared connections.json file
            border           = "rounded",
            picker           = "builtin",-- "builtin", "telescope", or "snacks"
            cell_split       = "horizontal", -- gB cell buffer: "horizontal" or "vertical" split
            sticky_header    = true,     -- keep the column names visible while scrolling (set false to reclaim the line)
        }
    },

    -- {
    --     "sphamba/smear-cursor.nvim",
    --     opts = {
    --         smear_between_buffers = true,
    --         smear_between_neighbor_lines = true,
    --         scroll_buffer_space = true,
    --         legacy_computing_symbols_support = false,
    --         smear_insert_mode = true,
    --         time_interval = 7,
    --
    --         -- stiffness = 0.8,                      -- 0.6      [0, 1]
    --         -- trailing_stiffness = 0.6,             -- 0.45     [0, 1]
    --         -- stiffness_insert_mode = 0.7,          -- 0.5      [0, 1]
    --         -- trailing_stiffness_insert_mode = 0.7, -- 0.5      [0, 1]
    --         -- damping = 0.95,                       -- 0.85     [0, 1]
    --         -- damping_insert_mode = 0.95,           -- 0.9      [0, 1]
    --         -- distance_stop_animating = 0.5,        -- 0.1      > 0
    --     },
    -- }

    -- {
    --     "harrisoncramer/gitlab.nvim",
    --     -- branch = "main", -- Uncomment to use a stable version. The default, possibly unstable, but more actively maintained branch is `develop`.
    --     dependencies = {
    --         "MunifTanjim/nui.nvim",
    --         "dlyongemallo/diffview-plus.nvim", -- Maintained fork of "sindrets/diffview.nvim".
    --         "stevearc/dressing.nvim", -- Recommended but not required. Better UI for pickers.
    --         "nvim-tree/nvim-web-devicons", -- Recommended but not required. Icons in discussion tree.
    --     },
    --     ---@type GitlabSettings
    --     opts = {}, -- Your configuration
    -- }

})
