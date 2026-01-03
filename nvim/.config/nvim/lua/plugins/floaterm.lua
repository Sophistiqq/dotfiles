vim.pack.add({ { src = "https://github.com/akinsho/toggleterm.nvim" } })
require("toggleterm").setup({})


vim.keymap.set("t", "<C-x>", [[<C-\><C-n>]], { silent = true })
vim.keymap.set({ "n", "t" }, "<M-v>", [[<C-\><C-n>:ToggleTerm direction=vertical size=50<CR>]], { silent = true })
vim.keymap.set({ "n", "t" }, "<M-h>", [[<C-\><C-n>:ToggleTerm direction=horizontal<CR>]], { silent = true })
vim.keymap.set({ "n", "t" }, "<M-i>", [[<C-\><C-n>:ToggleTerm direction=float<CR>]], { silent = true })
