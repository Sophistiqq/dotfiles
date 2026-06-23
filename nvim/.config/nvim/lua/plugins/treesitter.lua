vim.pack.add {
  { src = "https://github.com/romus204/tree-sitter-manager.nvim" }
}


require("tree-sitter-manager").setup({
  auto_install = true,
})
