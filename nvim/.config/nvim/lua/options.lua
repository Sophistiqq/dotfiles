----- [ Globals ] -----
local g = vim.g

g.mapleader = " "
g.maplocalleader = " "

-- In Neovim 0.13, `netrw` is no longer loaded by default; the built-in `dir`
-- plugin is. Disable it while using nvim-tree (remove this line to use native `dir`).
g.loaded_nvim_dir_plugin = 1

----- [ Built-in Neovim 0.12 / 0.13 Opt-In Packages & UI2 ] -----
pcall(vim.cmd.packadd, "nohlsearch")     -- Auto-clear search highlights on cursor move
pcall(vim.cmd.packadd, "nvim.undotree")  -- Built-in visual :Undotree
pcall(vim.cmd.packadd, "nvim.difftool")  -- Built-in :DiffTool for files & directories

-- Experimental Neovim 0.12/0.13 UI2 (eliminates "Press ENTER" prompts + live cmdline highlight)
pcall(function()
  require("vim._core.ui2").enable()
end)

----- [ Options ] -----
local o = vim.opt

o.number = true
o.expandtab = true
o.shiftwidth = 2
o.softtabstop = 2
o.tabstop = 2
o.signcolumn = "yes"
o.winborder = "single"
o.pumborder = "single"
o.smartindent = true
o.clipboard = "unnamedplus"
o.fillchars = {
  eob = " ",
  horiz = "─",
  horizup = "┴",
  horizdown = "┬",
  vert = "│",
  vertleft = "┤",
  vertright = "├",
  verthoriz = "┼",
}
o.laststatus = 3

-- Crisp, theme-adaptive split pane separators (works cleanly with laststatus = 3 & transparency)
local function set_win_separator()
  local border = vim.api.nvim_get_hl(0, { name = "FloatBorder", link = false })
  local comment = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
  local fg = (border and border.fg) or (comment and comment.fg) or "#5c6a72"
  vim.api.nvim_set_hl(0, "WinSeparator", { fg = fg, bg = "NONE" })
end
set_win_separator()
vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("UserWinSeparator", { clear = true }),
  callback = set_win_separator,
})
o.showtabline = 2
o.showmode = false -- Mode pill is rendered in the custom statusline
o.whichwrap:append("<,>,h,l")
o.timeout = true
o.timeoutlen = 300

-- 0.13 critical: virtual_lines.current_line triggers on CursorHold (default 4000ms is way too slow)
o.updatetime = 250

-- Quality of life & cross-platform defaults
o.autoread = true -- 0.13: real-time file watcher auto-reloads buffers edited by AI CLIs
o.undofile = true
o.ignorecase = true
o.smartcase = true
o.splitright = true
o.splitbelow = true
o.scrolloff = 4
o.termguicolors = true
if vim.fn.has("nvim-0.13") == 1 then
  pcall(function() o.shortmess:append("u") end) -- 0.13: silence undo/redo messages
  pcall(function() o.messagesopt:append("pager:<CR>,timeout:4000") end) -- 0.13: ui2 pager key & timeout
end
o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

----- [ Diagnostics ] -----
vim.diagnostic.config({
  virtual_lines = { current_line = true },
  severity_sort = true,
})

----- [ Filetypes (.NET / C# ecosystem) ] -----
vim.filetype.add({
  extension = {
    csproj = "xml",
    fsproj = "xml",
    vbproj = "xml",
    props = "xml",
    targets = "xml",
    slnx = "xml",
    xaml = "xml",
    axaml = "xml",
  },
})
