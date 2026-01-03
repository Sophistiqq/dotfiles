vim.pack.add({
  { src = "https://github.com/neanias/everforest-nvim" }
})
require("everforest").setup({
  transparent_background_level = 0
})

vim.cmd('colorscheme everforest')
