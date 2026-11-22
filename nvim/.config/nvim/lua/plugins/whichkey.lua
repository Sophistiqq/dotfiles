vim.pack.add({
  { src = "https://github.com/folke/which-key.nvim" },
})

local wk = require("which-key")
wk.setup({})
wk.add({
  { "<leader>a", group = "AI (Sidekick & Copilot)" },
  { "<leader>c", group = "Code / LSP / EF Core" },
  { "<leader>d", group = "Debug (DAP)" },
  { "<leader>e", group = "Explorer" },
  { "<leader>f", group = "Find (Telescope)" },
  { "<leader>g", group = "Git" },
  { "<leader>s", group = "Session" },
  { "<leader>t", group = "Terminal / Toggle" },
  { "<leader>u", group = "UI / Utilities" },
})

vim.keymap.set("n", "<leader>uk", function()
  wk.show({ global = false })
end, { desc = "Buffer-Local Keymaps (which-key)" })
