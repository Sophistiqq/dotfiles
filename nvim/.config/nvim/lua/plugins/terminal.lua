local terminals = {
  float  = { buf = -1, win = -1 },
  vsplit = { buf = -1, win = -1 },
  split  = { buf = -1, win = -1 },
}

local function toggle_terminal(kind)
  local t = terminals[kind]

  if vim.api.nvim_win_is_valid(t.win) then
    vim.api.nvim_win_hide(t.win)
    return
  end

  if not vim.api.nvim_buf_is_valid(t.buf) then
    t.buf = vim.api.nvim_create_buf(false, true)
  end

  if kind == "float" then
    local w = math.floor(vim.o.columns * 0.9)
    local h = math.floor(vim.o.lines * 0.85)
    t.win = vim.api.nvim_open_win(t.buf, true, {
      relative = "editor",
      width = w,
      height = h,
      col = math.floor((vim.o.columns - w) / 2),
      row = math.floor((vim.o.lines - h) / 2),
    })
    -- inherit normal editor colors instead of NormalFloat
    vim.wo[t.win].winhl = "Normal:Normal,NormalFloat:Normal"
  elseif kind == "vsplit" then
    vim.cmd("botright vsplit")
    t.win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_width(t.win, math.floor(vim.o.columns * 0.35))
    vim.api.nvim_win_set_buf(t.win, t.buf)
  else
    vim.cmd("botright split")
    t.win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(t.win, t.buf)
  end

  if vim.bo[t.buf].buftype ~= "terminal" then vim.cmd.terminal() end
  vim.bo[t.buf].buflisted = false
  vim.schedule(function() vim.cmd("startinsert") end)
end

local map = function(k, kind)
  vim.keymap.set({ "n", "t" }, k, function() toggle_terminal(kind) end, { desc = "Toggle " .. kind .. " terminal" })
end

map("<M-`>", "float")
map("<M-v>", "vsplit")
map("<M-h>", "split")
vim.keymap.set({ "n", "t" }, "<M-Left>", "<C-\\><C-n><C-w>h", { desc = "Move left" })
vim.keymap.set({ "n", "t" }, "<M-Right>", "<C-\\><C-n><C-w>l", { desc = "Move right" })
vim.keymap.set({ "n", "t" }, "<M-Up>", "<C-\\><C-n><C-w>k", { desc = "Move up" })
vim.keymap.set({ "n", "t" }, "<M-Down>", "<C-\\><C-n><C-w>j", { desc = "Move down" })
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { noremap = true })
