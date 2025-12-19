vim.pack.add({
  { src = "https://github.com/supermaven-inc/supermaven-nvim" },
})

require('supermaven-nvim').setup({
  keymaps = {
    accept_suggestion = "<M-CR>",
    clear_suggestion = "<M-\\>"
  },
  disable_inline_completion = false,
})
