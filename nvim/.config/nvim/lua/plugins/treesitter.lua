vim.pack.add({
  { src = "https://github.com/romus204/tree-sitter-manager.nvim" },
})

require("tree-sitter-manager").setup({
  auto_install = true,
  ensure_installed = {
    "c_sharp",
    "xml",
    "json",
    "lua",
    "rust",
    "typescript",
    "javascript",
    "svelte",
    "html",
    "css",
    "markdown",
    "markdown_inline",
  },
})
