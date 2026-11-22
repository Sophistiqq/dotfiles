-- [ Telescope ] --
vim.pack.add({
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
})

local telescope = require("telescope")
telescope.setup({
  pickers = {
    colorscheme = {
      enable_preview = true,
    },
  },
})

-- Load fzf-native if compiled on this machine (Linux make / Windows cmake)
pcall(telescope.load_extension, "fzf")
