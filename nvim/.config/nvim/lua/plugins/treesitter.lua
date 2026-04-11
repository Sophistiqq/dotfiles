vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter",  },
})

require('nvim-treesitter').setup {
  install_dir = vim.fn.stdpath('data') .. '/site'
}

require('nvim-treesitter').install { 'rust', 'javascript', 'zig', 'svelte', 'typescript' }


vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'rust', 'javascript', 'zig', 'svelte', 'typescript' },
  callback = function() vim.treesitter.start() end
})
