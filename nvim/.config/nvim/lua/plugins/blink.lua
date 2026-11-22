-- [ Blink ] --
-- Native library build is triggered only on install/update via PackChanged in init.lua
vim.pack.add({
  { src = "https://github.com/saghen/blink.lib" },
  { src = "https://github.com/saghen/blink.cmp" },
})

require("blink.cmp").setup({
  keymap = {
    preset = "super-tab",
  },
  appearance = {
    nerd_font_variant = "mono",
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
  completion = {
    documentation = { auto_show = true },
  },
  signature = { enabled = true },
  cmdline = {
    keymap = { preset = "inherit" },
    completion = { menu = { auto_show = true } },
  },
  fuzzy = { implementation = "prefer_rust_with_warning" },
})
