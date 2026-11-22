local map = vim.keymap.set

----- [ Telescope (lazy-required to keep startup fast) ] -----
local function tb(fn)
  return function()
    require("telescope.builtin")[fn]()
  end
end

map("n", "<leader>ff", tb("find_files"), { desc = "Find Files" })
map("n", "<leader>fw", tb("live_grep"), { desc = "Find Words (Grep)" })
map("n", "<leader>fh", tb("help_tags"), { desc = "Find Help Tags" })
map("n", "<leader>fk", tb("keymaps"), { desc = "Find Keymaps (Fuzzy)" })
map("n", "<leader>fq", tb("quickfix"), { desc = "Find Quickfix" })
map("n", "<leader>fd", tb("diagnostics"), { desc = "Find Diagnostics" })
map("n", "<leader>fb", tb("buffers"), { desc = "Find Buffers" })
map("n", "<leader><leader>", tb("buffers"), { desc = "Find Buffers" })
map("n", "<leader>fs", tb("lsp_document_symbols"), { desc = "Find Document Symbols" })
map("n", "<leader>fS", tb("lsp_dynamic_workspace_symbols"), { desc = "Find Workspace Symbols" })

----- [ Buffers (<Tab>/<S-Tab> plus Neovim native ]b / [b) ] -----
map("n", "<Tab>", "<cmd>bnext<CR>", { desc = "Next Buffer" })
map("n", "<S-Tab>", "<cmd>bprevious<CR>", { desc = "Previous Buffer" })
map("n", "<leader>x", "<cmd>bdelete<CR>", { desc = "Close Buffer" })

----- [ Window Navigation (Windows + Linux safe across normal & terminal modes) ] -----
map("n", "<C-h>", "<C-w>h", { desc = "Move Left" })
map("n", "<C-j>", "<C-w>j", { desc = "Move Down" })
map("n", "<C-k>", "<C-w>k", { desc = "Move Up" })
map("n", "<C-l>", "<C-w>l", { desc = "Move Right" })
map("n", "<C-Left>", "<C-w>h", { desc = "Move Left" })
map("n", "<C-Down>", "<C-w>j", { desc = "Move Down" })
map("n", "<C-Up>", "<C-w>k", { desc = "Move Up" })
map("n", "<C-Right>", "<C-w>l", { desc = "Move Right" })
map("n", "<M-Left>", "<C-w>h", { desc = "Move Left" })
map("n", "<M-Down>", "<C-w>j", { desc = "Move Down" })
map("n", "<M-Up>", "<C-w>k", { desc = "Move Up" })
map("n", "<M-Right>", "<C-w>l", { desc = "Move Right" })

----- [ File Explorer (NvimTree — avoids <C-m> which equals <CR> on Windows/ConPTY) ] -----
map("n", "<C-n>", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Toggle File Explorer" })
map("n", "<leader>ee", "<cmd>NvimTreeFindFileToggle<CR>", { desc = "Toggle File Explorer" })
map("n", "<leader>e>", "<cmd>NvimTreeResize +10<CR>", { desc = "Widen Explorer" })
map("n", "<leader>e<", "<cmd>NvimTreeResize -10<CR>", { desc = "Shrink Explorer" })

----- [ Quality of Life ] -----
map("n", "<leader>w", "<cmd>write<CR>", { desc = "Save File" })
map("n", ";", ":", { desc = "Command Mode" })
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear Search Highlight" })
map("n", "<leader>/", "gcc", { desc = "Toggle Line Comment", remap = true })
map("v", "<leader>/", "gc", { desc = "Toggle Selection Comment", remap = true })
map("v", "<leader>f", "zf", { desc = "Fold Selection" })

----- [ UI & Built-in Neovim 0.12 / 0.13 Toggles ] -----
map("n", "<leader>uw", "<cmd>set wrap!<CR>", { desc = "Toggle Wrap" })
map("n", "<leader>rn", "<cmd>set relativenumber!<CR>", { desc = "Toggle Relative Number" })
map("n", "<leader>uu", "<cmd>Undotree<CR>", { desc = "Toggle Built-in Undotree" })
map("n", "<leader>uf", function()
  vim.g.autoformat_enabled = not vim.g.autoformat_enabled
  vim.notify("Autoformat " .. (vim.g.autoformat_enabled and "enabled" or "disabled"), vim.log.levels.INFO)
end, { desc = "Toggle Format on Save" })

----- [ LSP (native 0.11+ grn/gra/grr/gri/grt/grx/gO also active) ] -----
map("n", "<leader>ra", vim.lsp.buf.rename, { desc = "LSP Rename" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP Code Action" })
map("n", "<leader>cl", vim.lsp.codelens.run, { desc = "Run LSP CodeLens (C# Tests/Refs)" })
map("n", "<leader>ih", function()
  local next_state = not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
  vim.lsp.inlay_hint.enable(next_state)
  vim.notify("Inlay hints " .. (next_state and "enabled" or "disabled"), vim.log.levels.INFO)
end, { desc = "Toggle Inlay Hints" })

----- [ Session ] -----
map("n", "<leader>ss", "<cmd>SessionSave<CR>", { desc = "Save Session" })
map("n", "<leader>sr", "<cmd>SessionRestore<CR>", { desc = "Restore Session" })
map("n", "<leader>sd", "<cmd>SessionDelete<CR>", { desc = "Delete Session" })

----- [ Flip true/false value under cursor ] -----
map("n", "<leader>tf", function()
  local word = vim.fn.expand("<cword>")
  if word ~= "true" and word ~= "false" then
    return
  end
  vim.cmd("normal! ciw" .. (word == "true" and "false" or "true"))
end, { desc = "Toggle Boolean Value" })
