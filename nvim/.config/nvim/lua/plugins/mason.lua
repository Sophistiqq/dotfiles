vim.pack.add({
  { src = "https://github.com/mason-org/mason.nvim.git" },
})

require('mason').setup({
  registries = {
    "github:mason-org/mason-registry",
    "github:Crashdummyy/mason-registry",
  },
})
