-- [ Conform ] --

vim.pack.add({
  { src = "https://github.com/stevearc/conform.nvim" },
})
require("conform").setup({
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
})
