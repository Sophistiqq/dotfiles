-- Native terminal & LazyGit manager (replaces floaterm.nvim, volt, and lazygit.nvim)
local terminals = {
  float = { buf = -1, win = -1 },
  vsplit = { buf = -1, win = -1 },
  split = { buf = -1, win = -1 },
}

local function open_centered_float(buf, width_ratio, height_ratio, title)
  local w = math.floor(vim.o.columns * width_ratio)
  local h = math.floor(vim.o.lines * height_ratio)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = w,
    height = h,
    col = math.floor((vim.o.columns - w) / 2),
    row = math.floor((vim.o.lines - h) / 2),
    title = title and (" " .. title .. " ") or nil,
    title_pos = title and "center" or nil,
  })
  vim.wo[win].winhl = "Normal:Normal,NormalFloat:Normal"
  return win
end

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
    t.win = open_centered_float(t.buf, 0.9, 0.85, "Terminal")
  elseif kind == "vsplit" then
    vim.cmd("botright vsplit")
    t.win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(t.win, t.buf)
    -- 0.13+: nvim_win_resize replaces deprecated nvim_win_set_width
    vim.api.nvim_win_resize(t.win, math.floor(vim.o.columns * 0.35), -1)
  else
    vim.cmd("botright split")
    t.win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_set_buf(t.win, t.buf)
    vim.api.nvim_win_resize(t.win, -1, math.floor(vim.o.lines * 0.3))
  end

  if vim.bo[t.buf].buftype ~= "terminal" then
    vim.cmd.terminal()
  end
  vim.bo[t.buf].buflisted = false
  vim.schedule(function()
    if vim.api.nvim_win_is_valid(t.win) then
      vim.cmd("startinsert")
    end
  end)
end

-- Native floating LazyGit (replaces kdheepak/lazygit.nvim)
local lazygit = { buf = -1, win = -1 }

local function toggle_lazygit()
  if vim.api.nvim_win_is_valid(lazygit.win) then
    vim.api.nvim_win_hide(lazygit.win)
    return
  end

  if vim.fn.executable("lazygit") ~= 1 then
    vim.notify("lazygit not found in PATH", vim.log.levels.ERROR)
    return
  end

  local is_new = not vim.api.nvim_buf_is_valid(lazygit.buf)
  if is_new then
    lazygit.buf = vim.api.nvim_create_buf(false, true)
  end

  lazygit.win = open_centered_float(lazygit.buf, 0.92, 0.9, "LazyGit")
  vim.bo[lazygit.buf].buflisted = false

  if is_new or vim.bo[lazygit.buf].buftype ~= "terminal" then
    vim.fn.jobstart({ "lazygit" }, {
      term = true,
      on_exit = function()
        vim.schedule(function()
          if vim.api.nvim_win_is_valid(lazygit.win) then
            vim.api.nvim_win_close(lazygit.win, true)
          end
          if vim.api.nvim_buf_is_valid(lazygit.buf) then
            vim.api.nvim_buf_delete(lazygit.buf, { force = true })
          end
          lazygit.buf = -1
          lazygit.win = -1
        end)
      end,
    })
  end

  vim.schedule(function()
    if vim.api.nvim_win_is_valid(lazygit.win) then
      vim.cmd("startinsert")
    end
  end)
end

-- Windows- & Linux-compatible terminal keybinds
local map = vim.keymap.set
map("n", "<leader>tt", function() toggle_terminal("float") end, { desc = "Toggle float terminal" })
map("n", "<leader>tv", function() toggle_terminal("vsplit") end, { desc = "Toggle vsplit terminal" })
map("n", "<leader>ts", function() toggle_terminal("split") end, { desc = "Toggle split terminal" })

-- Ctrl+/ (Linux/macOS sends <C-/>, Windows Terminal/ConPTY sends <C-_>)
map({ "n", "t" }, "<C-/>", function() toggle_terminal("float") end, { desc = "Toggle float terminal" })
map({ "n", "t" }, "<C-_>", function() toggle_terminal("float") end, { desc = "Toggle float terminal" })

-- LazyGit
map("n", "<leader>gt", toggle_lazygit, { desc = "LazyGit UI" })
map("n", "<leader>gg", toggle_lazygit, { desc = "LazyGit UI" })

-- Safe terminal exit (<Esc><Esc> preserves single <Esc> for lazygit, fzf, vi-mode shells)
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- Seamless window navigation from terminal mode
map("t", "<C-h>", [[<C-\><C-n><C-w>h]], { desc = "Move left" })
map("t", "<C-j>", [[<C-\><C-n><C-w>j]], { desc = "Move down" })
map("t", "<C-k>", [[<C-\><C-n><C-w>k]], { desc = "Move up" })
map("t", "<C-l>", [[<C-\><C-n><C-w>l]], { desc = "Move right" })
