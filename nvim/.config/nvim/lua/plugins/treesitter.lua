vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

require('nvim-treesitter').setup()

local parsers = { "rust", "javascript", "zig", "svelte", "typescript" }

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    require("nvim-treesitter").install(parsers)
  end,
})
