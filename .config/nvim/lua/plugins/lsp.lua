
-- Setup language servers.
vim.lsp.config('pyright', {
	settings = {
	    pyright = {
	      -- Using Ruff's import organizer
	      disableOrganizeImports = true,
	    },
	    python = {
	      analysis = {
	        -- Ignore all files for analysis to exclusively use Ruff for linting
	        ignore = { '*' },
	        },
		},
	},	
})

-- vim.lsp.config('tsserver', {})
vim.lsp.enable('ts_ls')
vim.lsp.config('ts_ls', {})
vim.lsp.enable('angularls')
vim.lsp.config('angularls', {})
vim.treesitter.language.register('angular', 'htmlangular')
vim.api.nvim_create_autocmd("FileType", {
  pattern = "htmlangular",
  callback = function()
    vim.treesitter.start()
  end,
})

vim.lsp.config('rust_analyzer', {
    settings = {
        ['rust-analyzer'] = {},
    },
})

vim.lsp.config('graphql', {
  cmd = { 'graphql-lsp', 'server', '-m', 'stream' },
  -- Expand filetypes to include where you actually use GraphQL 
  filetypes = { 'graphql', 'gql' },
  -- Use the new native root_markers field instead of lspconfig's util
  root_markers = { '.graphqlrc', '.graphql.config.json', 'graphql.config.json', 'package.json' },
  before_init = function(params)
    params.processId = vim.NIL
  end,
  settings = {
    ['graphql-config.load.baseDir'] = vim.fn.getcwd(), -- Forces the LS to look here
    ['graphql-config.load.legacy'] = true,             -- Helps if your config format is older
  }
})
vim.lsp.enable('graphql')


-- Setup Ruff Linter
vim.lsp.config('ruff_lsp', {
  init_options = {
    settings = {
      -- Any extra CLI arguments for `ruff` go here.
      args = {
		"--select=E,F,UP,N,I,ASYNC,S,PTH",
		"--line-length=79",
		"--respect-gitignore",  -- Исключать из сканирования файлы в .gitignore
      	"--target-version=py311"
      },
    }
  }
})

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', 'gh', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
-- vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    -- vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    
    -- vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    -- vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    -- vim.keymap.set('n', '<space>wl', function()
    --   print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    -- end, opts)
    
    vim.keymap.set({ 'n', 'v' }, '<C-.>', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  end,
})

