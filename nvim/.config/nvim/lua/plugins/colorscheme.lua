vim.pack.add({
  { src = "https://github.com/neanias/everforest-nvim" }
})
require("everforest").setup({
  transparent_background_level = 1
})

vim.cmd('colorscheme everforest')
