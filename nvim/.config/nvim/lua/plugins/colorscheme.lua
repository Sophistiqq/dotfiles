vim.pack.add({
  { src = "https://github.com/neanias/everforest-nvim" },
  { src = "https://github.com/sainnhe/gruvbox-material" }
})
require("everforest").setup({
  transparent_background_level = 1,
})


vim.cmd("colorscheme gruvbox-material")
