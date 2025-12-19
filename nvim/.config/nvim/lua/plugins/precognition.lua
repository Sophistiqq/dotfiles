vim.pack.add({
  { src = "https://github.com/tris203/precognition.nvim" }
})

require("precognition").setup({
})
require("precognition").toggle()

vim.keymap.set("n", "<leader>p", function()
  require("precognition").toggle()
end, { desc = "Precognition toggle" })
