local map = vim.keymap.set

-- Telescope
local builtin = require('telescope.builtin')
map("n", "<leader>ff", builtin.find_files, { desc = "[F]ind Files" })
map("n", "<leader>fw", builtin.live_grep, { desc = "[F]ind Words" })
map("n", "<leader>fh", builtin.help_tags, { desc = "[F]ind Help tags" })
map("n", "<leader>fq", builtin.quickfix, { desc = "[F]ind Quickfix" })
map("n", "<leader>fq", builtin.diagnostics, { desc = "[F]ind Diagnostics" })
map("n", "<leader>th", builtin.colorscheme, { desc = "[F]ind Colorscheme" })

map("n", "<C-Space>", builtin.buffers, { desc = "[F]ind Buffers" })
map("n", "<Tab>", ":bn<CR>", { desc = "Next Buffer", silent = true, noremap = true })
map("n", "<S-Tab>", ":bp<CR>", { desc = "Previous Buffer", silent = true, noremap = true })


-- Quality of Life
map("n", "<C-s>", ":w<CR>", { silent = true, noremap = true })
map("n", ";", ":", { silent = true, noremap = true })
map("n", "<leader>ra", vim.lsp.buf.rename, { desc = "Rename" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action", noremap = true })
map("n", "<leader>gt", ":LazyGit<CR>", { desc = "LazyGit UI", noremap = true })
map("n", "<M-z>", ":set wrap!<CR>", { desc = "Toggle Wrap", noremap = true, silent = true })
map("n", "<Esc>", ":noh<CR><Esc>", { desc = "Clear Highlight", noremap = true, silent = true })
map("n", "<leader>/", "gcc", { remap = true, silent = true })
map("v", "<leader>/", "gc", { remap = true, silent = true })

-- NvimTree
map("n", "<C-n>", ":NvimTreeFindFileToggle<CR>", { silent = true, noremap = true })

-- Close Buffer
map("n", "<leader>x", ":bd<CR>", { desc = "Close Buffer", noremap = true, silent = true })


map("v", "<C-f>", "zf", { desc = "zf", noremap = true, silent = true })

-- toggle relative number
map("n", "<leader>rn", ":set rnu!<CR>", { desc = "Toggle Relative Number", noremap = true })


-- Map C- left right up down to be the same as the arrow keys
map("n", "<C-Left>", "<C-w>h", { desc = "Move Left", noremap = true, silent = true })
map("n", "<C-Right>", "<C-w>l", { desc = "Move Right", noremap = true, silent = true })
map("n", "<C-Up>", "<C-w>k", { desc = "Move Up", noremap = true, silent = true })
map("n", "<C-Down>", "<C-w>j", { desc = "Move Down", noremap = true, silent = true })

map("n", "<leader>ih", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })
