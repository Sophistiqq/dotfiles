vim.pack.add({
  { src = "https://github.com/romgrk/barbar.nvim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
})

require("barbar").setup({
  tabpages = true,
  maximum_padding = 1,
  sidebar_filetypes = {
    NvimTree = true,
  },
  icons = {
    gitsigns = {
      added = { enabled = true, icon = '+' },
      changed = { enabled = true, icon = '~' },
      deleted = { enabled = true, icon = '-' },
    },
  },
  no_name_title = nil,
})
