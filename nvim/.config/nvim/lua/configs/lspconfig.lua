local servers = {
  "lua_ls",
  "ts_ls",
  "svelte",
  "html",
  "cssls",
  "emmet_language_server",
<<<<<<< Updated upstream
  "rust_analyzer",
  "roslyn"
=======
  "qmlls",
  "prismals",
  "rust_analyzer",
>>>>>>> Stashed changes
}

vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust_analyzer"] = {
      inlayHints = {
        typeHints = { enable = true },
        parameterHints = { enable = true },
        closingBraceHints = { enable = true, minLines = 25 },
      }
    }
  }
})

vim.lsp.config("ts_ls", {
  settings = {
    ["ts_ls"] = {
      inlayHints = {
        typeHints = { enable = true },
        parameterHints = { enable = true },
        closingBraceHints = { enable = true, minLines = 25 },
      }
    }
  }
})


vim.lsp.enable(servers)
