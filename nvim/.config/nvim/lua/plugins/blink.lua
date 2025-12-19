-- [ Blink ] --

vim.pack.add({
  { src = "https://github.com/saghen/blink.cmp" },
  { src = "https://github.com/rafamadriz/friendly-snippets" },
})

require('blink-cmp').setup({
  keymap = { preset = 'super-tab' },
  appearance = {
    nerd_font_variant = 'mono'
  },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },
  completion = { documentation = { auto_show = true } },
  fuzzy = { implementation = "prefer_rust_with_warning" }
})
