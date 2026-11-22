-- Sidekick.nvim: AI CLI bridge (agy/Antigravity, opencode, codex, gemini) + Copilot NES
vim.pack.add({
  { src = "https://github.com/folke/sidekick.nvim" },
})

require("sidekick").setup({
  nes = {
    enabled = true,
  },
  cli = {
    watch = true,
    picker = "telescope",
    -- Keep mux disabled by default for full Windows compatibility (works natively in Neovim splits)
    mux = {
      enabled = false,
    },
    tools = {
      -- Custom tool definition for Antigravity CLI (`agy`)
      antigravity = {
        cmd = { "agy" },
        is_proc = "\\<agy\\>",
        continue = { "--continue" },
      },
    },
  },
})

local map = vim.keymap.set

-- Next Edit Suggestions (NES) — Windows-safe (avoids <Tab> which shadows <C-i> in ConPTY)
map("n", "<leader>an", function()
  if not require("sidekick").nes_jump_or_apply() then
    vim.notify("No active Next Edit Suggestion", vim.log.levels.INFO)
  end
end, { desc = "Jump / Apply Next Edit Suggestion (NES)" })

map("n", "<leader>ac", function()
  require("sidekick.nes").clear()
end, { desc = "Clear NES Suggestions" })

-- AI CLI sessions (antigravity/agy, opencode, codex, gemini, etc.)
map({ "n", "v" }, "<leader>aa", function()
  require("sidekick.cli").toggle()
end, { desc = "Toggle AI CLI" })

map("n", "<leader>as", function()
  require("sidekick.cli").select({ filter = { installed = true } })
end, { desc = "Select Installed AI CLI" })

map({ "n", "v" }, "<leader>ay", function()
  require("sidekick.cli").toggle({ name = "antigravity", focus = true })
end, { desc = "Toggle Antigravity (agy)" })

map({ "n", "v" }, "<leader>ao", function()
  require("sidekick.cli").toggle({ name = "opencode", focus = true })
end, { desc = "Toggle OpenCode" })

map({ "n", "v" }, "<leader>ag", function()
  require("sidekick.cli").toggle({ name = "gemini", focus = true })
end, { desc = "Toggle Gemini CLI" })

map({ "n", "v" }, "<leader>ax", function()
  require("sidekick.cli").toggle({ name = "codex", focus = true })
end, { desc = "Toggle Codex CLI" })

map({ "n", "x" }, "<leader>at", function()
  require("sidekick.cli").send({ msg = "{this}" })
end, { desc = "Send Selection / Context to AI" })

map("n", "<leader>af", function()
  require("sidekick.cli").send({ msg = "{file}" })
end, { desc = "Send Current File to AI" })

map({ "n", "x" }, "<leader>ap", function()
  require("sidekick.cli").prompt()
end, { desc = "Select AI Prompt (Explain, Fix, Tests...)" })

map("n", "<leader>ad", function()
  require("sidekick.cli").close()
end, { desc = "Detach / Close AI CLI Session" })
