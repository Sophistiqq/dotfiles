vim.pack.add({
  { src = "https://github.com/neanias/everforest-nvim" },
  -- { src = "https://github.com/folke/tokyonight.nvim" },
  -- { src = "https://github.com/olimorris/onedarkpro.nvim" },
})
require("everforest").setup({
  transparent_background_level = 1,
})

-- require("tokyonight").setup({
--   style = "storm",
-- })


vim.cmd("colorscheme everforest")
