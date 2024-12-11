return {
  {
    "ellisonleao/carbon-now.nvim",
    lazy = true,
    cmd = "CarbonNow",
    config = function()
      require("carbon-now").setup()
    end,
  },
}
