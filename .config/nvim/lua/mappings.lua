require "nvchad.mappings"
-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
-- map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Mapping the switching panes with arrow keys
map("n", "<C-Left>", "<C-w>h", { silent = true })
map("n", "<C-Down>", "<C-w>j", { silent = true })
map("n", "<C-Up>", "<C-w>k", { silent = true })
map("n", "<C-Right>", "<C-w>l", { silent = true })
map("n", "<leader>ca", function()
  require("tiny-code-action").code_action()
end, { noremap = true, silent = true})

-- :CopilotChat
map("n", "<leader>cc", "<cmd> CopilotChatOpen <cr>", { desc = "Open Copilot Chat" })
