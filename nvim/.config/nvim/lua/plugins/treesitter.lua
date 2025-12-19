vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "lua",
    "typescript",
    "svelte",
    "html",
    "css",
    "javascript",
  },
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = true,
  },
})
