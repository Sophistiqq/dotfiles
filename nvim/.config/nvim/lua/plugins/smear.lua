vim.pack.add({
  { src = "https://github.com/sphamba/smear-cursor.nvim" }
})

require("smear_cursor").setup({
  trailing_stiffness = 0.3,
  trailing_exponent = 1,
})
