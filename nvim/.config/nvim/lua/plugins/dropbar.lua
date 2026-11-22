-- Build step for telescope-fzf-native is handled via PackChanged in init.lua
vim.pack.add({
  { src = "https://github.com/Bekaboo/dropbar.nvim" },
  { src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim" },
})

vim.keymap.set("n", "<leader>;", function()
  require("dropbar.api").pick()
end, { desc = "Pick symbols in winbar" })
vim.keymap.set("n", "[;", function()
  require("dropbar.api").goto_context_start()
end, { desc = "Go to start of current context" })
vim.keymap.set("n", "];", function()
  require("dropbar.api").select_next_context()
end, { desc = "Select next context" })
