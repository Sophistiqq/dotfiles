vim.pack.add({
  { src = "https://github.com/supermaven-inc/supermaven-nvim" },
})

require('supermaven-nvim').setup({
  keymaps = {
    accept_suggestion = "<C-f>",
    clear_suggestion = "<C-\\>"
  },
  disable_inline_completion = false,
})
