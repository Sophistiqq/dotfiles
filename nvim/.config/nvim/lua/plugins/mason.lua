vim.pack.add({
  { src = "https://github.com/mason-org/mason.nvim.git" },
})

require("mason").setup({
  registries = {
    "github:mason-org/mason-registry",
    "github:Crashdummyy/mason-registry", -- Required for roslyn (C# LSP)
  },
})

-- Native helper command to install core dev tools (C#, Rust, Web, Lua) on fresh Linux/Windows machines
local ensure_tools = {
  "roslyn",
  "netcoredbg",
  "codelldb",
  "copilot-language-server",
  "lua-language-server",
  "typescript-language-server",
}

vim.api.nvim_create_user_command("MasonEnsure", function()
  local mr = require("mason-registry")
  mr.refresh(function()
    for _, tool in ipairs(ensure_tools) do
      local ok, pkg = pcall(mr.get_package, tool)
      if ok and not pkg:is_installed() then
        vim.notify("Mason: installing " .. tool .. "...", vim.log.levels.INFO)
        pkg:install()
      end
    end
  end)
end, { desc = "Install core Mason packages (roslyn, netcoredbg, codelldb, ...)" })
