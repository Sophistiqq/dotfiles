return {
  "rachartier/tiny-code-action.nvim",
  dependencies = {
    { "nvim-lua/plenary.nvim" },

    { "nvim-telescope/telescope.nvim" },
    { "ibhagwan/fzf-lua" },
  },
  event = "LspAttach",
  opts = {
  },
}
