-- Pull community lsp/*.lua definitions via vim.pack (no manual lsp/ folder copying needed)
vim.pack.add({
  { src = "https://github.com/neovim/nvim-lspconfig" },
})

local servers = {
  "lua_ls",
  "ts_ls",
  "svelte",
  "html",
  "cssls",
  "emmet_language_server",
  "rust_analyzer",
  "qmlls",
  "prismals",
  "roslyn",
  "copilot",
}

vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      inlayHints = {
        typeHints = { enable = true },
        parameterHints = { enable = true },
        closingBraceHints = { enable = true, minLines = 25 },
      },
    },
  },
})

local ts_inlay_hints = {
  includeInlayParameterNameHints = "all",
  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
  includeInlayFunctionParameterTypeHints = true,
  includeInlayVariableTypeHints = true,
  includeInlayPropertyDeclarationTypeHints = true,
  includeInlayFunctionLikeReturnTypeHints = true,
  includeInlayEnumMemberValueHints = true,
}

vim.lsp.config("ts_ls", {
  settings = {
    typescript = { inlayHints = ts_inlay_hints },
    javascript = { inlayHints = ts_inlay_hints },
  },
})

vim.lsp.enable(servers)

-- Zero-plugin Mason v2 auto-enabler: automatically enables every Mason-installed LSP
-- at startup AND live the moment `:Mason` finishes installing a new server
local ok_mr, mr = pcall(require, "mason-registry")
if ok_mr then
  local function enable_mason_pkg(pkg, notify)
    local name = pkg and pkg.spec and pkg.spec.neovim and pkg.spec.neovim.lspconfig
    if not name or vim.lsp.is_enabled(name) then
      return
    end
    vim.lsp.enable(name)
    if notify then
      vim.notify("LSP auto-enabled: " .. name, vim.log.levels.INFO)
    end
  end

  for _, pkg in ipairs(mr.get_installed_packages()) do
    enable_mason_pkg(pkg, false)
  end

  mr:on(
    "package:install:success",
    vim.schedule_wrap(function(pkg)
      enable_mason_pkg(pkg, true)
    end)
  )
end

-- Enable native Neovim 0.12/0.13 CodeLens (virtual lines; great for C# references & test lenses)
if vim.lsp.codelens and vim.lsp.codelens.enable then
  vim.lsp.codelens.enable(true)
end

-- Enable inlay hints & native 0.12/0.13 inline completions per buffer on LspAttach
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspAttach", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    if client:supports_method("textDocument/inlayHint", args.buf) then
      vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
    end

    -- Native Neovim 0.12/0.13 LSP inline completion (zero-plugin Copilot ghost text)
    if client:supports_method("textDocument/inlineCompletion", args.buf) then
      vim.lsp.inline_completion.enable(true, { bufnr = args.buf })

      vim.keymap.set("i", "<C-f>", function()
        if not vim.lsp.inline_completion.get() then
          return "<C-f>"
        end
      end, { expr = true, buf = args.buf, desc = "Accept LSP inline completion" })

      vim.keymap.set("i", "<C-g>", function()
        vim.lsp.inline_completion.select()
      end, { buf = args.buf, desc = "Next LSP inline completion" })
    end
  end,
})

vim.keymap.set("n", "<leader>ai", function()
  local next_state = not vim.lsp.inline_completion.is_enabled()
  vim.lsp.inline_completion.enable(next_state)
  vim.notify("Inline completion " .. (next_state and "enabled" or "disabled"), vim.log.levels.INFO)
end, { desc = "Toggle Native Inline Completion" })

-- Native format-on-save (replaces conform.nvim when using LSP formatting)
vim.g.autoformat_enabled = true

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("UserLspAutoFormat", { clear = true }),
  callback = function(args)
    if not vim.g.autoformat_enabled then
      return
    end
    local clients = vim.lsp.get_clients({ bufnr = args.buf, method = "textDocument/formatting" })
    if #clients > 0 then
      vim.lsp.buf.format({ bufnr = args.buf, timeout_ms = 500 })
    end
  end,
})
