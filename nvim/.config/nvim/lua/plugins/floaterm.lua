vim.pack.add({
  { src = "https://github.com/nvzone/floaterm" },
  { src = "https://github.com/nvzone/volt" },
})

require("floaterm").setup({
  size = { h = 80, w = 90 },
  mappings = {
    term = function(buf)
      vim.keymap.set({ "n", "t" }, "<C-Tab>", function()
        require("floaterm.api").cycle_term_bufs "prev"
      end, { buffer = buf })
    end,
  }
})

vim.keymap.set("n", "<C-`>", ":FloatermToggle<CR>", { silent = true })
vim.keymap.set("t", "<C-`>", "<C-\\><C-n>:FloatermToggle<CR>", { silent = true })
