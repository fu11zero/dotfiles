
require('nvim-treesitter').setup {
    
    ensure_installed = "all",

 --  ensure_installed = {
 --    "bash",
	-- "css",
	-- "dockerfile",
	-- "html",
    -- "javascript",
    -- "typescript",
    -- "angular",
	-- "json",
	-- "json5",
	-- "lua",
	-- "python",
	-- "vim",
	-- "yaml",
	-- "c",
	-- "go",
	-- "rust",
	-- },

  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
  },
}

