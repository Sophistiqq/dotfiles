vim.pack.add({
  { src = "https://github.com/backdround/tabscope.nvim" }
})

require("tabscope").setup({})

vim.keymap.set("n", "<M-o>", require("tabscope").remove_tab_buffer)
