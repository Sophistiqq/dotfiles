require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Mapping the switching panes with arrow keys
map("n", "<C-Left>", "<C-w>h", { silent = true })
map("n", "<C-Down>", "<C-w>j", { silent = true })
map("n", "<C-Up>", "<C-w>k", { silent = true })
map("n", "<C-Right>", "<C-w>l", { silent = true })
map("n", "<leader>ca", function ()
  vim.lsp.buf.code_action()
end, {  silent = true, desc = "Code Action" })


require("cmp").mapping = {
  ["<Up>"] = require("cmp").mapping.select_prev_item(),
  ["<Down>"] = require("cmp").mapping.select_next_item(),
  ["<Tab>"] = require("cmp").mapping.confirm {
    behavior = require("cmp").ConfirmBehavior.Replace,
    select = true
  }
}
