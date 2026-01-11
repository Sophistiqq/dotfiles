local servers = {
  "lua_ls",
  "ts_ls",
  "svelte",
  "html",
  "cssls",
  "emmet_language_server",
  "qmlls",
  "prismals",
}

vim.lsp.config("roslyn", {
  on_attach = function()
    print("This will run when the server attaches!")
  end,
  settings = {
    ["csharp|inlay_hints"] = {
      csharp_enable_inlay_hints_for_implicit_object_creation = true,
      csharp_enable_inlay_hints_for_implicit_variable_types = true,
    },
    ["csharp|code_lens"] = {
      dotnet_enable_references_code_lens = true,
    },
  },
})
vim.lsp.enable('roslyn_ls')

vim.lsp.enable(servers)
