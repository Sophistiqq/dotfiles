vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter",  },
})

local status, configs = pcall(require, "nvim-treesitter.configs")
if status then
  configs.setup({
    ensure_installed = { "rust", "javascript", "zig", "svelte", "typescript" },
    highlight = {
      enable = true,
    },
  })
else
  vim.notify("nvim-treesitter.configs not found", vim.log.levels.WARN)
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'rust', 'javascript', 'zig', 'svelte', 'typescript' },
  callback = function() 
    pcall(vim.treesitter.start)
  end
})
