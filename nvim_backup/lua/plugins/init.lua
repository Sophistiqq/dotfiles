return {
  {
    "stevearc/conform.nvim",
    event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },
  -- {
  --   "Saghen/blink.cmp",
  --   opts = {
  --     keymap = { preset = "super-tab" }
  --   }
  -- },

  -- {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    auto_install = true
    -- ensure_installed = {
    -- 	"vim", "lua", "vimdoc",
    --    "html", "css"
    -- },
  },
  -- },
  --
  {
    "supermaven-inc/supermaven-nvim",
    config = function()
      require("supermaven-nvim").setup({
        keymaps = {
          accept_suggestion = "<M-Tab>",
          clear_suggestion = "<C-]>",
          accept_word = "<C-j>",
        },
        color = {
          suggestion_color = "#ffffff",
          cterm = 244,
        },
        log_level = "info",              -- set to "off" to disable logging completely
        disable_inline_completion = false, -- disables inline completion for use with cmp
        disable_keymaps = false,         -- disables built in keymaps for more manual control
        condition = function()
          return false
        end
      })
    end
  }
}
