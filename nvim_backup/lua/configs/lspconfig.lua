require("nvchad.configs.lspconfig").defaults()

local servers = { "html", "cssls", "svelte", "ts_ls", "vtsls", 'lua_ls', 'emmet_language_server', 'tailwindcss' }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers 
