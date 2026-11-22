-- Native Neovim 0.13 per-directory session manager (replaces rmagatti/auto-session)
-- Uses Neovim 0.13's `vim.fs.slug()` and `vim.fs.mkdir()`
local session_dir = vim.fs.joinpath(vim.fn.stdpath("state"), "sessions")

local function session_file(cwd)
  cwd = cwd or vim.fn.getcwd()
  local slug = vim.fs.slug and vim.fs.slug(cwd) or cwd:gsub("[^%w%-_]", "_")
  return vim.fs.joinpath(session_dir, slug .. ".vim")
end

local function has_real_buffers()
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buflisted and vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= "" then
      return true
    end
  end
  return false
end

local function save_session()
  if not has_real_buffers() then
    return
  end
  if vim.fs.mkdir then
    vim.fs.mkdir(session_dir, { parents = true })
  else
    vim.fn.mkdir(session_dir, "p")
  end
  vim.cmd("silent! mksession! " .. vim.fn.fnameescape(session_file()))
end

local function restore_session()
  local file = session_file()
  if vim.uv.fs_stat(file) then
    vim.cmd("silent! source " .. vim.fn.fnameescape(file))
  end
end

local function delete_session()
  local file = session_file()
  if vim.uv.fs_stat(file) then
    vim.uv.fs_unlink(file)
    vim.notify("Deleted session for current directory", vim.log.levels.INFO)
  end
end

local group = vim.api.nvim_create_augroup("UserNativeSession", { clear = true })

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = group,
  callback = save_session,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = group,
  nested = true,
  callback = function()
    -- Skip auto-restore when files were passed on CLI, in diff mode, headless, or after 0.13 :restart
    if #vim.fn.argv() > 0 or vim.wo.diff or #vim.api.nvim_list_uis() == 0 then
      return
    end
    if vim.v.startreason == "restart" then
      return
    end
    restore_session()
  end,
})

vim.api.nvim_create_user_command("SessionSave", save_session, { desc = "Save current directory session" })
vim.api.nvim_create_user_command("SessionRestore", restore_session, { desc = "Restore current directory session" })
vim.api.nvim_create_user_command("SessionDelete", delete_session, { desc = "Delete current directory session" })
