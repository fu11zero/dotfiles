local timer = vim.uv.new_timer()
local group = vim.api.nvim_create_augroup("OptimizedAutosave", { clear = true })

-- Optimization 4: Cache Git status per buffer to avoid repeated disk searches
local function update_git_cache()
  local file_path = vim.api.nvim_buf_get_name(0)
  if file_path == "" then
    vim.b.is_git_repo = false
    return
  end
  local dir_path = vim.fn.fnamemodify(file_path, ":h")
  local git_dir = vim.fn.finddir(".git", dir_path .. ";")
  vim.b.is_git_repo = git_dir ~= ""
end

-- Optimization 1, 3, & 4: Logic for determining if we should save
local function should_save()
  -- Optimization 1: Only save if buffer is actually modified
  if not vim.bo.modified then return false end

  -- Basic guards: Check if modifiable and is a normal file (not a terminal/explorer)
  if not vim.bo.modifiable or vim.bo.readonly or vim.bo.buftype ~= "" then
    return false
  end

  -- Optimization 3: Ignore large files (> 2MB) to prevent editor lag
  local max_size =  2 * 1024 * 1024
  local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(0))
  if ok and stats and stats.size > max_size then return false end

  -- Optimization 3: Ignore specific filetypes (e.g., git commits)
  local excluded_fts = { ["gitcommit"] = true, ["TelescopePrompt"] = true }
  if excluded_fts[vim.bo.filetype] then return false end

  -- Optimization 4: Use cached Git status
  return vim.b.is_git_repo or false
end

-- Cache Git status on buffer read/entry
vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter" }, {
  group = group,
  callback = update_git_cache,
})

-- The Autosave mechanism with 500ms Debounce
local timeout = 1000
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "TextChangedP", "FocusLost" }, {
  group = group,
  callback = function()
    if not should_save() then return end

    timer:stop()
    timer:start(timeout, 0, vim.schedule_wrap(function()
      -- Final safety check before writing to disk
      if vim.api.nvim_buf_is_valid(0) and should_save() then
        vim.cmd("silent! update")
      end
    end))
  end,
})
