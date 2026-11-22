-- Build step for telescope-fzf-native is handled via PackChanged in init.lua
vim.pack.add({
  { src = "https://github.com/Bekaboo/dropbar.nvim" },
  { src = "https://github.com/nvim-telescope/telescope-fzf-native.nvim" },
})

require("dropbar").setup({
  bar = {
    enable = function(buf, win, _)
      if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then
        return false
      end
      if vim.bo[buf].buftype ~= "" then
        return false
      end
      if vim.api.nvim_win_get_config(win).relative ~= "" then
        return false
      end
      return vim.bo[buf].ft == "markdown"
        or pcall(vim.treesitter.get_parser, buf)
        or not vim.tbl_isempty(vim.lsp.get_clients({ bufnr = buf, method = "textDocument/documentSymbol" }))
    end,
  },
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
