
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    {
        "willothy/flatten.nvim",
        config = true,
        -- Ensure that it runs first to minimize delay when opening file from terminal
        lazy = false,
        priority = 1001,
    },

    {
        "nvim-treesitter/nvim-treesitter",
        dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
        build = ":TSUpdate",
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

	{ 'neovim/nvim-lspconfig' },
    { 'jmbuhr/otter.nvim' },


	-- Autocomplete support
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
		'nvim-telescope/telescope.nvim', tag = 'v0.2.0',
		dependencies = {
            'nvim-lua/plenary.nvim',
            'nvim-telescope/telescope-ui-select.nvim'
        }
	},
    {
        'nat-418/boole.nvim',
        event = "VeryLazy",
        config = function()
            require('boole').setup({
                mappings = {
                    increment = '<C-a>',
                    decrement = '<C-x>'
                },
                -- Add custom toggle sets (optional)
                additions = {
                    {'+', '-'},
                    {'⬜', '✅'},
                    {'[ ]', '[x]'}
                },
                -- Enable case-insensitive matches for specific words
                allow_caps_additions = {
                    {'enable', 'disable'} -- Toggles enable -> disable, Enable -> Disable, etc.
                }
            })
        end
    },
    { "smjonas/inc-rename.nvim", opts = {} },
    {
        'stevearc/dressing.nvim',
        opts = {},
        config = function()
            require("inc_rename").setup {
              input_buffer_type = "dressing",
            }
        end
    },
    {
        "3rd/image.nvim",
        event = "VeryLazy",
        build = false,
        opts = {
            processor = "magick_cli",
        }
    },
    {
        'lewis6991/gitsigns.nvim',
        event = "VeryLazy",
        config = function()
            require('gitsigns').setup {
              current_line_blame = true,
              current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
              max_file_length = 40000, -- Disable if file is longer than this (in lines)
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
                    -- "livewire",
                    -- "angular",
                    {
                        pattern = "/(.*)/(.*)/([^/]+)%.ts$",
                        target = componentTargets,
                    },
                    -- Mapping for HTML files
                    {
                        pattern = "/(.*)/(.*)/([^/]+)%.html$",
                        target = componentTargets,
                    },
                    -- Mapping for SCSS files
                    {
                        pattern = "/(.*)/(.*)/([^/]+)%.scss$",
                        target = componentTargets,
                    },
                    -- Mapping for GraphQL files
                    {
                        pattern = "/(.*)/(.*)/([^/]+)%.gql$",
                        target = componentTargets,
                    },
                    "laravel",
                    -- "rails",
                    -- "golang",
                    "python",
                    -- "react",
                    -- "rust",
                    -- "elixir",
                    -- "clojure",
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
            require("nvim-surround").setup({

            })
        end
    },

    {
        'MeanderingProgrammer/render-markdown.nvim',
        event = "VeryLazy",
        config = function ()
            require('render-markdown').setup({
                heading = {
                    backgrounds = {},
                },
                code = {
                    style = 'language',
                    highlight = 'Normal',
                },
            })
        end
    },

    -- {
    --   "3rd/diagram.nvim",
    --   dependencies = {
    --     { "3rd/image.nvim", opts = {} },
    --   },
    --   keys = {
    --       {
    --           "K", -- or any key you prefer
    --           function()
    --               require("diagram").show_diagram_hover()
    --           end,
    --           mode = "n",
    --           ft = { "markdown", "norg" }, -- Only in these filetypes
    --           desc = "Show diagram in new tab",
    --       },
    --   },
    -- },

    {
        "wellle/targets.vim",
    },

    {
	  'nvimdev/dashboard-nvim',
	  event = 'VimEnter',
	  config = function()
	    require('dashboard').setup {
	      -- config
	    }
	  end,
	  dependencies = { {'nvim-tree/nvim-web-devicons'}}
	},

    {
        "kdheepak/lazygit.nvim",
        event = 'VeryLazy',
        cmd = {
            "LazyGit",
            "LazyGitConfig",
            "LazyGitCurrentFile",
            "LazyGitFilter",
            "LazyGitFilterCurrentFile",
        },
        keys = {
        },
        config = function()
            -- 1.0 is full screen, 0.9 is 90% of the editor size
            vim.g.lazygit_floating_window_scaling_factor = 1.0 

            -- Optional: Border style ("none", "single", "double", "rounded", "solid", "shadow")
            -- vim.g.lazygit_floating_window_border_chars = {'╭','─', '╮', '│', '╯','─', '╰', '│'}
            vim.g.lazygit_floating_window_border_chars = "none"
            vim.g.lazygit_floating_window_use_plenary = 0 -- use builtin neovim windowing
        end
    },
    {
      "LostbBlizzard/lazysql.nvim",
      opts = {},
      dependencies = {
        "MunifTanjim/nui.nvim",
      }
    },
    {
        "crnvl96/lazydocker.nvim",
        event = 'VeryLazy',
        opts = {},
        dependencies = { }
    },

	{ 'Eandrju/cellular-automaton.nvim' },
	{ 'norcalli/nvim-colorizer.lua' },

	{
	    'nvim-lualine/lualine.nvim',
	    dependencies = { 'nvim-tree/nvim-web-devicons' }
	},

	{
	  "folke/todo-comments.nvim",
	  dependencies = { "nvim-lua/plenary.nvim" },
	  opts = {
	    -- your configuration comes here
	    -- or leave it empty to use the default settings
	    -- refer to the configuration section below
	  }
	},

	{ "ellisonleao/gruvbox.nvim", priority = 1000 , config = true, opts = ...},

	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },

	{
	    'numToStr/Comment.nvim',
	    opts = {
	        -- add any options here
	    },
	    lazy = false,
	},

	{'akinsho/bufferline.nvim', version = "*", dependencies = 'nvim-tree/nvim-web-devicons'},

	{
	  "nvim-tree/nvim-tree.lua",
	  version = "*",
	  lazy = false,
	  dependencies = {
	    "nvim-tree/nvim-web-devicons",
	  },
	},

	{
	    'dense-analysis/ale',
	    config = function()
	        -- Configuration goes here.
	        local g = vim.g

            g.ale_linters = {
	        	python = {'mypy'},
	            lua = {'lua_language_server'},
	            php = {},
	        }
	    end
	},

	{ 'RRethy/vim-illuminate' },

	{
	    "vhyrro/luarocks.nvim",
	    priority = 1001, -- this plugin needs to run before anything else
	    opts = {
	        rocks = { "magick" },
	    },
	},

	{
	 "folke/trouble.nvim",
	 dependencies = { "nvim-tree/nvim-web-devicons" },
	 opts = {
	  -- your configuration comes here
	  -- or leave it empty to use the default settings
	  -- refer to the configuration section below
	 },
	},

	{'akinsho/toggleterm.nvim', version = "*", config = true},

	{ "folke/which-key.nvim", event = "VeryLazy" },

	-- Выравнивание и перемещение текста
	-- Автоматическое открытие фигурных скобок, кавычек и т.д
	{ 'echasnovski/mini.nvim', version = false },
	{ 'echasnovski/mini.move', version = false },
	{ 'echasnovski/mini.pairs', version = false },

    { "nickjvandyke/opencode.nvim", version = "*" },
})
