----- [ Globals ] -----
local g = vim.g

g.mapleader = ' '
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1


----- [ Options ] -----
local o = vim.opt

o.number = true
o.expandtab = true
o.shiftwidth = 2
o.softtabstop = 2
o.tabstop = 2
o.signcolumn = "yes"
o.winborder = "single"
o.smartindent = true
o.termguicolors = true
o.clipboard = "unnamedplus"
o.fillchars = { eob = " " }
o.laststatus = 3
o.whichwrap:append("<,>,h,l")

----- [ Diagnostics ] -----
vim.diagnostic.config({ virtual_lines = { current_line = true } })


----- [ Highlights ] -----
