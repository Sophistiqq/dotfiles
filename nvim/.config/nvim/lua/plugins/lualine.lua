vim.pack.add({
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
})


require('lualine').setup({
  options = {
    globalstatus = true
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch' },
    lualine_c = { 'filename' },
    lualine_x = { 'filetype' },
    lualine_y = { 'diagnostics' },
    lualine_z = { 'location' }
  },
  extensions = { 'nvim-tree', 'fzf' }
})
